-- =============================================================
--  ambiente.lua — variáveis de ambiente
-- =============================================================
--  São "avisos" para os programas sobre como devem rodar.
-- =============================================================

-- Cursor do mouse: Bibata Modern Classic (preto com borda branca), tamanho 24
--   O Bibata só vem no formato clássico (XCURSOR), que o Hyprland também usa
--   quando não há um tema no formato nativo dele (HYPRCURSOR).
hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("XCURSOR_SIZE", "24")

-- O Hyprland prefere cursores no formato nativo dele (hyprcursor). O Bibata não
-- tem esse formato; se outro tema instalado tiver (ex.: Catppuccin), o Hyprland
-- usaria ESSE no lugar do Bibata. Desligando, ele usa o XCURSOR_THEME acima.
hl.config({ cursor = { enable_hyprcursor = false } })

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
