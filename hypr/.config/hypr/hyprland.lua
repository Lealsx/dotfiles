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
--    economia.lua   → modo economia de bateria (Super + Shift + B)
--    efeitos.lua    → pulso de sangue ao abrir apps e pausa inteligente do vídeo
--
--  Documentação oficial: https://wiki.hypr.land/configuring/
--  Para checar erros sem reiniciar:  Hyprland --verify-config
-- =============================================================

-- Modo economia de bateria (precisa vir antes dos monitores: usa 60 Hz quando ligado)
require("economia")

-- ---------- Monitores ----------
-- Para ver os nomes, resoluções e posições: hyprctl monitors
--   scale    → tamanho de tudo na tela (1 = normal, 1.25 = 25% maior...)
--   position → onde a tela fica, em pixels ("X x Y"; Y cresce para BAIXO):
--              "0x0" = em cima | "0x1080" = embaixo de uma tela de 1080 de altura

-- Tela do notebook (15,6", 1920x1080 a 144 Hz) — fica EMBAIXO do monitor externo
-- No modo economia cai para 60 Hz (gasta bem menos bateria)
hl.monitor({
    output   = "eDP-1",
    mode     = economia and "1920x1080@60" or "1920x1080@144",
    position = "0x1080",
    scale    = 1,
})

-- Monitor externo (LG UltraGear) — fica EM CIMA do notebook.
-- Identificado pelo MODELO ("desc:"), não pela porta: vale no HDMI, no
-- DisplayPort ou no USB-C. Para ver a descrição: hyprctl monitors
hl.monitor({
    output   = "desc:LG Electronics LG ULTRAGEAR",
    mode     = "1920x1080@144",
    position = "0x0",
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

-- Modo economia: desliga os efeitos por último, para valer por cima do aparencia.lua
aplicar_economia()

-- Efeitos do tema Muzan (pulso de sangue ao abrir apps, pausa inteligente do vídeo)
require("efeitos")
