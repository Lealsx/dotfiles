# Guia do meu Arch + Hyprland

Tudo sobre este projeto: **onde fica cada coisa, como mudar e como aplicar**.
(O `README.md` é a vitrine do GitHub; este guia é o "manual de uso" do dia a dia.)

---

## 1. O básico

### Onde está tudo
Tudo fica na pasta **`~/dotfiles`** (= `/home/leall/dotfiles`).
Ela é um repositório Git ligado a **github.com/Lealsx/dotfiles**.

### Como abrir para mexer
```bash
code ~/dotfiles
```
(abre a pasta inteira no VS Code; à esquerda aparecem todos os arquivos)

### Como funciona (stow)
Os programas leem as configurações em `~/.config/...`, mas lá só existem
**atalhos (links)** que apontam para `~/dotfiles`. Exemplo:

```
~/.config/hypr   →   ~/dotfiles/hypr/.config/hypr
~/.config/waybar →   ~/dotfiles/waybar/.config/waybar
```

Por isso **editar em qualquer um dos dois lugares dá no mesmo**: é o mesmo arquivo.
Cada pasta de primeiro nível do `~/dotfiles` é um "pacote" do **stow**
(hypr, waybar, rofi, swaync, kitty, swappy, icones, matugen).

> ⚠️ Nunca apague a pasta `~/dotfiles`: todas as configurações estão nela.

---

## 2. Mapa: onde fica cada coisa

### 🪟 Hyprland (janelas, atalhos, visual) — `hypr/.config/hypr/`
| Quero mudar… | Arquivo |
|---|---|
| Monitores (resolução, posição, escala) | `hyprland.lua` (ou use `Super + P`) |
| Programas padrão (terminal, navegador, editor) | `programas.lua` |
| Variáveis de ambiente (cursor, Qt, Electron) | `ambiente.lua` |
| O que abre sozinho ao iniciar | `inicio.lua` |
| Bordas, cantos, sombra, desfoque, **animações** | `aparencia.lua` |
| Teclado (US intl + ABNT2), touchpad, gestos | `entrada.lua` |
| **Atalhos de teclado** | `atalhos.lua` |
| Regras de janelas (quais abrem soltas etc.) | `regras.lua` |
| O que o modo economia desliga | `economia.lua` + `scripts/modo-economia.sh` |
| Pulso de luz ao abrir apps, pausa do vídeo de fundo | `efeitos.lua` |
| Cores padrão (tema Muzan, quando não há música) | `cores-muzan.lua` |
| Tela de bloqueio (`Super + L`) | `hyprlock.conf` |
| Tempo para bloquear / desligar tela / suspender | `hypridle.conf` |

`cores.lua` é **gerado** pelo tema musical (não edite; muda a cada álbum).

### 📜 Scripts — `hypr/.config/hypr/scripts/`
| Script | O que faz |
|---|---|
| `musica-tema.sh` | Escuta o Spotify e troca papel de parede + cores a cada álbum; cartão "Tocando agora" |
| `musica-wallpaper.py` | Desenha o papel de parede do álbum (capa, brilho, vinil girando) e a transição |
| `wallpaper.sh` | Decide o papel de parede (álbum, vídeo ou imagem) |
| `wallpaper-pausa.sh` | Pausa o vídeo de fundo quando há janelas na frente |
| `spotify.sh` | Mostra a música do Spotify na barra |
| `player.sh` | Mostra outros players (YouTube no Brave, VLC…) na barra |
| `visualizador.sh` | Barrinhas que dançam com a música (cava) |
| `modo-economia.sh` | Liga/desliga o modo economia de bateria |
| `telas.sh` | Menu de posição das telas (`Super + P`) |
| `menu-energia.sh` | Menu bloquear/suspender/sair/reiniciar/desligar |
| `print.sh` | Capturas de tela |
| `historico-copia.sh` | Histórico do copiar/colar |
| `atalhos.sh` | Lista de atalhos (`Super + F1`) |

### 🎵 Tema musical (detalhes)
| Quero mudar… | Onde |
|---|---|
| Tamanho/posição da capa e do vinil, velocidade do disco | `scripts/musica-wallpaper.py`, variáveis no topo (`CAPA`, `DISCO`, `SEGUNDOS`…) |
| Transição entre álbuns (duração, distância) | mesmo arquivo: `TRANSICAO`, `SAI`, `ENTRA`, função `transicao` |
| Desfoque e brilho do fundo | mesmo arquivo: linha com `boxblur` e `brightness` |
| Como a cor dominante é escolhida | mesmo arquivo: função `cor_dominante` |
| Esquema de cores (mais fiel / mais vibrante) | `scripts/musica-tema.sh`, função `cores_do_album` (`scheme-content`) |
| Quais cores do álbum vão para cada app | `matugen/.config/matugen/modelos/` |
| Cartão "Tocando agora" e pulso ao trocar de música | `scripts/musica-tema.sh`, função `troca_de_musica` |

### 📊 Barra do topo — `waybar/.config/waybar/`
| Quero mudar… | Arquivo |
|---|---|
| O que aparece e onde | `config.jsonc` (listas `modules-left/center/right`) |
| Visual, animações, espaçamentos | `style.css` |
| Cores padrão | `cores-muzan.css` (`cores.css` é gerado) |
| Visualizador (número de barras, velocidade) | `cava.conf` |

