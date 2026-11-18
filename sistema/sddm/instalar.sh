#!/usr/bin/env bash
# =============================================================
#  sistema/sddm/instalar.sh — tela de login (SDDM) com tema Catppuccin
# =============================================================
#  Estes arquivos ficam FORA da pasta pessoal (em /etc e /usr/share),
#  por isso não são ligados pelo stow — são COPIADOS com sudo.
#
#    tema.conf        → /etc/sddm.conf.d/tema.conf
#                       diz ao SDDM qual tema usar
#    theme.conf.user  → /usr/share/sddm/themes/catppuccin-mocha-blue/theme.conf.user
#                       ajustes pessoais do tema (fonte JetBrainsMono, tamanho 12)
#
#  Precisa do yay (o tema vem do AUR).
# =============================================================
set -euo pipefail
cd "$(dirname "$0")"

TEMA=/usr/share/sddm/themes/catppuccin-mocha-blue

echo "==> Instalando o SDDM e o tema Catppuccin Mocha..."
sudo pacman -S --needed sddm
yay -S --needed catppuccin-sddm-theme-mocha

echo "==> Copiando as configurações..."
sudo install -Dm644 tema.conf       /etc/sddm.conf.d/tema.conf
sudo install -Dm644 theme.conf.user "$TEMA/theme.conf.user"

echo "==> Ativando o SDDM como tela de login..."
# Desativa outra tela de login que esteja ativa (ex.: GDM do GNOME)
sudo systemctl disable display-manager.service 2>/dev/null || true
sudo systemctl enable sddm

echo
echo "Pronto! Reinicie para ver a nova tela de login."
echo "Prévia sem reiniciar: sddm-greeter-qt6 --test-mode --theme $TEMA"
