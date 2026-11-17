#!/usr/bin/env bash
# =============================================================
#  menu-energia.sh — menu para bloquear, sair, suspender,
#  reiniciar ou desligar. Atalho: Super + Esc (e botão na barra)
# =============================================================

opcoes="  Bloquear\n  Suspender\n󰍃  Sair do Hyprland\n  Reiniciar\n  Desligar"

escolha=$(echo -e "$opcoes" | rofi -dmenu -i -p "Energia" -theme-str 'window {width: 300px;} listview {lines: 5;}')

case "$escolha" in
    *Bloquear)  pidof hyprlock || hyprlock ;;
    *Suspender) systemctl suspend ;;
    *Sair*)     hyprctl dispatch 'hl.dsp.exit()' ;;
    *Reiniciar) systemctl reboot ;;
    *Desligar)  systemctl poweroff ;;
esac
