#!/usr/bin/env bash
# =============================================================
#  instalar.sh — instala os pacotes e liga as configurações
# =============================================================
#  1) instala tudo de pacotes.txt com o pacman
#  2) faz backup de configs que já existam (.bak)
#  3) cria os links de ~/.config para este repositório com o stow
# =============================================================
set -euo pipefail
shopt -s nullglob   # pastas sem .config (ex.: icones) não quebram o loop

cd "$(dirname "$0")"
PASTAS=(hypr waybar rofi mako kitty swappy icones matugen)

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

echo "==> Cores iniciais (tema Muzan) para o tema musical..."
for par in hypr/.config/hypr/cores-muzan.lua:- \
           waybar/.config/waybar/cores-muzan.css:waybar/.config/waybar/cores.css \
           rofi/.config/rofi/cores-muzan.rasi:rofi/.config/rofi/cores.rasi \
           kitty/.config/kitty/cores-muzan.conf:kitty/.config/kitty/cores.conf \
           mako/.config/mako/cores-muzan:mako/.config/mako/cores; do
    destino="${par#*:}"
    [ "$destino" = "-" ] && continue     # o Hyprland usa o cores-muzan.lua sozinho
    [ -f "$destino" ] || cp "${par%%:*}" "$destino"
done

echo
echo "Pronto! Saia da sessão e escolha 'Hyprland (uwsm-managed)' na tela de login."
