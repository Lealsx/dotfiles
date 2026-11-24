#!/usr/bin/env bash
# =============================================================
#  visualizador.sh — barrinhas que dançam com a música (Waybar)
# =============================================================
#  Roda o cava e converte os números 0–7 em ▁▂▃▄▅▆▇█.
#  - Sem som tocando → barrinhas paradas no chão (▁▁▁▁)
#  - Modo economia ligado → para o cava e deixa as barrinhas paradas
#  - cava não instalado → não mostra nada
# =============================================================

config="$HOME/.config/waybar/cava.conf"
economia="$HOME/.cache/hypr-economia"
# barrinhas paradas (uma ▁ para cada barra do cava.conf)
barras=$(sed -n 's/^bars *= *//p' "$config")
parado=$(printf '▁%.0s' $(seq "${barras:-10}"))

command -v cava >/dev/null || { echo ""; exec sleep infinity; }

while true; do
    if [ -e "$economia" ]; then
        echo "$parado"     # barrinhas paradas, cava desligado
        sleep 5
        continue
    fi

    # awk lê cada quadro do cava (ex.: "0;3;5;7;2;...")
    cava -p "$config" | awk -v marcador="$economia" '
        BEGIN { split("▁▂▃▄▅▆▇█", blocos, ""); quadros = 0 }
        {
            # a cada ~2 s, confere se o modo economia foi ligado
            if (++quadros % 60 == 0 && system("test -e \"" marcador "\"") == 0) exit

            gsub(/;$/, "")
            n = split($0, alturas, ";")
            linha = ""
            for (i = 1; i <= n; i++) {
                linha = linha blocos[alturas[i] + 1]
            }
            print linha
            fflush()
        }'
done
