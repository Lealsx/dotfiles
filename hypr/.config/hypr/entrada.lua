-- =============================================================
--  entrada.lua — teclado, touchpad e gestos
-- =============================================================

hl.config({
    input = {
        -- Dois layouts, na ordem:
        --   1) us  + intl → teclado inglês com acentos (' + a = á, AltGr + , = ç)
        --   2) br  (sem variante) → teclado português ABNT2
        -- Trocar entre eles: Super + Espaço (ver atalhos.lua)
        kb_layout  = "us,br",
        kb_variant = "intl,",
        kb_model   = "",
        kb_options = "",

        numlock_by_default = true,
        follow_mouse = 1, -- o foco vai para a janela debaixo do mouse

        touchpad = {
            natural_scroll       = true, -- rolar igual celular (como no GNOME)
            tap_to_click         = true, -- toque leve = clique
            disable_while_typing = true,
        },
    },
})

-- Gesto: 3 dedos para os lados no touchpad troca de área de trabalho
hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})
