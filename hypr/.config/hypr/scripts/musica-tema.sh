#!/usr/bin/env bash
# =============================================================
#  musica-tema.sh — o sistema muda com o álbum que toca no Spotify
# =============================================================
#    musica-tema.sh            → fica escutando o Spotify (iniciado pelo Hyprland)
#    musica-tema.sh alternar   → liga/desliga o tema musical (Super + Shift + W)
#
#  Quando o Spotify troca de ÁLBUM (mesma capa = não refaz nada):
#   1) baixa a capa do álbum
#   2) musica-wallpaper.py monta o papel de parede animado (capa + vinil girando)
#   3) matugen tira as cores da capa e escreve os arquivos "cores" de cada app
#      (modelos em ~/.config/matugen/modelos)
#   4) recarrega Hyprland (bordas), Waybar, kitty e mako, e troca o papel de parede
#  Spotify fechado/parado → fica o último álbum.
#
#  Quando troca a MÚSICA (mesmo sem trocar de álbum), animações rápidas,
#  que acontecem uma vez só (não pesam):
#   - cartão "Tocando agora" com a capa, deslizando pela direita (mako)
#   - pulso de luz na borda da janela ativa, na cor do álbum
#  Desligado → volta o tema Muzan (cores-muzan.* e o papel de parede normal).
# =============================================================

CACHE="$HOME/.cache/musica"
ALBUM="$CACHE/album"              # papel de parede do álbum atual (vídeo + imagem)
ULTIMO="$CACHE/ultimo"            # URL da última capa aplicada
DESLIGADO="$CACHE/desligado"      # existe = tema musical desligado
SCRIPTS="$HOME/.config/hypr/scripts"
mkdir -p "$CACHE"

# Arquivos de cores de cada app: <arquivo que o app lê>:<padrão Muzan>
PARES=(
    "$HOME/.config/waybar/cores.css:$HOME/.config/waybar/cores-muzan.css"
    "$HOME/.config/rofi/cores.rasi:$HOME/.config/rofi/cores-muzan.rasi"
    "$HOME/.config/kitty/cores.conf:$HOME/.config/kitty/cores-muzan.conf"
    "$HOME/.config/mako/cores:$HOME/.config/mako/cores-muzan"
)

# Volta as cores do Muzan (o Hyprland usa cores-muzan.lua quando cores.lua não existe)
cores_muzan() {
    rm -f "$HOME/.config/hypr/cores.lua"
    for par in "${PARES[@]}"; do cp "${par#*:}" "${par%%:*}"; done
}

# Garante que os arquivos de cores existem (senão a Waybar reclama)
for par in "${PARES[@]}"; do
    [ -f "${par%%:*}" ] || cp "${par#*:}" "${par%%:*}"
done

# Faz os apps lerem as cores novas
aplicar_cores() {
    hyprctl reload config-only >/dev/null   # bordas e brilho (sem mexer nos monitores)
    pkill -SIGUSR2 -x waybar                # recarrega a barra
    pkill -SIGUSR1 -x kitty                 # recarrega as cores dos terminais abertos
    makoctl reload 2>/dev/null              # notificações
    # o Rofi lê as cores sozinho cada vez que abre
}

# Gera papel de parede + cores a partir de uma capa já baixada ($CACHE/capa.png)
gerar() {
    rm -rf "$ALBUM.novo"
    "$SCRIPTS/musica-wallpaper.py" "$CACHE/capa.png" "$ALBUM.novo" >/dev/null || return 1
    rm -rf "$ALBUM" && mv "$ALBUM.novo" "$ALBUM"
    matugen image "$CACHE/capa.png" -m dark -t scheme-vibrant --prefer saturation -q
}

novo_album() {
    local url="$1"
    curl -sf --max-time 15 -o "$CACHE/capa.jpg" "$url" || return
    nice -n 15 ffmpeg -v error -y -i "$CACHE/capa.jpg" "$CACHE/capa.png" || return
    gerar || return
    echo "$url" > "$ULTIMO"
    aplicar_cores
    setsid "$SCRIPTS/wallpaper.sh" >/dev/null 2>&1 9>&-   # 9>&-: o vídeo não herda a trava (flock)   # troca o vídeo do fundo
}

