-- =============================================================
--  efeitos.lua — efeitos especiais do tema Muzan
-- =============================================================
--  1) Aura vermelha: atrás das janelas transparentes (terminal, menu,
--     barra) o desfoque vira uma "aurora" carmesim que se move devagar.
--  2) Pulso de sangue: quando um app abre, a borda dele acende em brasa
--     quase branca e vai "esfriando" até o carmesim normal.
--  (O "olho abrindo" fica em aparencia.lua, na animação windowsIn.)
--
--  Tudo isso é desligado no modo economia (Super + Shift + B).
-- =============================================================

if economia then return end

-- ---------- 1) Aura vermelha ----------
-- Variantes de desfoque do Hyprland 0.57 (número → nome):
--   0 kawase (normal) | 1 frost | 2 ripple | 3 drops | 4 water | 5 fluid_jar
--   6 prism | 7 heat_shimmer | 8 acrylic | 9 aurora | 10 haze
hl.config({
    decoration = {
        blur = {
            variant = 9, -- aurora
            aurora = {
                color1    = "rgba(e3123b99)", -- carmesim (alpha = quanto aparece)
                color2    = "rgba(ff7b5c66)", -- brasa
                intensity = 0.6,              -- força da cor
                speed     = 0.3,              -- velocidade do movimento (0 = parado)
            },
        },
    },
})

-- ---------- 2) Pulso de sangue ao abrir um app ----------
-- A borda passa por 3 cores, uma depois da outra:
--   brasa quase branca → brasa → volta ao normal (carmesim girando).
-- A transição entre elas é suave por causa da animação "border" (aparencia.lua).
local function cor_da_borda(endereco, cor)
    pcall(hl.dispatch, hl.dsp.window.set_prop({
        prop = "active_border_color", value = cor, window = "address:" .. endereco,
    }))
end

hl.on("window.open", function(janela)
    if not janela or not janela.address then return end
    local endereco = janela.address

    cor_da_borda(endereco, "rgba(ffd9c7ff) rgba(ff7b5cff) 45deg")   -- acende
    hl.timer(function()
        cor_da_borda(endereco, "rgba(ff7b5cff) rgba(e3123bff) 45deg") -- esfria
    end, { timeout = 250, type = "oneshot" })
    hl.timer(function()
        cor_da_borda(endereco, "unset")                              -- volta ao normal
    end, { timeout = 700, type = "oneshot" })
end)
