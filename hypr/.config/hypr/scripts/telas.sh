#!/usr/bin/env bash
# =============================================================
#  telas.sh — escolhe a posição das telas (notebook + monitor externo)
# =============================================================
#    telas.sh            → abre o menu (Super + P ou o botão 🖥 da barra)
#    telas.sh <opção>    → aplica direto: cima, baixo, esquerda, direita,
#                          espelhar, so-notebook, so-monitor
#    telas.sh status     → texto para a barra (Waybar)
#
#  A escolha fica salva em ~/.local/state/hypr/telas e o hyprland.lua lê esse
#  arquivo para montar os monitores (por isso continua valendo ao reiniciar).
# =============================================================

ESTADO="$HOME/.local/state/hypr/telas"
mkdir -p "$(dirname "$ESTADO")"
atual=$(cat "$ESTADO" 2>/dev/null || echo cima)

# opção | texto do menu
OPCOES="cima|  Monitor em cima
baixo|  Monitor embaixo
esquerda|  Monitor à esquerda
direita|  Monitor à direita
espelhar|  Espelhar (mesma imagem nas duas)
so-notebook|  Só a tela do notebook
so-monitor|  Só o monitor externo"

texto_de() { echo "$OPCOES" | awk -F'|' -v o="$1" '$1 == o {print $2}'; }

# o monitor externo está ligado no cabo? (qualquer tela que não seja a eDP-1)
monitor_ligado() {
    hyprctl -j monitors all | python3 -c '
import sys, json
print(any(not m["name"].startswith("eDP") for m in json.load(sys.stdin)))' | grep -q True
}

aplicar() {
    local opcao="$1"
    if [ "$opcao" = "so-monitor" ] && ! monitor_ligado; then
        notify-send "Telas" "Nenhum monitor externo ligado — a tela do notebook continua ligada."
        return 1
    fi
    echo "$opcao" > "$ESTADO"
    hyprctl reload >/dev/null          # o hyprland.lua relê o arquivo e reposiciona
    pkill -RTMIN+9 waybar              # atualiza o botão da barra
    notify-send -i video-display "Telas" "$(texto_de "$opcao" | sed 's/^[^ ]*  //')"
}

case "$1" in
    status)
        printf '{"text": "\\uf108", "tooltip": "Telas: %s (Super + P)", "class": "%s"}\n' \
            "$(texto_de "$atual" | sed 's/^[^ ]*  //')" "$atual"
        ;;
    "")
        # marca a opção atual com ●
        menu=$(echo "$OPCOES" | awk -F'|' -v a="$atual" '{print ($1 == a ? "● " : "   ") $2}')
        escolha=$(echo "$menu" | rofi -dmenu -i -p "Telas" -no-custom \
            -theme-str 'window {width: 420px;} listview {lines: 7;}') || exit 0
        escolha=$(echo "$escolha" | sed 's/^● //; s/^   //')
        opcao=$(echo "$OPCOES" | awk -F'|' -v e="$escolha" '$2 == e {print $1}')
        [ -n "$opcao" ] && aplicar "$opcao"
        ;;
    *)
        texto_de "$1" >/dev/null && [ -n "$(texto_de "$1")" ] || { echo "opção inválida: $1"; exit 1; }
        aplicar "$1"
        ;;
esac
