-- =============================================================
--  ambiente.lua — variáveis de ambiente
-- =============================================================
--  São "avisos" para os programas sobre como devem rodar.
-- =============================================================

-- Tamanho do cursor do mouse
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Apps Qt (ex.: IntelliJ partes, pavucontrol-qt) rodando nativo no Wayland;
-- se não der, cai para o modo X11 (xcb).
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")

-- Apps Electron (VS Code, Discord...) usam Wayland nativo → texto nítido
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

-- Apps Java (IntelliJ) não ficam com janela cinza/em branco no tiling
hl.env("_JAVA_AWT_WM_NONREPARENTING", "1")

-- Notebook com Intel + NVIDIA: o Hyprland roda na Intel (economiza bateria).
-- Para usar a NVIDIA num app específico: prime-run <app>
