#!/usr/bin/env bash
# =============================================================
#  wallpaper.sh — papel de parede (vídeo animado ou imagem parada)
# =============================================================
#  Decide sozinho o que mostrar:
#    - existe o vídeo e o modo economia está DESLIGADO
#        → vídeo em loop com o mpvpaper (pausa quando as janelas cobrem a tela)
#    - modo economia LIGADO (ou mpvpaper não instalado)
#        → imagem parada com o hyprpaper (um quadro tirado do próprio vídeo)
#    - não existe vídeo
#        → imagem padrão do Hyprland
#
#  Para trocar o papel de parede: substitua o wallpaper.mp4 por outro vídeo
#  e apague o wallpaper.png (ele é gerado de novo a partir do vídeo).
#  Dica: converta vídeos 4K para 1080p/30 fps sem som antes (bem mais leve):
#    ffmpeg -i video.mp4 -vf "scale=1920:1080,fps=30" -c:v libx264 -crf 22 -an wallpaper.mp4
#  Chamado ao iniciar o Hyprland e pelo modo-economia.sh.
# =============================================================

VIDEO="$HOME/Imagens/wallpapers/wallpaper.mp4"
IMAGEM="$HOME/Imagens/wallpapers/wallpaper.png" # gerada automaticamente do vídeo
PADRAO="/usr/share/hypr/wall2.png"
ECONOMIA="$HOME/.cache/hypr-economia"

# Para o papel de parede que estiver rodando
pkill -x mpvpaper
pkill -x hyprpaper
sleep 0.3

# Gera a imagem parada a partir do vídeo (quadro do segundo 1), só na primeira vez
if [ -f "$VIDEO" ] && [ ! -f "$IMAGEM" ]; then
    ffmpeg -y -loglevel error -ss 1 -i "$VIDEO" -frames:v 1 "$IMAGEM"
fi

if [ -f "$VIDEO" ] && [ ! -e "$ECONOMIA" ] && command -v mpvpaper >/dev/null; then
    # -f: roda em segundo plano | -p: pausa quando o fundo não está visível
    # no-audio: sem som | loop-file=inf: repete para sempre
    # hwdec=auto-safe: usa a placa de vídeo para decodificar (gasta menos)
    # panscan=1.0: preenche a tela inteira, cortando as bordas se precisar
    mpvpaper -f -p -o "no-audio loop-file=inf hwdec=auto-safe panscan=1.0" ALL "$VIDEO"
else
    imagem="$PADRAO"
    [ -f "$IMAGEM" ] && imagem="$IMAGEM"
    config="$HOME/.cache/hyprpaper.conf"
    printf 'wallpaper {\n    monitor =\n    path = %s\n    fit_mode = cover\n}\n\nsplash = false\n' "$imagem" > "$config"
    setsid hyprpaper -c "$config" >/dev/null 2>&1 &
fi
