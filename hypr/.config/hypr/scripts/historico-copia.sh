#!/usr/bin/env bash
# =============================================================
#  historico-copia.sh — mostra tudo que você copiou (Ctrl+C)
#  e coloca o item escolhido de volta para colar.
#  Atalho: Super + Shift + V
# =============================================================

cliphist list | rofi -dmenu -i -p "Copiados" | cliphist decode | wl-copy
