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
--   Para trocar sem editar: Super + P (ou o botão 🖥 na barra)

-- Posição escolhida no menu de telas (Super + P → scripts/telas.sh), salva em
-- ~/.local/state/hypr/telas: cima | baixo | esquerda | direita | espelhar |
-- so-notebook | so-monitor. Sem arquivo = monitor em cima.
local arquivo_telas = io.open(os.getenv("HOME") .. "/.local/state/hypr/telas", "r")
telas = arquivo_telas and arquivo_telas:read("l") or "cima"
if arquivo_telas then arquivo_telas:close() end

-- posição de cada tela em cada opção (as duas têm 1920x1080)
local posicoes = {
    cima     = { notebook = "0x1080", monitor = "0x0" },
    baixo    = { notebook = "0x0",    monitor = "0x1080" },
    esquerda = { notebook = "1920x0", monitor = "0x0" },
    direita  = { notebook = "0x0",    monitor = "1920x0" },
}
local pos = posicoes[telas] or posicoes.cima

-- Tela do notebook (15,6", 1920x1080 a 144 Hz)
-- No modo economia cai para 60 Hz (gasta bem menos bateria)
hl.monitor({
    output   = "eDP-1",
    mode     = economia and "1920x1080@60" or "1920x1080@144",
    position = pos.notebook,
    scale    = 1,
    disabled = (telas == "so-monitor"),
})

-- Monitor externo (LG UltraGear).
-- Identificado pelo MODELO ("desc:"), não pela porta: vale no HDMI, no
-- DisplayPort ou no USB-C. Para ver a descrição: hyprctl monitors
hl.monitor({
    output   = "desc:LG Electronics LG ULTRAGEAR",
    mode     = "1920x1080@144",
    position = pos.monitor,
    scale    = 1,
    disabled = (telas == "so-notebook"),
    mirror   = (telas == "espelhar") and "eDP-1" or nil,
})

-- Proteção: com "só o monitor", se o monitor for desconectado a tela do
-- notebook volta sozinha (para nunca ficar tudo preto)
-- (desligar a própria tela do notebook também conta como "monitor removido",
--  por isso confere se SOBROU algum monitor externo antes de agir)
if telas == "so-monitor" then
    hl.on("monitor.removed", function()
        local sobrou_externo = false
        for _, m in ipairs(hl.get_monitors() or {}) do
            if not tostring(m.name):match("^eDP") then sobrou_externo = true end
        end
        if not sobrou_externo then
            hl.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/telas.sh cima")
        end
    end)
end

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
