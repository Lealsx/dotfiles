#!/usr/bin/env bash
# =============================================================
#  wallpaper-pausa.sh — pausa ou toca o vídeo do papel de parede
# =============================================================
#    wallpaper-pausa.sh pausar | tocar
#  Chamado pelo efeitos.lua: toca só quando alguma tela está com a área
#  de trabalho vazia (economiza muito a placa de vídeo).
#  Fala com o mpv pelo "socket" criado no wallpaper.sh.
# =============================================================
SOCKET="$XDG_RUNTIME_DIR/mpvpaper.sock"
[ -S "$SOCKET" ] || exit 0          # vídeo não está rodando (ex.: modo economia)

case "$1" in
    pausar) valor=true ;;
    tocar)  valor=false ;;
    *) echo "uso: $0 pausar|tocar"; exit 1 ;;
esac

python3 -c '
import socket, sys
s = socket.socket(socket.AF_UNIX)
s.connect(sys.argv[1])
s.sendall(("{\"command\": [\"set_property\", \"pause\", %s]}\n" % sys.argv[2]).encode())
' "$SOCKET" "$valor" 2>/dev/null
