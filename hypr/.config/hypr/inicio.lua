-- =============================================================
--  inicio.lua — o que abre sozinho quando o Hyprland inicia
-- =============================================================

hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")                      -- barra do topo
    hl.exec_cmd(scripts .. "/wallpaper.sh")    -- papel de parede (vídeo ou imagem)
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
    -- Cursor nos apps GTK (Nautilus, etc.)
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Classic'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-size 24")
end)

-- -------------------------------------------------------------
--  Monitor reconectado → reabre a Waybar
-- -------------------------------------------------------------
--  Quando um monitor volta (cabo, suspensão, monitor que desligou),
--  a Waybar às vezes não cria a barra nele. Ao reabrir, ela cria
--  uma barra para cada monitor ligado.
--  O "contador" evita reabrir várias vezes seguidas se o monitor
--  piscar: só age 2 s depois do ÚLTIMO evento.
local reconexoes = 0
hl.on("monitor.added", function()
    reconexoes = reconexoes + 1
    local minha = reconexoes
    hl.timer(function()
        if minha == reconexoes then
            hl.exec_cmd("pkill -x waybar; sleep 0.5; waybar")
        end
    end, { timeout = 2000, type = "oneshot" })
end)
