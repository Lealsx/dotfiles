-- =============================================================
--  aparencia.lua — visual (tema Muzan (Demon Slayer): preto, carmesim e brasa)
-- =============================================================
--  Paleta "Muzan" (Demon Slayer), tirada do papel de parede:
--    carmesim #e3123b   brasa (olho) #ff7b5c   preto #0a0608
--    cinza    #2e1a1f   (borda das janelas sem foco)
-- =============================================================

hl.config({
    general = {
        gaps_in     = 4,   -- espaço entre janelas
        gaps_out    = 10,  -- espaço entre janelas e a borda da tela
        border_size = 2,

        col = {
            -- Borda da janela com foco: degradê carmesim → brasa (o brilho do olho do Muzan)
            -- (passa por um vermelho bem escuro: ao girar, parece sangue escorrendo)
            active_border   = { colors = { "rgba(e3123bee)", "rgba(ff7b5cee)", "rgba(5c0a1aee)" }, angle = 45 },
            inactive_border = "rgba(2e1a1faa)",
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
            range          = 14,
            render_power   = 3,
            color          = 0x66e3123b, -- janela com foco: brilho vermelho em volta
            color_inactive = 0xaa000000, -- outras janelas: sombra preta comum
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
hl.curve("sinistra",     { type = "bezier", points = { {0.16, 1},    {0.3, 1}    } }) -- dispara e desacelera BEM devagar
hl.curve("corte",        { type = "bezier", points = { {0.7, 0},     {0.84, 0}   } }) -- começa lento e termina num golpe
hl.curve("linear",       { type = "bezier", points = { {0, 0},       {1, 1}      } }) -- velocidade constante
hl.curve("quick",        { type = "bezier", points = { {0.15, 0},    {0.1, 1}    } })
hl.curve("pesada",       { type = "spring", mass = 1.4, stiffness = 180, damping = 30 }) -- mola pesada, sem quicar

-- Janelas (tema Muzan: dramático e sinistro, nada de "pulinho"):
--   abrir  → surge como uma linha fina e se abre na vertical, como um OLHO abrindo ("gnomed")
--   fechar → achata até virar uma linha, como uma pálpebra fechando ("gnomed")
--   mover  → desliza pesada, sem quicar
hl.animation({ leaf = "global",      enabled = true, speed = 10,  bezier = "default" })
hl.animation({ leaf = "windows",     enabled = true, speed = 5,   spring = "pesada" })
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 6,   bezier = "sinistra", style = "gnomed" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 3,   bezier = "corte",    style = "gnomed" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 5,   spring = "pesada" })
hl.animation({ leaf = "fade",        enabled = true, speed = 4,   bezier = "sinistra" })
hl.animation({ leaf = "fadeIn",      enabled = true, speed = 6,   bezier = "sinistra" })
hl.animation({ leaf = "fadeOut",     enabled = true, speed = 3,   bezier = "corte" })

-- Borda da janela ativa: a cor muda suave e o degradê carmesim → brasa → vermelho-escuro
-- GIRA devagar (uma volta a cada 6 s; speed 60 = 60 décimos de segundo)
hl.animation({ leaf = "border",      enabled = true, speed = 5,   bezier = "easeOutQuint" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 60,  bezier = "linear", style = "loop" })

-- Menus, barra e notificações ("layers"): surgem com fade, sem quicar
hl.animation({ leaf = "layers",      enabled = true, speed = 4,   bezier = "sinistra" })
hl.animation({ leaf = "layersIn",    enabled = true, speed = 4,   bezier = "sinistra", style = "popin 90%" })
hl.animation({ leaf = "layersOut",   enabled = true, speed = 2,   bezier = "corte",    style = "fade" })

-- Áreas de trabalho: deslizam com fade (como névoa passando); o rascunho desce de cima
hl.animation({ leaf = "workspaces",       enabled = true, speed = 6, bezier = "sinistra", style = "slidefade 30%" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 6, bezier = "sinistra", style = "slidefadevert 30%" })

-- Janelas "gelatinosas" (novo na 0.57): balançam ao arrastar ou redimensionar
hl.config({
    decoration = {
        wobble = {
            enabled   = true,
            intensity = 0.12, -- quanto balança (0 = nada); baixo = mais "pesado"
            stiffness = 200,  -- firmeza da "gelatina"
            damping   = 12,   -- quanto tempo demora para parar
        },
    },
})

-- Animação própria de cada menu (regras de "layer", por nome)
hl.layer_rule({ name = "anim-rofi",         match = { namespace = "^rofi$" },          animation = "popin 90%" })
hl.layer_rule({ name = "anim-notificacoes", match = { namespace = "^notifications$" }, animation = "slide right" })
hl.layer_rule({ name = "anim-bloqueio",     match = { namespace = "^hyprlock$" },      animation = "fade" })

-- Desfoque atrás da barra e do menu (os fundos deles são semitransparentes)
hl.layer_rule({ name = "blur-waybar", match = { namespace = "^waybar$" }, blur = true, ignore_alpha = 0.3 })
hl.layer_rule({ name = "blur-rofi",   match = { namespace = "^rofi$" },   blur = true, ignore_alpha = 0.3 })
