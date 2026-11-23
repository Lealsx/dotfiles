# dotfiles

Minhas configurações do **Arch Linux + Hyprland**, comentadas em português.

Tema **Muzan** (Demon Slayer): preto, carmesim e brasa, com papel de parede animado,
cantos arredondados, desfoque e animações dramáticas.
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
| `sistema/sddm/` | [SDDM](https://github.com/sddm/sddm) + [SilentSDDM](https://github.com/uiriansan/SilentSDDM) | Tela de login no tema Muzan (fora do stow, ver abaixo) |

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
A tela de login usa o [SilentSDDM](https://github.com/uiriansan/SilentSDDM) com a
configuração própria `sistema/sddm/silent-muzan.conf`: o **mesmo vídeo do papel de parede**
de fundo (nítido na tela de bloqueio, escuro e desfocado no login), cores carmesim/brasa,
fonte JetBrainsMono e textos em português.
Como o SDDM roda antes do login e não lê a pasta pessoal, um script próprio baixa o tema
(numa versão fixa) e copia tudo com `sudo` para `/usr/share/sddm/themes/silent`.
Rode de novo sempre que trocar o papel de parede:

```bash
./sistema/sddm/instalar.sh   # precisa do yay (para o cursor)
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

## Cores (tema Muzan)

| Cor | Hex | Uso |
|---|---|---|
| Preto avermelhado | `#0a0608` | fundos |
| Carmesim | `#e3123b` | destaque: bordas, área ativa, seleção, cursor do terminal |
| Brasa | `#ff7b5c` | segundo destaque (o brilho do olho do Muzan) |
| Branco rosado | `#f5ecee` | texto |

As cores ficam em `aparencia.lua` (bordas e sombra), `waybar/style.css` (`@define-color`),
`rofi/config.rasi`, `mako/config`, `kitty.conf` e `hyprlock.conf`.

## Papel de parede

O `hypr/scripts/wallpaper.sh` escolhe sozinho:
- **vídeo em loop** com o [mpvpaper](https://github.com/GhostNaN/mpvpaper) (pausa quando as janelas cobrem a tela
  e usa a placa de vídeo para decodificar);
- **imagem parada** com o hyprpaper no modo economia (um quadro tirado do próprio vídeo);
- a imagem padrão do Hyprland se não houver vídeo.

O vídeo fica **fora do repositório** (personagens têm direitos autorais), em
`~/Imagens/wallpapers/wallpaper.mp4`. Para usar outro, troque o arquivo e apague o
`wallpaper.png` gerado. Vídeos 4K ficam muito mais leves convertidos para 1080p/30 fps sem som:

```bash
ffmpeg -i video.mp4 -vf "scale=1920:1080,fps=30" -c:v libx264 -crf 22 -an ~/Imagens/wallpapers/wallpaper.mp4
```

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

Estilo "Muzan": dramático e sinistro, sem molas elásticas.
- **Abrir janela**: surge pequena e cresce, desacelerando devagar ("emergindo das sombras")
- **Fechar janela**: achata até virar uma linha, como uma pálpebra fechando
- **Mover janela**: desliza pesada, sem quicar; ao arrastar, balança de leve (*wobble*, novo na 0.57)
- **Borda da janela ativa**: degradê carmesim → brasa → vermelho-escuro girando (uma volta a cada 6 s),
  com brilho vermelho em volta
- **Áreas de trabalho**: deslizam com fade, como névoa; o rascunho (`Super + S`) desce de cima
- **Menu e notificações**: surgem com fade suave; notificações deslizam pela direita
- **Barra**: a área ativa "cresce" com um degradê que flui, barrinhas que dançam no ritmo da música
  ao lado do Spotify (cava), o Spotify "pulsa" enquanto toca, os módulos acendem ao passar o mouse,
  a bateria pisca quando está crítica e "respira" ao carregar

Tudo fica em `hypr/.config/hypr/aparencia.lua` e `waybar/.config/waybar/style.css`.
O modo economia (`Super + Shift + B`) desliga todas as animações.

## Dicas

- Checar erros na config do Hyprland: `Hyprland --verify-config`
- Ver o nome/classe das janelas (para criar regras): `hyprctl clients`
- Trocar o papel de parede: veja a seção "Papel de parede"
- Rodar um app na placa NVIDIA: `prime-run <app>`
