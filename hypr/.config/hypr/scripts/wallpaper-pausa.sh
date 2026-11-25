#!/usr/bin/env bash
# =============================================================
#  wallpaper-pausa.sh — pausa ou toca o vídeo do papel de parede
# =============================================================
#    wallpaper-pausa.sh auto   → decide sozinho: toca só se alguma tela está
#                                com a área de trabalho VAZIA (senão pausa)
#    wallpaper-pausa.sh pausar | tocar
#  Chamado pelo efeitos.lua (a cada abrir/fechar/mover janela e troca de área)
#  e pelo wallpaper.sh (logo depois de trocar o vídeo do fundo).
#  Fala com o mpv pelo "socket" criado no wallpaper.sh.
# =============================================================
SOCKET="$XDG_RUNTIME_DIR/mpvpaper.sock"
[ -S "$SOCKET" ] || exit 0          # vídeo não está rodando (ex.: modo economia)

modo="$1"
if [ "$modo" = "auto" ]; then
    # áreas de trabalho visíveis (uma por tela) e quantas janelas cada uma tem
    vazia=$(hyprctl -j monitors | python3 -c '
import sys, json, subprocess
areas = {w["id"]: w["windows"] for w in json.loads(subprocess.run(
    ["hyprctl", "-j", "workspaces"], capture_output=True, text=True).stdout)}
print(any(areas.get(m["activeWorkspace"]["id"], 0) == 0 for m in json.load(sys.stdin)))')
    [ "$vazia" = "True" ] && modo=tocar || modo=pausar
fi

case "$modo" in
    pausar) valor=true ;;
    tocar)  valor=false ;;
    *) echo "uso: $0 auto|pausar|tocar"; exit 1 ;;
esac

python3 -c '
import socket, sys
s = socket.socket(socket.AF_UNIX)
s.connect(sys.argv[1])
s.sendall(("{\"command\": [\"set_property\", \"pause\", %s]}\n" % sys.argv[2]).encode())
' "$SOCKET" "$valor" 2>/dev/null
