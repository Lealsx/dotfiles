-- =============================================================
--  aparencia.lua — visual (tema escuro estilo Catppuccin Mocha)
-- =============================================================
--  Cores Catppuccin Mocha usadas aqui:
--    azul    #89b4fa   lilás   #cba6f7   fundo  #1e1e2e
--    cinza   #45475a   (borda das janelas sem foco)
-- =============================================================

hl.config({
    general = {
        gaps_in     = 4,   -- espaço entre janelas
        gaps_out    = 10,  -- espaço entre janelas e a borda da tela
        border_size = 2,

        col = {
            -- Borda da janela com foco: degradê azul → lilás
            active_border   = { colors = { "rgba(89b4faee)", "rgba(cba6f7ee)" }, angle = 45 },
            inactive_border = "rgba(45475aaa)",
        },

        resize_on_border = true,      -- redimensionar arrastando a borda
        layout           = "dwindle", -- janelas se dividem em espiral
    },

    decoration = {
        rounding = 10, -- cantos arredondados

        active_opacity   = 1.0,
        inactive_opacity = 0.95, -- janelas sem foco levemente transparentes

        shadow = {
            enabled      = true,
            range        = 8,
            render_power = 3,
            color        = 0xee11111b,
        },

        -- Desfoque atrás de janelas transparentes (gasta um pouco mais de bateria;
        -- para desligar: enabled = false)
        blur = {
            enabled  = true,
            size     = 6,
            passes   = 2,
            vibrancy = 0.17,
        },
    },

    animations = { enabled = true },

    dwindle = { preserve_split = true },

    misc = {
        force_default_wallpaper = 0,    -- sem papel de parede padrão (usamos o hyprpaper)
        disable_hyprland_logo   = true,
        disable_splash_rendering = true,
    },
})

-- Curvas e animações (rápidas e suaves)
hl.curve("easeOutQuint", { type = "bezier", points = { {0.23, 1},  {0.32, 1} } })
hl.curve("linear",       { type = "bezier", points = { {0, 0},     {1, 1}    } })
hl.curve("almostLinear", { type = "bezier", points = { {0.5, 0.5}, {0.75, 1} } })
hl.curve("quick",        { type = "bezier", points = { {0.15, 0},  {0.1, 1}  } })
hl.curve("easy",         { type = "spring", mass = 1, stiffness = 238.1191, damping = 24.21279333 })

hl.animation({ leaf = "global",     enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",     enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",    enabled = true, speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn",  enabled = true, speed = 4.1,  spring = "easy",   style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fade",       enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",     enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "slide" })
