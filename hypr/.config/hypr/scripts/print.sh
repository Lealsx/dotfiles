#!/usr/bin/env bash
# =============================================================
#  print.sh — captura de tela
#    print.sh area → seleciona uma área com o mouse e abre o editor (swappy)
#    print.sh tela → tela inteira, salva direto e copia
#  As imagens vão para: ~/Imagens/Capturas de tela
# =============================================================

pasta="$(xdg-user-dir PICTURES)/Capturas de tela"
mkdir -p "$pasta"
arquivo="$pasta/Captura de tela de $(date +'%Y-%m-%d %H-%M-%S').png"

case "$1" in
    area)
        # slurp = selecionar área | grim = tirar o print | swappy = editar/salvar
        area=$(slurp) || exit 0   # Esc cancela
        grim -g "$area" - | swappy -f - -o "$arquivo"
        ;;
    tela)
        grim "$arquivo" && wl-copy < "$arquivo"
        notify-send "Captura de tela" "Salva em $pasta e copiada" -i "$arquivo"
        ;;
esac
