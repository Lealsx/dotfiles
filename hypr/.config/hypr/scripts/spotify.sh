#!/usr/bin/env bash
# =============================================================
#  spotify.sh — integração do Spotify com a barra (Waybar)
# =============================================================
#    spotify.sh status → fica "escutando" o Spotify e avisa a barra
#                        sempre que a música muda (usado pelo Waybar)
#    spotify.sh abrir  → se o Spotify estiver aberto, traz a janela
#                        para a frente; se não, abre o Spotify
#
#  Usa o playerctl, que conversa com os players pelo padrão MPRIS.
# =============================================================

# Deixa o texto seguro para a barra (JSON + marcação do Pango)
escapar() {
    local t="$1"
    t=${t//&/&amp;}; t=${t//</&lt;}; t=${t//>/&gt;}
    t=${t//\\/\\\\}; t=${t//\"/\\\"}
    t=${t//$'\n'/\\n}   # quebra de linha vira \n (o JSON precisa ser uma linha só)
    printf '%s' "$t"
}

# Imprime uma linha JSON para o Waybar: texto, dica (tooltip) e classe (para a cor)
mostrar() {
    printf '{"text": "%s", "tooltip": "%s", "class": "%s"}\n' \
        "$(escapar "$1")" "$(escapar "$2")" "$3"
}

case "$1" in
    status)
        mostrar "Spotify" "Clique para abrir o Spotify" "fechado"
        # --follow: o playerctl continua rodando e imprime uma linha nova
        # a cada mudança (música, play/pause, Spotify abriu/fechou)
        playerctl --player=spotify --follow metadata \
            --format '{{status}}|{{artist}}|{{title}}|{{album}}' 2>/dev/null |
        while IFS='|' read -r estado artista musica album; do
            if [ -z "$estado" ]; then
                mostrar "Spotify" "Clique para abrir o Spotify" "fechado"
                continue
            fi
            texto="$musica"
            [ -n "$artista" ] && texto="$musica · $artista"
            (( ${#texto} > 40 )) && texto="${texto:0:39}…"   # corta textos longos
            if [ "$estado" = "Playing" ]; then
                dica="$musica"$'\n'"$artista — $album"
                if [ "$musica" != "$anterior" ] && [ -n "$anterior" ]; then
                    # música nova: classe "nova" por 2,5 s → o CSS faz um flash
                    # (animação que roda uma vez só; não pesa)
                    mostrar "$texto" "$dica" "tocando nova"
                    ( sleep 2.5; mostrar "$texto" "$dica" "tocando" ) &
                else
                    mostrar "$texto" "$dica" "tocando"
                fi
                anterior="$musica"
            else
                mostrar "$texto" "Pausado: $musica"$'\n'"$artista — $album" "pausado"
            fi
        done
        ;;

    abrir)
        if pgrep -x spotify >/dev/null; then
            hyprctl dispatch 'hl.dsp.focus({ window = "class:^([Ss]potify)$" })' >/dev/null
        else
            hyprctl dispatch 'hl.dsp.exec_cmd("spotify-launcher")' >/dev/null
        fi
        ;;
esac
