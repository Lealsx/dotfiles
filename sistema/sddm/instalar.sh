#!/usr/bin/env bash
# =============================================================
#  sistema/sddm/instalar.sh — tela de login (SDDM) no tema Muzan
# =============================================================
#  Usa o tema SilentSDDM (https://github.com/uiriansan/SilentSDDM) com a
#  configuração própria "silent-muzan.conf": o mesmo vídeo do papel de
#  parede de fundo e as cores carmesim/brasa do Hyprland.
#
#  O SDDM roda ANTES do login e não consegue ler a sua pasta pessoal,
#  por isso tudo é COPIADO (com sudo) para /usr/share/sddm/themes/silent:
#    - o tema, baixado do GitHub numa versão fixa (VERSAO)
#    - silent-muzan.conf        → configs/muzan.conf
#    - o papel de parede do Hyprland (imagem ou vídeo) → backgrounds/
#  e tema.conf → /etc/sddm.conf.d/tema.conf (qual tema e qual cursor usar).
#
#  Rode de novo sempre que trocar o papel de parede ou mudar o silent-muzan.conf.
#  Prévia sem reiniciar:
#    sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/silent
# =============================================================
set -euo pipefail
cd "$(dirname "$0")"

VERSAO=d179078                       # commit do SilentSDDM testado com esta config
DESTINO=/usr/share/sddm/themes/silent
PASTA="$HOME/Imagens/wallpapers"
VIDEO="$PASTA/wallpaper.mp4"

echo "==> Instalando o SDDM e o que o tema precisa (vídeo e teclado virtual)..."
sudo pacman -S --needed sddm qt6-svg qt6-multimedia qt6-virtualkeyboard
yay -S --needed bibata-cursor-theme-bin

echo "==> Baixando o SilentSDDM (versão $VERSAO)..."
tmp=$(mktemp -d)
git clone -q https://github.com/uiriansan/SilentSDDM.git "$tmp/silent"
git -C "$tmp/silent" checkout -q "$VERSAO"
rm -rf "$tmp/silent/.git"

echo "==> Colocando a configuração e o papel de parede..."
cp silent-muzan.conf "$tmp/silent/configs/muzan.conf"
sed -i -E 's|^ConfigFile=.*|ConfigFile=configs/muzan.conf|' "$tmp/silent/metadata.desktop"
# Usa o mesmo papel de parede do Hyprland: imagem (preferida) ou vídeo
IMAGEM=""
for ext in jpg jpeg png webp; do
    [ -f "$PASTA/wallpaper.$ext" ] && { IMAGEM="$PASTA/wallpaper.$ext"; break; }
done
conf="$tmp/silent/configs/muzan.conf"
if [ -n "$IMAGEM" ]; then
    fundo="muzan.${IMAGEM##*.}"
    cp "$IMAGEM" "$tmp/silent/backgrounds/$fundo"
    sed -i "s/\"muzan.mp4\"/\"$fundo\"/g; s/^animated-background-placeholder = .*/animated-background-placeholder = \"\"/" "$conf"
elif [ -f "$VIDEO" ]; then
    cp "$VIDEO" "$tmp/silent/backgrounds/muzan.mp4"
    ffmpeg -y -loglevel error -ss 1 -i "$VIDEO" -frames:v 1 "$tmp/silent/backgrounds/muzan.png"
else
    echo "    (sem papel de parede em $PASTA — fica a imagem padrão do tema)"
    sed -i 's/"muzan.mp4"/"smoky.jpg"/g; s/"muzan.png"/""/' "$conf"
fi

echo "==> Instalando em $DESTINO..."
sudo rm -rf "$DESTINO"
sudo cp -r "$tmp/silent" "$DESTINO"
sudo chmod -R a+rX "$DESTINO"
sudo install -Dm644 tema.conf /etc/sddm.conf.d/tema.conf
rm -rf "$tmp"

echo "==> Ativando o SDDM como tela de login..."
sudo systemctl disable display-manager.service 2>/dev/null || true
sudo systemctl enable sddm

echo
echo "Pronto! A nova tela de login aparece na próxima vez que ligar o computador."