### 🎛️ Central de controle e notificações — `swaync/.config/swaync/`
| Quero mudar… | Arquivo |
|---|---|
| Widgets e **botões** da Central | `config.json` (`widgets` e `buttons-grid`) |
| Visual | `style.css` |
| Cores padrão | `cores-muzan.css` (`cores.css` é gerado) |

### Outros apps
| App | Arquivo |
|---|---|
| Menu de apps (`Super + D`) | `rofi/.config/rofi/config.rasi` |
| Terminal kitty | `kitty/.config/kitty/kitty.conf` |
| Editor de prints | `swappy/.config/swappy/config` |
| Cursor padrão do sistema | `icones/.icons/default/index.theme` |
| Tela de login (SDDM) | `sistema/sddm/silent-muzan.conf` (+ `tema.conf`) |

### Instalação num PC novo
| Arquivo | Para quê |
|---|---|
| `instalar.sh` | Instala os pacotes e cria os links do stow |
| `pacotes.txt` | Lista de pacotes oficiais |
| `sistema/sddm/instalar.sh` | Instala a tela de login (copia com `sudo`) |

---

## 3. Depois de mudar: como aplicar

| O que mudou | Como aplicar |
|---|---|
| Qualquer `.lua` do Hyprland | **Sozinho, ao salvar** (se errar, aparece uma faixa vermelha com o erro) |
| Barra (Waybar) | `pkill -SIGUSR2 waybar` |
| Central (SwayNC) | `swaync-client -R` (config) e `swaync-client -rs` (visual) |
| Terminal (kitty) | `Ctrl + Shift + F5` dentro do kitty |
| Menu (Rofi) | Só abrir de novo |
| `hyprlock.conf` | Vale no próximo bloqueio |
| `hypridle.conf` / papel de parede | Sair e entrar na sessão (ou rodar o script de novo) |
| Papel de parede do álbum (`musica-wallpaper.py`) | `rm ~/.cache/musica/ultimo` e trocar de música |
| Tela de login | `~/dotfiles/sistema/sddm/instalar.sh` |

**Checar se a config do Hyprland está certa antes:**
```bash
cd ~/.config/hypr && Hyprland --verify-config | sed -n '/parsing result/,$p'
```
(o resultado `config ok` aparece depois de uma linha em branco)

---

## 4. Salvar no GitHub

Depois de mudar algo e gostar do resultado:
```bash
cd ~/dotfiles
git status            # quais arquivos mudaram
git diff              # o que mudou, linha por linha
git add -A
git commit -m "o que eu mudei"
git push
```

**Deu errado? Desfazer:**
```bash
git checkout -- arquivo     # desfaz um arquivo (o que ainda não virou commit)
git checkout -- .           # desfaz TUDO que ainda não virou commit
```

**Arquivos que NÃO vão para o GitHub** (estão no `.gitignore`): os `cores.*`
gerados pelo tema musical, backups `.bak` e temporários.

---

## 5. Arquivos fora do `~/dotfiles` (gerados / estado)

| Caminho | O que é |
|---|---|
| `~/.cache/musica/` | Tema musical: capa atual, papel de parede do álbum (`album/`), `ultimo`, `pedido`, `desligado` |
| `~/.cache/hypr-economia` | Existe = modo economia ligado |
| `~/.cache/hyprpaper.conf` | Config do papel de parede parado (gerada) |
| `~/.local/state/hypr/telas` | Posição das telas escolhida no `Super + P` |
| `~/Imagens/wallpapers/` | Seu papel de parede (`wallpaper.jpg/.png` ou `wallpaper.mp4`) |
| `~/Imagens/Capturas de tela/` | Prints |
| `/etc/sddm.conf.d/`, `/usr/share/sddm/themes/silent/` | Tela de login (copiados pelo `sistema/sddm/instalar.sh`) |

---

## 6. Atalhos principais

`Super` = tecla do Windows. **`Super + F1` mostra todos, com busca.**

| Atalho | Ação |
|---|---|
| `Super + Enter` | Terminal |
| `Super + D` | Menu de apps |
| `Super + Q` | Fechar janela |
| `Super + 1…0` / `Super + Shift + 1…0` | Ir para a área / mandar janela para a área |
| `Super + N` | **Central de controle** |
| `Super + P` | Posição das telas |
| `Super + Espaço` | Teclado US ⇄ BR |
| `Super + Shift + W` | Tema musical liga/desliga |
| `Super + Shift + B` | Modo economia liga/desliga |
| `Super + Shift + M` | Spotify |
| `Super + L` | Bloquear |
| `Super + Esc` | Menu de energia |
| `Print` / `Shift + Print` | Print de área / tela inteira |
| `Super + Shift + V` | Histórico do copiar/colar |

---

## 7. Se algo der errado

| Problema | O que fazer |
|---|---|
| Faixa vermelha no topo | Erro na config do Hyprland: ela diz o arquivo e a linha |
| Barra sumiu | `waybar &` no terminal (mostra o erro) |
| Tema musical parou | `~/.config/hypr/scripts/musica-tema.sh &` |
| Computador travando / lento | Ligue o modo economia (`Super + Shift + B`); vídeo de fundo e efeitos pesam na placa Intel |
| Tela preta ao entrar | `Ctrl + Alt + F3`, faça login e rode `claude --continue` |
| Quero voltar tudo como estava no GitHub | `cd ~/dotfiles && git checkout -- .` |

Cada arquivo tem **comentários em português** explicando cada parte — leia o topo
do arquivo antes de mexer.