# Cartão "Tocando agora" + pulso na borda da janela ativa
troca_de_musica() {
    local url="$1" musica="$2" artista="$3" album="$4"
    # capa pequena para o cartão (baixa de novo só se mudou)
    if [ "$url" != "$(cat "$CACHE/cartao.url" 2>/dev/null)" ]; then
        curl -sf --max-time 10 -o "$CACHE/cartao.jpg" "$url" && echo "$url" > "$CACHE/cartao.url"
    fi
    # -a: nome do app (o mako usa para o estilo do cartão)
    # synchronous: um cartão novo SUBSTITUI o anterior, em vez de empilhar
    notify-send -a "Tocando agora" -i "$CACHE/cartao.jpg" -t 5000 \
        -h string:x-canonical-private-synchronous:musica \
        "$musica" "$artista · $album"

    # pulso: a borda acende numa cor clara e volta à cor normal
    local claro destaque
    claro=$(sed -n 's/.*claro *= *"\(.*\)".*/\1/p' "$HOME/.config/hypr/cores.lua" 2>/dev/null)
    destaque=$(sed -n 's/.*destaque *= *"\(.*\)".*/\1/p' "$HOME/.config/hypr/cores.lua" 2>/dev/null)
    hyprctl dispatch "hl.dsp.window.set_prop({ prop = \"active_border_color\", value = \"rgba(${claro:-ffd9c7}ff) rgba(${destaque:-e3123b}ff) 45deg\" })" >/dev/null 2>&1
    sleep 0.6
    hyprctl dispatch 'hl.dsp.window.set_prop({ prop = "active_border_color", value = "unset" })' >/dev/null 2>&1
}

if [ "$1" = "alternar" ]; then
    if [ -e "$DESLIGADO" ]; then
        rm -f "$DESLIGADO"
        if [ -f "$CACHE/capa.png" ]; then
            matugen image "$CACHE/capa.png" -m dark -t scheme-vibrant --prefer saturation -q
        fi
        msg="Ligado: papel de parede e cores seguem o álbum do Spotify."
    else
        touch "$DESLIGADO"
        cores_muzan
        msg="Desligado: voltou o tema Muzan."
    fi
    aplicar_cores
    setsid "$SCRIPTS/wallpaper.sh" >/dev/null 2>&1 9>&-   # 9>&-: o vídeo não herda a trava (flock)
    notify-send -i spotify "Tema musical" "$msg"
    exit 0
fi

# ---------- modo escuta (uma instância só) ----------
# A trava fica no descritor 9; os programas abertos daqui (ex.: o vídeo do
# fundo) recebem "9>&-" para não herdá-la — senão ela ficaria presa neles.
exec 9>"$CACHE/lock"
flock -n 9 || exit 0

while true; do
    # --follow: uma linha nova a cada mudança (música, play/pause...)
    # trackid = identificador da música | artUrl = capa do álbum
    playerctl -p spotify --follow metadata \
        --format '{{mpris:trackid}}|{{mpris:artUrl}}|{{title}}|{{artist}}|{{album}}' 2>/dev/null 9>&- |
    while IFS='|' read -r faixa url musica artista album; do
        [ -z "$url" ] && continue                          # Spotify fechou: fica o último
        if [ "$faixa" != "$faixa_anterior" ]; then         # trocou de MÚSICA
            # na primeira linha (ao iniciar) não mostra o cartão
            [ -n "$faixa_anterior" ] && troca_de_musica "$url" "$musica" "$artista" "$album" &
            faixa_anterior="$faixa"
        fi
        [ -e "$DESLIGADO" ] && continue                    # tema musical desligado
        [ "$url" = "$(cat "$ULTIMO" 2>/dev/null)" ] && continue   # mesmo álbum
        novo_album "$url"
    done
    sleep 5   # o playerctl saiu (ex.: reinício do sistema de som): tenta de novo
done
