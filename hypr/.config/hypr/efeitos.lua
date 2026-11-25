-- =============================================================
--  efeitos.lua — efeitos especiais do tema Muzan
-- =============================================================
--  1) Pulso de sangue: quando um app abre, a borda dele acende em brasa
--     quase branca e vai "esfriando" até o carmesim normal.
--  2) Papel de parede inteligente: o vídeo só toca quando alguma tela
--     está com a área de trabalho VAZIA; com janelas abertas, ele pausa.
--  (O "olho abrindo" fica em aparencia.lua, na animação windowsIn.)
--
--  Tudo isso é desligado no modo economia (Super + Shift + B).
-- =============================================================

if economia then return end

-- ---------- Aura vermelha: DESLIGADA ----------
-- A variante de desfoque "aurora" (9) é animada e obriga o Hyprland a redesenhar
-- as duas telas o tempo todo: a placa de vídeo (Intel UHD) foi de 31% para 97%
-- de uso e o computador travava. Ficou desligada. Para referência:
--   0 kawase (normal) | 1 frost | 2 ripple | 3 drops | 4 water | 5 fluid_jar
--   6 prism | 7 heat_shimmer | 8 acrylic | 9 aurora | 10 haze

-- ---------- 1) Pulso de sangue ao abrir um app ----------
-- A borda passa por 3 cores, uma depois da outra:
--   brasa quase branca → brasa → volta ao normal (carmesim girando).
-- A transição entre elas é suave por causa da animação "border" (aparencia.lua).
local function cor_da_borda(endereco, cor)
    pcall(hl.dispatch, hl.dsp.window.set_prop({
        prop = "active_border_color", value = cor, window = "address:" .. endereco,
    }))
end

hl.on("window.open", function(janela)
    if not janela or not janela.address then return end
    local endereco = janela.address

    cor_da_borda(endereco, "rgba(" .. cores.claro .. "ff) rgba(" .. cores.destaque2 .. "ff) 45deg")   -- acende
    hl.timer(function()
        cor_da_borda(endereco, "rgba(" .. cores.destaque2 .. "ff) rgba(" .. cores.destaque .. "ff) 45deg") -- esfria
    end, { timeout = 250, type = "oneshot" })
    hl.timer(function()
        cor_da_borda(endereco, "unset")                              -- volta ao normal
    end, { timeout = 700, type = "oneshot" })
end)

-- ---------- 2) Papel de parede inteligente ----------
-- Cada quadro do vídeo obriga o Hyprland a redesenhar as telas inteiras, com
-- todas as janelas por cima — na placa Intel UHD isso deixava o uso em 100%.
-- Com janelas abertas quase não se vê o fundo, então o vídeo pausa; quando
-- alguma tela fica com a área de trabalho vazia, ele volta a tocar.
-- Quem decide é o wallpaper-pausa.sh (modo "auto"), pelo "socket" do mpv.
local function atualizar_video()
    hl.exec_cmd(scripts .. "/wallpaper-pausa.sh auto")
end

-- confere logo depois de cada mudança (o pequeno atraso deixa o Hyprland
-- terminar de abrir/fechar/mover a janela antes de contar)
local function depois(_)
    hl.timer(atualizar_video, { timeout = 150, type = "oneshot" })
end
for _, evento in ipairs({ "window.open", "window.close", "window.destroy",
                          "window.move_to_workspace", "workspace.active",
                          "monitor.focused", "monitor.added", "monitor.removed" }) do
    hl.on(evento, depois)
end
-- ao iniciar o Hyprland, confere uma vez
-- (não usar "config.reloaded" aqui: um timer nesse evento derruba o
--  "Hyprland --verify-config" com falha de segmentação)
hl.on("hyprland.start", function() hl.timer(atualizar_video, { timeout = 3000, type = "oneshot" }) end)

