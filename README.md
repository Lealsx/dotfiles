# dotfiles

Minhas configurações do **Arch Linux + Hyprland**, comentadas em português.

Tema **Miles Morales** (Homem-Aranha no Aranhaverso): preto, vermelho e ciano "glitch",
com papel de parede animado, cantos arredondados, desfoque e animações.
Feito para um notebook (Intel + NVIDIA) com dois teclados: **inglês internacional** e **português ABNT2**.

## O que tem aqui

| Pasta | Programa | Para que serve |
|---|---|---|
| `hypr/` | [Hyprland](https://hypr.land) 0.57+ | Gerenciador de janelas (config em **Lua**) + bloqueio, inatividade e papel de parede |
| `waybar/` | [Waybar](https://github.com/Alexays/Waybar) | Barra do topo |
| `rofi/` | [Rofi](https://github.com/davatorium/rofi) | Menu de aplicativos |
| `mako/` | [mako](https://github.com/emersion/mako) | Notificações |
| `kitty/` | [kitty](https://sw.kovidgoyal.net/kitty/) | Terminal |
| `swappy/` | [swappy](https://github.com/jtheoof/swappy) | Editor de capturas de tela |
| `sistema/sddm/` | [SDDM](https://github.com/sddm/sddm) + [Catppuccin](https://github.com/catppuccin/sddm) | Tela de login (fora do stow, ver abaixo) |

Cada pasta segue o formato do [GNU Stow](https://www.gnu.org/software/stow/):
`hypr/.config/hypr/...` vira `~/.config/hypr/...` através de um link simbólico.
Assim, editar o arquivo em `~/.config` é o mesmo que editar aqui no repositório.

### Arquivos do Hyprland

```
hypr/.config/hypr/
├── hyprland.lua     → arquivo principal (carrega os outros)
├── programas.lua    → terminal, navegador, editor...
├── ambiente.lua     → variáveis de ambiente
├── inicio.lua       → o que abre ao iniciar
├── aparencia.lua    → cores, bordas, desfoque, animações
├── entrada.lua      → teclado, touchpad, gestos
├── atalhos.lua      → atalhos de teclado
├── regras.lua       → regras de janelas
├── economia.lua     → modo economia de bateria
├── hyprlock.conf    → tela de bloqueio
├── hypridle.conf    → bloqueio/suspensão por inatividade
└── scripts/         → menu de energia, prints, histórico do copiar, Spotify, modo economia
```

## Instalação

```bash
git clone git@github.com:Lealsx/dotfiles.git ~/dotfiles
cd ~/dotfiles
./instalar.sh
```

O `instalar.sh` instala os pacotes de `pacotes.txt` e cria os links com o `stow`.

### Tela de login (opcional)
A tela de login usa o [SDDM](https://github.com/sddm/sddm) com o tema
[Catppuccin Mocha](https://github.com/catppuccin/sddm) azul e a fonte JetBrainsMono.
Como esses arquivos ficam em `/etc` e `/usr/share` (fora da pasta pessoal),
eles não são ligados pelo stow — um script próprio copia com `sudo`:

```bash
./sistema/sddm/instalar.sh   # precisa do yay (o tema vem do AUR)
```
Depois é só sair da sessão e escolher **Hyprland (uwsm-managed)** na tela de login.

## Atalhos

`Super` = tecla do Windows.

> **Esqueceu um atalho?** Aperte `Super + F1`: abre a lista de todos os atalhos, com busca.
> A lista é lida direto do Hyprland (`hyprctl binds`), a partir das descrições em `atalhos.lua`.

### Programas
| Atalho | Ação |
|---|---|
| `Super + Enter` | Terminal |
| `Super + D` | Menu de aplicativos |
| `Super + Tab` | Lista de janelas abertas |
| `Super + E` | Arquivos |
| `Super + B` | Navegador |
| `Super + C` | VS Code |
| `Super + Shift + M` | Spotify (abre ou mostra a janela) |

### Janelas
| Atalho | Ação |
|---|---|
| `Super + Q` | Fechar janela |
| `Super + F` | Tela cheia |
| `Super + M` | Maximizar (mantém a barra) |
| `Super + V` | Soltar/encaixar a janela (flutuante) |
| `Super + J` | Alternar divisão em pé/deitado |
| `Super + ←↑→↓` | Mudar o foco |
| `Super + Shift + ←↑→↓` | Mover a janela |
| `Super + arrastar (botão esquerdo)` | Mover com o mouse |
| `Super + arrastar (botão direito)` | Redimensionar com o mouse |

### Áreas de trabalho
| Atalho | Ação |
|---|---|
| `Super + 1…0` | Ir para a área 1…10 |
| `Super + Shift + 1…0` | Mandar a janela para a área 1…10 |
| `Super + rolar o mouse` | Passar pelas áreas |
| 3 dedos para os lados no touchpad | Passar pelas áreas |
| `Super + S` | Mostrar/esconder a área "rascunho" |
| `Super + Shift + S` | Mandar a janela para o rascunho |

### Sistema
| Atalho | Ação |
|---|---|
| `Super + Espaço` | Trocar teclado US ⇄ BR |
| `Super + L` | Bloquear a tela |
| `Super + Esc` | Menu de energia (bloquear, suspender, sair, reiniciar, desligar) |
| `Super + Shift + V` | Histórico do copiar/colar |
| `Super + N` | Limpar notificações |
| `Super + Shift + B` | Modo economia de bateria (liga/desliga) |

### Spotify na barra
Ao lado do relógio fica o Spotify: clique no nome da música para abrir/mostrar o app,
use os botões ⏮ ⏯ ⏭ ou role o mouse em cima para trocar de música.
Outros players (YouTube no navegador, VLC...) aparecem num módulo separado ao lado.

### Modo economia de bateria
Para quando estiver fora de casa. Liga/desliga com `Super + Shift + B` ou clicando na folha 🍃 da barra
(verde = ligado). Quando ligado:
- perfil de energia `power-saver` (via `power-profiles-daemon`)
- tela do notebook a 60 Hz em vez de 144 Hz
- sem desfoque, sombras, transparência e animações
- Bluetooth desligado
| `Print` ou `Super + Shift + P` | Print de uma área (abre o editor) |
| `Shift + Print` | Print da tela inteira |

### Acentos no teclado inglês (layout internacional)
| Para | Digite |
|---|---|
| á é í ó ú | `'` + letra |
| â ê ô | `^` + letra |
| ã õ | `~` + letra |
| à | `` ` `` + a |
| ç | `AltGr + ,` |
| `'` ou `"` sozinho | a tecla + Espaço |

## Cores (tema Miles Morales)

| Cor | Hex | Uso |
|---|---|---|
| Preto | `#0d0d12` | fundos |
| Vermelho Miles | `#ff2a4f` | destaque: bordas, área ativa, seleção, cursor do terminal |
| Ciano "glitch" | `#00d8ff` | segundo destaque (o efeito do Aranhaverso) |
| Branco | `#f4f4f6` | texto |

As cores ficam em `aparencia.lua` (bordas e sombra), `waybar/style.css` (`@define-color`),
`rofi/config.rasi`, `mako/config`, `kitty.conf` e `hyprlock.conf`.

## Papel de parede

O `hypr/scripts/wallpaper.sh` escolhe sozinho:
- **vídeo em loop** com o [mpvpaper](https://github.com/GhostNaN/mpvpaper) (pausa quando as janelas cobrem a tela
  e usa a placa de vídeo para decodificar);
- **imagem parada** com o hyprpaper no modo economia (um quadro tirado do próprio vídeo);
- a imagem padrão do Hyprland se não houver vídeo.

O vídeo fica **fora do repositório** (personagens têm direitos autorais), em
`~/Imagens/wallpapers/miles.mp4`. Para usar outro, troque o arquivo (ou a variável `VIDEO`
no script) e apague a `miles.png` gerada.

```bash
yay -S mpvpaper
```

## Ícones e cursor

- **Ícones**: [Papirus-Dark](https://github.com/PapirusDevelopmentTeam/papirus-icon-theme) com pastas azuis
- **Cursor**: [Catppuccin Mocha azul](https://github.com/catppuccin/cursors) (com versão *hyprcursor*, nativa do Hyprland)

O ícone e o cursor são aplicados ao iniciar o Hyprland (`inicio.lua` e `ambiente.lua`).
O cursor e a cor das pastas vêm do AUR, então instale à parte:

```bash
yay -S catppuccin-cursors-mocha papirus-folders
sudo papirus-folders -C blue --theme Papirus-Dark
```

## Animações

- **Janelas** abrem crescendo com um "pulinho" (mola), fecham encolhendo e deslizam ao mudar de lugar
- **Janelas gelatinosas** (*wobble*, novo no Hyprland 0.57): balançam ao arrastar ou redimensionar
- **Borda da janela ativa**: o degradê vermelho → ciano gira (uma volta a cada 4 s), com brilho vermelho em volta
- **Menu (Rofi)** abre crescendo; **notificações** deslizam pela direita
- **Áreas de trabalho** deslizam para o lado; o rascunho (`Super + S`) desce de cima
- **Barra**: a área ativa "cresce" com um degradê vermelho → ciano que flui (igual à borda das janelas),
  barrinhas que dançam no ritmo da música ao lado do Spotify (cava), o Spotify "pulsa" enquanto toca,
  os módulos acendem ao passar o mouse,
  a bateria pisca em vermelho quando está crítica e "respira" ao carregar

Tudo fica em `hypr/.config/hypr/aparencia.lua` e `waybar/.config/waybar/style.css`.
O modo economia (`Super + Shift + B`) desliga todas as animações.

## Dicas

- Checar erros na config do Hyprland: `Hyprland --verify-config`
- Ver o nome/classe das janelas (para criar regras): `hyprctl clients`
- Trocar o papel de parede: veja a seção "Papel de parede"
- Rodar um app na placa NVIDIA: `prime-run <app>`
