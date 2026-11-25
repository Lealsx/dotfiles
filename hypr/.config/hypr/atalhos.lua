-- =============================================================
--  atalhos.lua — atalhos de teclado
-- =============================================================
--  "SUPER" é a tecla do Windows.
--  Super + F1 mostra a lista de todos os atalhos (com busca).
--
--  Todo atalho é criado com a função atalho(teclas, ação, descrição).
--  A descrição é o texto que aparece na lista do Super + F1 —
--  então, ao criar um atalho novo, sempre coloque uma descrição!
-- =============================================================

local mod  = "SUPER"
local exec = hl.dsp.exec_cmd

-- Cria um atalho com descrição. "opcoes" é opcional (ex.: { locked = true }).
local function atalho(teclas, acao, descricao, opcoes)
    opcoes = opcoes or {}
    opcoes.description = descricao
    hl.bind(teclas, acao, opcoes)
end

-- ---------- Ajuda ----------
atalho(mod .. " + F1",      exec(scripts .. "/atalhos.sh"), "Ajuda: mostrar esta lista de atalhos")

-- ---------- Abrir programas ----------
atalho(mod .. " + RETURN",  exec(apps.terminal),  "Abrir: terminal (kitty)")
atalho(mod .. " + D",       exec(apps.menu),      "Abrir: menu de aplicativos")
atalho(mod .. " + TAB",     exec(apps.janelas),   "Abrir: lista de janelas abertas")
atalho(mod .. " + E",       exec(apps.arquivos),  "Abrir: arquivos (Nautilus)")
atalho(mod .. " + B",       exec(apps.navegador), "Abrir: navegador (Brave)")
atalho(mod .. " + C",       exec(apps.editor),    "Abrir: VS Code")
atalho(mod .. " + SHIFT + M", exec(scripts .. "/spotify.sh abrir"), "Abrir: Spotify (ou mostrar a janela)")

-- ---------- Janelas ----------
atalho(mod .. " + Q",       hl.dsp.window.close(),                          "Janela: fechar")
atalho(mod .. " + F",       hl.dsp.window.fullscreen(),                     "Janela: tela cheia")
atalho(mod .. " + M",       hl.dsp.window.fullscreen({ mode = "maximized" }), "Janela: maximizar (mantém a barra)")
atalho(mod .. " + V",       hl.dsp.window.float({ action = "toggle" }),     "Janela: soltar/encaixar (flutuante)")
atalho(mod .. " + J",       hl.dsp.layout("togglesplit"),                   "Janela: dividir em pé/deitado")

local setas = { left = "à esquerda", right = "à direita", up = "acima", down = "abaixo" }
for dir, nome in pairs(setas) do
    atalho(mod .. " + " .. dir,         hl.dsp.focus({ direction = dir }),       "Foco: janela " .. nome)
    atalho(mod .. " + SHIFT + " .. dir, hl.dsp.window.move({ direction = dir }), "Janela: mover " .. nome)
end

-- Mouse: Super + arrastar com botão esquerdo = mover; botão direito = redimensionar
atalho(mod .. " + mouse:272", hl.dsp.window.drag(),   "Mouse: mover a janela", { mouse = true })
atalho(mod .. " + mouse:273", hl.dsp.window.resize(), "Mouse: redimensionar a janela", { mouse = true })

-- ---------- Áreas de trabalho (1 a 10) ----------
for i = 1, 10 do
    local tecla = i % 10 -- a área 10 fica na tecla 0
    atalho(mod .. " + " .. tecla,         hl.dsp.focus({ workspace = i }),       "Área: ir para a área " .. i)
    atalho(mod .. " + SHIFT + " .. tecla, hl.dsp.window.move({ workspace = i }), "Área: mandar janela para a área " .. i)
end

atalho(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }), "Área: próxima")
atalho(mod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }), "Área: anterior")

atalho(mod .. " + S",         hl.dsp.workspace.toggle_special("rascunho"),            "Área: mostrar/esconder o rascunho")
atalho(mod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:rascunho" }), "Área: mandar janela para o rascunho")

-- ---------- Sistema ----------
atalho(mod .. " + SPACE",     exec("hyprctl switchxkblayout all next"), "Sistema: trocar teclado US ⇄ BR")
atalho(mod .. " + P",         exec(scripts .. "/telas.sh"),               "Sistema: posição das telas (em cima, ao lado, espelhar...)")
atalho(mod .. " + L",         exec(apps.bloqueio),                      "Sistema: bloquear a tela")
atalho(mod .. " + ESCAPE",    exec(scripts .. "/menu-energia.sh"),      "Sistema: menu de energia (sair, reiniciar, desligar)")
atalho(mod .. " + SHIFT + V", exec(scripts .. "/historico-copia.sh"),   "Sistema: histórico do copiar/colar")
atalho(mod .. " + N",         exec("makoctl dismiss --all"),            "Sistema: limpar notificações")
atalho(mod .. " + SHIFT + B", exec(scripts .. "/modo-economia.sh"),     "Sistema: modo economia de bateria (liga/desliga)")
atalho(mod .. " + SHIFT + W", exec(scripts .. "/musica-tema.sh alternar"), "Sistema: tema musical — cores e fundo do álbum (liga/desliga)")

-- ---------- Captura de tela ----------
atalho("Print",               exec(scripts .. "/print.sh area"), "Print: selecionar área e editar")
atalho("SHIFT + Print",       exec(scripts .. "/print.sh tela"), "Print: tela inteira (salva e copia)")
atalho(mod .. " + SHIFT + P", exec(scripts .. "/print.sh area"), "Print: selecionar área (sem tecla Print)")

-- ---------- Teclas do notebook (volume, brilho, música) ----------
-- locked = funciona até com a tela bloqueada | repeating = segurar repete
local function fixo() return { locked = true, repeating = true } end
atalho("XF86AudioRaiseVolume",  exec("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), "Tecla: aumentar volume", fixo())
atalho("XF86AudioLowerVolume",  exec("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      "Tecla: diminuir volume", fixo())
atalho("XF86AudioMute",         exec("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     "Tecla: mudo",            { locked = true })
atalho("XF86AudioMicMute",      exec("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   "Tecla: mudo do microfone", { locked = true })
atalho("XF86MonBrightnessUp",   exec("brightnessctl -e4 -n2 set 5%+"),                  "Tecla: aumentar brilho", fixo())
atalho("XF86MonBrightnessDown", exec("brightnessctl -e4 -n2 set 5%-"),                  "Tecla: diminuir brilho", fixo())
atalho("XF86AudioPlay",         exec("playerctl play-pause"), "Tecla: tocar/pausar música", { locked = true })
atalho("XF86AudioPause",        exec("playerctl play-pause"), "Tecla: tocar/pausar música", { locked = true })
atalho("XF86AudioNext",         exec("playerctl next"),       "Tecla: próxima música",      { locked = true })
atalho("XF86AudioPrev",         exec("playerctl previous"),   "Tecla: música anterior",     { locked = true })
