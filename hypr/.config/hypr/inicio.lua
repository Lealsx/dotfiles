-- =============================================================
--  inicio.lua — o que abre sozinho quando o Hyprland inicia
-- =============================================================

hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")                      -- barra do topo
    hl.exec_cmd("hyprpaper")                   -- papel de parede
    hl.exec_cmd("mako")                        -- notificações
    hl.exec_cmd("hypridle")                    -- bloqueio/suspensão por inatividade
    hl.exec_cmd("systemctl --user start hyprpolkitagent") -- janela de senha de admin
    hl.exec_cmd("nm-applet --indicator")       -- ícone do Wi-Fi na barra
    hl.exec_cmd("blueman-applet")              -- ícone do Bluetooth na barra

    -- Histórico da área de transferência (texto e imagens)
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    -- Tema escuro nos apps GTK (Nautilus, etc.)
    hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'")
    -- Ícones dos apps e pastas: Papirus (versão escura)
    hl.exec_cmd("gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'")
end)
