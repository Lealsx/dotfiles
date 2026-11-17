#!/usr/bin/env bash
# =============================================================
#  atalhos.sh — mostra todos os atalhos com busca (Super + F1)
# =============================================================
#  Lê os atalhos direto do Hyprland (hyprctl binds), então a lista
#  está sempre atualizada. Digite para filtrar; Esc fecha.
# =============================================================

# Se a lista já estiver aberta, fecha (apertar Super + F1 de novo fecha)
pkill -x rofi && exit 0

lista=$(hyprctl binds -j | python3 -c '
import sys, json

# modmask é um número; cada bit é uma tecla modificadora
MODS = [(64, "Super"), (4, "Ctrl"), (8, "Alt"), (1, "Shift")]
NOMES = {
    "RETURN": "Enter", "SPACE": "Espaço", "ESCAPE": "Esc", "TAB": "Tab",
    "left": "←", "right": "→", "up": "↑", "down": "↓",
    "mouse:272": "arrastar (esquerdo)", "mouse:273": "arrastar (direito)",
    "mouse_down": "rolar ↓", "mouse_up": "rolar ↑",
    "XF86AudioRaiseVolume": "Volume +", "XF86AudioLowerVolume": "Volume −",
    "XF86AudioMute": "Mudo", "XF86AudioMicMute": "Mic mudo",
    "XF86MonBrightnessUp": "Brilho +", "XF86MonBrightnessDown": "Brilho −",
    "XF86AudioPlay": "Play", "XF86AudioPause": "Pause",
    "XF86AudioNext": "Próxima", "XF86AudioPrev": "Anterior",
}

vistos = set()
for b in json.load(sys.stdin):
    desc = b.get("description", "")
    if not desc:
        continue
    teclas = [nome for bit, nome in MODS if b["modmask"] & bit]
    teclas.append(NOMES.get(b["key"], b["key"]))
    combo = " + ".join(teclas)
    linha = f"{combo:<30} {desc}"
    if linha not in vistos:          # tecla Play/Pause repetida, etc.
        vistos.add(linha)
        print(linha)
')

echo "$lista" | rofi -dmenu -i -p "Atalhos" -no-custom \
    -theme-str 'window {width: 820px;} listview {lines: 14;} element-text {font: "JetBrainsMono Nerd Font 11";}' >/dev/null
