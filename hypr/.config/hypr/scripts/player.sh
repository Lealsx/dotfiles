#!/usr/bin/env bash
# =============================================================
#  player.sh — o que está tocando FORA do Spotify (Waybar)
# =============================================================
#  YouTube no Brave, VLC, etc. O Spotify tem o próprio módulo
#  (spotify.sh), então aqui ele é ignorado.
#  Sem nada tocando ou pausado → texto vazio → o módulo some.
#  A barra chama este script a cada 2 segundos.
# =============================================================

escapar() {
    local t="$1"
    t=${t//&/&amp;}; t=${t//</&lt;}; t=${t//>/&gt;}
    t=${t//\\/\\\\}; t=${t//\"/\\\"}; t=${t//$'\n'/\\n}
    printf '%s' "$t"
}

for player in $(playerctl -l 2>/dev/null); do
    [[ "$player" == spotify* ]] && continue

    estado=$(playerctl -p "$player" status 2>/dev/null)
    titulo=$(playerctl -p "$player" metadata title 2>/dev/null)
    [[ "$estado" == "Stopped" || -z "$titulo" ]] && continue

    artista=$(playerctl -p "$player" metadata artist 2>/dev/null)
    texto="$titulo"; [ -n "$artista" ] && texto="$titulo · $artista"
    (( ${#texto} > 40 )) && texto="${texto:0:39}…"

    # ícone: navegador ou música genérica
    case "$player" in
        brave*|chromium*|firefox*) icone=$'' ;;
        *)                         icone=$'' ;;
    esac
    classe=$([ "$estado" = "Playing" ] && echo tocando || echo pausado)

    printf '{"text": "%s %s", "tooltip": "%s", "class": "%s"}\n' \
        "$icone" "$(escapar "$texto")" "$(escapar "${player%%.*}: $titulo")" "$classe"
    exit 0
done

echo '{"text": ""}'   # nada tocando → esconde
