-- =============================================================
--  programas.lua — os apps que eu uso
-- =============================================================
--  Ficam numa tabela global "apps" para os outros arquivos usarem.
--  Quer trocar o terminal ou o navegador? Mude só aqui.
-- =============================================================

apps = {
    terminal    = "kitty",
    arquivos    = "nautilus",
    navegador   = "flatpak run com.brave.Browser",
    editor      = "code",
    menu        = "rofi -show drun",            -- lista de aplicativos
    janelas     = "rofi -show window",          -- lista de janelas abertas
    bloqueio    = "pidof hyprlock || hyprlock", -- evita abrir dois bloqueios
    som         = "pavucontrol",
}

-- Pasta dos meus scripts (menu de energia, prints, etc.)
scripts = os.getenv("HOME") .. "/.config/hypr/scripts"
