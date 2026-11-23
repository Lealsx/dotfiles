#!/usr/bin/env bash
# =============================================================
#  visualizador.sh — barrinhas que dançam com a música (Waybar)
# =============================================================
#  Roda o cava e converte os números 0–7 em ▁▂▃▄▅▆▇█.
#  - Sem som tocando → não mostra nada (o módulo some da barra)
#  - Modo economia ligado → para o cava e não mostra nada
#  - cava não instalado → não mostra nada
# =============================================================

config="$HOME/.config/waybar/cava.conf"
economia="$HOME/.cache/hypr-economia"

command -v cava >/dev/null || { echo ""; exec sleep infinity; }

while true; do
    if [ -e "$economia" ]; then
        echo ""            # esconde o módulo
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
            linha = ""; silencio = 1
            for (i = 1; i <= n; i++) {
                linha = linha blocos[alturas[i] + 1]
                if (alturas[i] > 0) silencio = 0
            }
            print (silencio ? "" : linha)
            fflush()
        }'
done
