#!/usr/bin/env bash
# =============================================================
#  menu-energia.sh — menu para bloquear, sair, suspender,
#  reiniciar ou desligar. Atalho: Super + Esc (e botão na barra)
# =============================================================

opcoes="\uf023  Bloquear\n\uf186  Suspender\n\U000f0343  Sair do Hyprland\n\uf01e  Reiniciar\n\uf011  Desligar"

escolha=$(echo -e "$opcoes" | rofi -dmenu -i -p "Energia" -theme-str 'window {width: 300px;} listview {lines: 5;}')

case "$escolha" in
    *Bloquear)  pidof hyprlock || hyprlock ;;
    *Suspender) systemctl suspend ;;
    *Sair*)     hyprctl dispatch 'hl.dsp.exit()' ;;
    *Reiniciar) systemctl reboot ;;
    *Desligar)  systemctl poweroff ;;
esac
