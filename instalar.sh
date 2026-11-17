#!/usr/bin/env bash
# =============================================================
#  instalar.sh — instala os pacotes e liga as configurações
# =============================================================
#  1) instala tudo de pacotes.txt com o pacman
#  2) faz backup de configs que já existam (.bak)
#  3) cria os links de ~/.config para este repositório com o stow
# =============================================================
set -euo pipefail

cd "$(dirname "$0")"
PASTAS=(hypr waybar rofi mako kitty swappy)

echo "==> Instalando pacotes..."
grep -vE '^\s*(#|$)' pacotes.txt | sudo pacman -S --needed -

echo "==> Fazendo backup de configurações que já existem..."
for pasta in "${PASTAS[@]}"; do
    for alvo in "$pasta"/.config/*; do
        destino="$HOME/.config/$(basename "$alvo")"
        if [ -e "$destino" ] && [ ! -L "$destino" ]; then
            mv -v "$destino" "$destino.bak"
        fi
    done
done

echo "==> Criando os links com o stow..."
mkdir -p "$HOME/.config"
stow -v -t "$HOME" "${PASTAS[@]}"

echo
echo "Pronto! Saia da sessão e escolha 'Hyprland (uwsm-managed)' na tela de login."
