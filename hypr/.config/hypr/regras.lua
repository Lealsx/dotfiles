-- =============================================================
--  regras.lua — regras para janelas específicas
-- =============================================================
--  Para descobrir a "class" de uma janela: hyprctl clients
-- =============================================================

-- Ignora pedidos de "maximizar" vindos dos apps (no tiling quem manda é o Hyprland)
hl.window_rule({
    name  = "ignorar-maximizar",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Janelas pequenas de configuração abrem flutuando (soltas), não encaixadas
hl.window_rule({
    name  = "flutuar-utilitarios",
    match = { class = "^(org.pulseaudio.pavucontrol|blueman-manager|nm-connection-editor|nwg-look|org.gnome.Calculator)$" },
    float = true,
})

-- Janela de "escolher arquivo" e diálogos de senha flutuando
hl.window_rule({
    name  = "flutuar-dialogos",
    match = { title = "^(Abrir arquivo|Salvar arquivo|Open File|Save File|Authentication Required)(.*)$" },
    float = true,
})

-- Corrige arrastar janelas de apps X11 antigos (recomendado pelo Hyprland)
hl.window_rule({
    name  = "corrigir-arrastar-xwayland",
    match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
    no_focus = true,
})
