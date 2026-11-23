#!/usr/bin/env bash
# =============================================================
#  wallpaper.sh — papel de parede (imagem ou vídeo)
# =============================================================
#  Coloque o papel de parede em ~/Imagens/wallpapers/ com o nome:
#    wallpaper.jpg (ou .png / .webp)  → IMAGEM parada (hyprpaper) — leve
#    wallpaper.mp4                    → VÍDEO em loop (mpvpaper)
#  Se existirem os dois, a IMAGEM ganha (o vídeo pesa na placa de vídeo).
#
#  Vídeo: só toca quando alguma tela está com a área de trabalho vazia
#  (efeitos.lua + wallpaper-pausa.sh) e vira imagem no modo economia.
#  Converta vídeos 4K antes (bem mais leve):
#    ffmpeg -i video.mp4 -vf "scale=1920:1080,fps=30" -c:v libx264 -crf 22 -an wallpaper.mp4
#
#  Chamado ao iniciar o Hyprland e pelo modo-economia.sh.
# =============================================================

PASTA="$HOME/Imagens/wallpapers"
VIDEO="$PASTA/wallpaper.mp4"
QUADRO="$PASTA/.quadro-do-video.png"   # imagem tirada do vídeo (modo economia)
PADRAO="/usr/share/hypr/wall2.png"
ECONOMIA="$HOME/.cache/hypr-economia"
SOCKET="$XDG_RUNTIME_DIR/mpvpaper.sock"

# Imagem escolhida pelo usuário (a primeira que existir)
IMAGEM=""
for ext in jpg jpeg png webp; do
    [ -f "$PASTA/wallpaper.$ext" ] && { IMAGEM="$PASTA/wallpaper.$ext"; break; }
done

# Para o papel de parede que estiver rodando
pkill -x mpvpaper
pkill -x hyprpaper
sleep 0.3

if [ -z "$IMAGEM" ] && [ -f "$VIDEO" ] && [ ! -e "$ECONOMIA" ] && command -v mpvpaper >/dev/null; then
    # -f: roda em segundo plano | -p: pausa quando o fundo não está visível
    # hwdec=auto-safe: decodifica pela placa de vídeo | panscan=1.0: preenche a tela
    # input-ipc-server: "socket" para pausar/tocar de fora (wallpaper-pausa.sh)
    mpvpaper -f -p -o "no-audio loop-file=inf hwdec=auto-safe panscan=1.0 input-ipc-server=$SOCKET" ALL "$VIDEO"
    exit 0
fi

# Imagem parada: a escolhida; senão um quadro do vídeo; senão a padrão do Hyprland
if [ -z "$IMAGEM" ] && [ -f "$VIDEO" ]; then
    [ -f "$QUADRO" ] || ffmpeg -y -loglevel error -ss 1 -i "$VIDEO" -frames:v 1 "$QUADRO"
    IMAGEM="$QUADRO"
fi
[ -n "$IMAGEM" ] || IMAGEM="$PADRAO"

config="$HOME/.cache/hyprpaper.conf"
printf 'wallpaper {\n    monitor =\n    path = %s\n    fit_mode = cover\n}\n\nsplash = false\n' "$IMAGEM" > "$config"
setsid hyprpaper -c "$config" >/dev/null 2>&1 &
