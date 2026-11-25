#!/usr/bin/env bash
# =============================================================
#  musica-tema.sh — o sistema muda com o álbum que toca no Spotify
# =============================================================
#    musica-tema.sh            → fica escutando o Spotify (iniciado pelo Hyprland)
#    musica-tema.sh alternar   → liga/desliga o tema musical (Super + Shift + W)
#
#  Quando o Spotify troca de ÁLBUM (mesma capa = não refaz nada):
#   1) baixa a capa do álbum
#   2) musica-wallpaper.py monta o papel de parede animado (capa + vinil girando),
#      a transição "trocando o disco" e calcula a COR DOMINANTE da capa
#   3) matugen gera as cores do sistema a partir da cor dominante e escreve os
#      arquivos "cores" de cada app
#      (modelos em ~/.config/matugen/modelos)
#   4) recarrega Hyprland (bordas), Waybar, kitty e a Central (SwayNC) e troca o papel de parede
#  Spotify fechado/parado → fica o último álbum.
#
#  Quando troca a MÚSICA (mesmo sem trocar de álbum), animações rápidas,
#  que acontecem uma vez só (não pesam):
#   - cartão "Tocando agora" com a capa, deslizando pela direita (SwayNC)
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
    "$HOME/.config/swaync/cores.css:$HOME/.config/swaync/cores-muzan.css"
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
    swaync-client -rs >/dev/null 2>&1       # Central de controle e notificações
    # o Rofi lê as cores sozinho cada vez que abre
}

# Gera papel de parede + cores a partir de uma capa já baixada ($CACHE/capa.png)
gerar() {
    rm -rf "$ALBUM.novo"
    # o gerador devolve a COR DOMINANTE da capa (ex.: #a86668)
    local cor
    cor=$("$SCRIPTS/musica-wallpaper.py" "$CACHE/capa.png" "$ALBUM.novo") || return 1
    echo "$cor" > "$ALBUM.novo/cor"
    # transição "trocando o disco" do álbum antigo para o novo (se houver antigo)
    if [ -f "$ALBUM/fundo.png" ]; then
        "$SCRIPTS/musica-wallpaper.py" --transicao "$ALBUM" "$ALBUM.novo" || true
    fi
    # o álbum novo vira o atual (o mpv continua lendo o antigo até a troca)
    rm -rf "$ALBUM.antigo"
    [ -d "$ALBUM" ] && mv "$ALBUM" "$ALBUM.antigo"
    mv "$ALBUM.novo" "$ALBUM"
    cores_do_album "$cor"
}

# Manda um comando para o mpv do papel de parede (JSON pelo socket)
mpv_comando() {
    python3 -c '
import socket, sys, json, os
s = socket.socket(socket.AF_UNIX)
s.connect(os.environ["XDG_RUNTIME_DIR"] + "/mpvpaper.sock")
s.sendall((json.dumps({"command": sys.argv[1:]}) + "\n").encode())
s.recv(4096)
' "$@" 2>/dev/null
}

# Troca o papel de parede: com o vídeo rodando, toca a transição UMA vez e
# emenda no loop novo, sem reiniciar o player; senão, reinicia pelo wallpaper.sh
trocar_fundo() {
    local socket="$XDG_RUNTIME_DIR/mpvpaper.sock"
    if [ -S "$socket" ] && pgrep -x mpvpaper >/dev/null && [ -f "$ALBUM/transicao.mp4" ] \
       && [ ! -e "$HOME/.cache/hypr-economia" ]; then
        # replace = toca já | append = entra na fila | loop-file só vale para aquele arquivo
        mpv_comando loadfile "$ALBUM/transicao.mp4" replace -1 "loop-file=no"
        mpv_comando loadfile "$ALBUM/wallpaper.mp4" append -1 "loop-file=inf"
    else
        setsid "$SCRIPTS/wallpaper.sh" >/dev/null 2>&1 9>&-
    fi
}

# Cores do sistema a partir da cor dominante ("scheme-content" fica fiel a ela)
cores_do_album() {
    matugen color hex "$1" -m dark -t scheme-content -q
}

# ---------- "último pedido vence" ----------
# Quem ESCUTA o Spotify só anota o álbum mais recente em $PEDIDO e acorda o
# "ajudante". O ajudante espera você parar de pular músicas, gera SÓ o álbum
# mais recente e, ao terminar, confere de novo (você pode ter pulado de novo
# enquanto ele gerava). Assim quem escuta nunca fica travado gerando vídeo,
# e pular várias músicas rápido termina sempre no álbum certo.
PEDIDO="$CACHE/pedido"

ajudante() {
    exec 8>"$CACHE/ajudante.lock"
    flock -n 8 || return          # já tem um ajudante trabalhando
    while true; do
        sleep 1.5                 # espera parar de pular
        local alvo
        alvo=$(cat "$PEDIDO" 2>/dev/null)
        if [ -z "$alvo" ] || [ "$alvo" = "$(cat "$ULTIMO" 2>/dev/null)" ]; then
            # nada novo: solta a trava e confere uma última vez (um pedido pode
            # ter chegado bem agora, enquanto outro ajudante não podia entrar)
            flock -u 8
            alvo=$(cat "$PEDIDO" 2>/dev/null)
            [ -z "$alvo" ] || [ "$alvo" = "$(cat "$ULTIMO" 2>/dev/null)" ] && return
            flock -n 8 || return
            continue
        fi
        [ -e "$DESLIGADO" ] || novo_album "$alvo"
        [ -e "$DESLIGADO" ] && echo "$alvo" > "$ULTIMO"
    done
}

novo_album() {
    local url="$1"
    curl -sf --max-time 15 -o "$CACHE/capa.jpg" "$url" || return
    nice -n 15 ffmpeg -v error -y -i "$CACHE/capa.jpg" "$CACHE/capa.png" || return
    # pulou de álbum enquanto baixava? deixa o próximo giro do ajudante cuidar
    [ "$url" = "$(cat "$PEDIDO" 2>/dev/null)" ] || return
    gerar || return
    echo "$url" > "$ULTIMO"
    trocar_fundo      # a transição e as cores novas começam juntas
    aplicar_cores   # troca o vídeo do fundo
}

# Cartão "Tocando agora" + pulso na borda da janela ativa
troca_de_musica() {
    local url="$1" musica="$2" artista="$3" album="$4"
    # capa pequena para o cartão (baixa de novo só se mudou)
    if [ "$url" != "$(cat "$CACHE/cartao.url" 2>/dev/null)" ]; then
        curl -sf --max-time 10 -o "$CACHE/cartao.jpg" "$url" && echo "$url" > "$CACHE/cartao.url"
    fi
    # -a: nome do app (o SwayNC usa para não guardar o cartão no histórico)
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
        [ -f "$ALBUM/cor" ] && cores_do_album "$(cat "$ALBUM/cor")"
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
        [ "$url" = "$(cat "$PEDIDO" 2>/dev/null)" ] && continue   # já anotado
        echo "$url" > "$PEDIDO"                            # anota o mais recente...
        ajudante 9>&- &                                    # ...e acorda o ajudante
    done
    sleep 5   # o playerctl saiu (ex.: reinício do sistema de som): tenta de novo
done
