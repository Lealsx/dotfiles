#!/usr/bin/env bash
# =============================================================
#  modo-economia.sh — liga/desliga o modo economia de bateria
#  Atalho: Super + Shift + B  (ou clique na folha da barra)
# =============================================================
#  Ligado:    perfil de energia "power-saver", tela do notebook a 60 Hz,
#             sem desfoque/sombras/animações, Bluetooth desligado,
#             papel de parede parado em vez do vídeo
#  Desligado: volta tudo ao normal ("balanced", 144 Hz, efeitos, Bluetooth)
#
#    modo-economia.sh          → alterna (liga se estiver desligado e vice-versa)
#    modo-economia.sh status   → informa a barra (Waybar) se está ligado
# =============================================================

marcador="$HOME/.cache/hypr-economia"

if [ "$1" = "status" ]; then
    if [ -e "$marcador" ]; then
        echo '{"text": "", "tooltip": "Modo economia LIGADO (clique para desligar)", "class": "ligado"}'
    else
        echo '{"text": "", "tooltip": "Modo economia desligado (clique para ligar)", "class": "desligado"}'
    fi
    exit 0
fi

if [ -e "$marcador" ]; then
    rm -f "$marcador"
    powerprofilesctl set balanced
    bluetoothctl power on >/dev/null
    mensagem="Desligado: desempenho normal, 144 Hz e efeitos de volta."
else
    mkdir -p "$(dirname "$marcador")"
    touch "$marcador"
    powerprofilesctl set power-saver
    bluetoothctl power off >/dev/null
    mensagem="Ligado: perfil economia, tela a 60 Hz, sem efeitos, Bluetooth desligado."
fi

hyprctl reload >/dev/null          # aplica o economia.lua (efeitos e 60 Hz)
setsid "$HOME/.config/hypr/scripts/wallpaper.sh" >/dev/null 2>&1 &   # vídeo ⇄ imagem parada
pkill -RTMIN+8 waybar              # avisa a barra para atualizar a folha
notify-send -i battery "Modo economia" "$mensagem"
