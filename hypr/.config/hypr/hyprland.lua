-- =============================================================
--  hyprland.lua — arquivo principal do Hyprland (versão 0.57+)
-- =============================================================
--  A partir da versão 0.57 o Hyprland é configurado em Lua.
--  Este arquivo só carrega as outras partes, cada uma num arquivo:
--
--    programas.lua  → quais apps uso (terminal, navegador, etc.)
--    ambiente.lua   → variáveis de ambiente (Wayland, cursor, Qt...)
--    inicio.lua     → o que abre sozinho quando o Hyprland inicia
--    aparencia.lua  → bordas, cores, cantos, desfoque, animações
--    entrada.lua    → teclado (US intl + ABNT2), touchpad, gestos
--    atalhos.lua    → todos os atalhos de teclado
--    regras.lua     → regras para janelas específicas
--
--  Documentação oficial: https://wiki.hypr.land/configuring/
--  Para checar erros sem reiniciar:  Hyprland --verify-config
-- =============================================================

-- ---------- Monitores ----------
-- Para ver os nomes, resoluções e posições: hyprctl monitors
--   scale    → tamanho de tudo na tela (1 = normal, 1.25 = 25% maior...)
--   position → onde a tela fica, em pixels; "1920x0" = à direita de uma tela de 1920 de largura

-- Tela do notebook (15,6", 1920x1080 a 144 Hz) — fica à esquerda
hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1080@144",
    position = "0x0",
    scale    = 1,
})

-- Monitor externo (cabo DisplayPort/USB-C) — fica à direita do notebook
hl.monitor({
    output   = "DP-2",
    mode     = "1920x1080@144",
    position = "1920x0",
    scale    = 1,
})

-- Qualquer outro monitor que for ligado (ex.: um projetor): automático, à direita
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto-right",
    scale    = 1,
})

require("programas")
require("ambiente")
require("inicio")
require("aparencia")
require("entrada")
require("atalhos")
require("regras")
