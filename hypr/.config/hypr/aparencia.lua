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

-- =============================================================
--  Animações
-- =============================================================
--  "curve" = o jeito que o movimento acelera/desacelera:
--    bezier → curva fixa (ex.: começa rápido e freia no fim)
--    spring → mola: quanto MENOR o damping, mais a janela "quica"
--  "speed" = duração em décimos de segundo (5 = meio segundo)
--  No modo economia (Super + Shift + B) tudo isso é desligado.
-- =============================================================

-- Curvas
hl.curve("easeOutQuint", { type = "bezier", points = { {0.23, 1},    {0.32, 1}   } }) -- freia suave no fim
hl.curve("overshot",     { type = "bezier", points = { {0.05, 0.9},  {0.1, 1.1}  } }) -- passa um pouco do ponto e volta
hl.curve("linear",       { type = "bezier", points = { {0, 0},       {1, 1}      } }) -- velocidade constante
hl.curve("almostLinear", { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}   } })
hl.curve("quick",        { type = "bezier", points = { {0.15, 0},    {0.1, 1}    } })
hl.curve("easy",         { type = "spring", mass = 1, stiffness = 238, damping = 24 }) -- mola firme (sem quicar)
hl.curve("bouncy",       { type = "spring", mass = 1, stiffness = 260, damping = 15 }) -- mola com "pulinho"

-- Janelas: abrem crescendo com um pulinho, fecham encolhendo rápido,
-- e deslizam com mola quando mudam de lugar
hl.animation({ leaf = "global",      enabled = true, speed = 10,  bezier = "default" })
hl.animation({ leaf = "windows",     enabled = true, speed = 5,   spring = "bouncy" })
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 4.5, spring = "bouncy", style = "popin 70%" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 2,   bezier = "easeOutQuint", style = "popin 80%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 5,   spring = "bouncy" })
hl.animation({ leaf = "fade",        enabled = true, speed = 3,   bezier = "quick" })

-- Borda da janela ativa: a cor muda suave e o degradê azul → lilás GIRA devagar
-- (borderangle + "loop" = uma volta completa a cada 10 s)
hl.animation({ leaf = "border",      enabled = true, speed = 5,   bezier = "easeOutQuint" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 100, bezier = "linear", style = "loop" })

-- Menus, barra e notificações ("layers")
hl.animation({ leaf = "layers",      enabled = true, speed = 4,   bezier = "overshot" })
hl.animation({ leaf = "layersIn",    enabled = true, speed = 4,   bezier = "overshot",     style = "popin 85%" })
hl.animation({ leaf = "layersOut",   enabled = true, speed = 2,   bezier = "easeOutQuint", style = "fade" })

-- Áreas de trabalho: deslizam para o lado; o rascunho (Super + S) desce de cima
hl.animation({ leaf = "workspaces",       enabled = true, speed = 4, bezier = "easeOutQuint", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 4, bezier = "easeOutQuint", style = "slidevert" })

-- Janelas "gelatinosas" (novo na 0.57): balançam ao arrastar ou redimensionar
hl.config({
    decoration = {
        wobble = {
            enabled   = true,
            intensity = 0.25, -- quanto balança (0 = nada)
            stiffness = 200,  -- firmeza da "gelatina"
            damping   = 12,   -- quanto tempo demora para parar
        },
    },
})

-- Animação própria de cada menu (regras de "layer", por nome)
hl.layer_rule({ name = "anim-rofi",         match = { namespace = "^rofi$" },          animation = "popin 85%" })
hl.layer_rule({ name = "anim-notificacoes", match = { namespace = "^notifications$" }, animation = "slide right" })
hl.layer_rule({ name = "anim-bloqueio",     match = { namespace = "^hyprlock$" },      animation = "fade" })

-- Desfoque atrás da barra e do menu (os fundos deles são semitransparentes)
hl.layer_rule({ name = "blur-waybar", match = { namespace = "^waybar$" }, blur = true, ignore_alpha = 0.3 })
hl.layer_rule({ name = "blur-rofi",   match = { namespace = "^rofi$" },   blur = true, ignore_alpha = 0.3 })
