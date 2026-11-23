-- =============================================================
--  economia.lua — modo economia de bateria
-- =============================================================
--  Liga/desliga com Super + Shift + B (ou clicando na folha da barra).
--  O script scripts/modo-economia.sh cria ou apaga o arquivo
--  ~/.cache/hypr-economia e recarrega o Hyprland. Este arquivo só
--  verifica se ele existe e, se existir, deixa o visual mais leve.
--
--  O resto do modo economia (perfil de energia, Bluetooth) fica no script.
-- =============================================================

-- 1) Detecta se o modo está ligado (variável global, usada em hyprland.lua para os 60 Hz)
local arquivo = io.open(os.getenv("HOME") .. "/.cache/hypr-economia", "r")
economia = arquivo ~= nil
if arquivo then arquivo:close() end

-- 2) Desliga os efeitos visuais. É chamada no FIM do hyprland.lua,
--    depois do aparencia.lua, para não ser sobrescrita por ele.
function aplicar_economia()
    if not economia then return end
    hl.config({
        decoration = {
            blur   = { enabled = false }, -- sem desfoque
            shadow = { enabled = false }, -- sem sombras
            wobble = { enabled = false }, -- sem janelas "gelatinosas"
            inactive_opacity = 1.0,       -- sem transparência
        },
        animations = { enabled = false }, -- sem animações
    })
end
