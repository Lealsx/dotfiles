-- Cores padrão (tema Muzan). Usadas quando não há álbum tocando ou o tema
-- musical está desligado. O tema musical gera cores.lua com as cores do álbum.
-- (hex sem "#": é assim que o Hyprland monta "rgba(RRGGBBAA)")
return {
    destaque  = "e3123b", -- carmesim: borda ativa e brilho
    destaque2 = "ff7b5c", -- brasa: segunda cor do degradê
    escuro    = "5c0a1a", -- terceira cor do degradê (vermelho bem escuro)
    inativo   = "2e1a1f", -- borda das janelas sem foco
    claro     = "ffd9c7", -- cor do "pulso" ao abrir um app
}
