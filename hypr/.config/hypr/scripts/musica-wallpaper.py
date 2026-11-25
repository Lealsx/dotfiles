#!/usr/bin/env python3
# =============================================================
#  musica-wallpaper.py — monta o papel de parede animado do álbum
# =============================================================
#  Uso: musica-wallpaper.py <capa.png> <pasta-de-saída>
#       musica-wallpaper.py --transicao <pasta-do-álbum-antigo> <pasta-do-novo>
#
#  Desenha (com cairo) as peças do papel de parede e o ffmpeg junta
#  tudo num vídeo curto em loop:
#    fundo.png   → a capa ampliada, desfocada e escurecida (parado)
#    vinil.png   → disco de vinil com a capa no rótulo (este GIRA)
#    frente.png  → a capa pequena com sombra e um brilho na cor do álbum
#  Saída: wallpaper.mp4 (4 s, 24 quadros/s, loop perfeito) e wallpaper.png
#  (o primeiro quadro, usado no modo economia).
#
#  --transicao: vídeo de ~2,4 s "trocando o disco" (transicao.mp4, na pasta
#  do álbum novo): o disco e a capa antigos saem deslizando para a esquerda,
#  o fundo se mistura do antigo para o novo, a capa nova entra pela direita
#  e o vinil novo chega girando rápido e desacelera. O último quadro é igual
#  ao primeiro do loop novo, então a troca para o wallpaper.mp4 não "pula".
# =============================================================
import cairo
import math
import subprocess
import sys
from pathlib import Path

LARG, ALT = 1920, 1080          # tamanho da tela
CAPA = 480                      # lado da capa (pequena, no centro)
DISCO = 460                     # diâmetro do vinil
CAPA_X = LARG // 2 - CAPA // 2 - 120   # capa um pouco à esquerda do centro...
CAPA_Y = ALT // 2 - CAPA // 2
DISCO_CX = CAPA_X + CAPA // 2 + 210    # ...para o disco aparecer à direita
DISCO_CY = ALT // 2
SEGUNDOS, QPS = 4, 24           # uma volta do disco = 4 s


def cor_dominante(imagem):
    """Cor que MAIS aparece na capa.

    Agrupa os pixels por tom (matiz), saturação e brilho e pega o grupo mais
    numeroso. Pixels quase pretos ficam de fora (fundo preto não é "cor").
    Se a capa quase não tiver cor (preto e branco), usa o grupo mais
    numeroso mesmo assim — o tema fica em tons de cinza, fiel à capa.
    """
    import colorsys
    w, h = imagem.get_width(), imagem.get_height()
    dados, passo = imagem.get_data(), imagem.get_stride()
    grupos_cor, grupos_todos = {}, {}
    for y in range(0, h, 4):
        for x in range(0, w, 4):
            b, g, r = dados[y * passo + x * 4: y * passo + x * 4 + 3]
            hh, ss, vv = colorsys.rgb_to_hsv(r / 255, g / 255, b / 255)
            if vv < 0.12:
                continue                                  # quase preto
            chave = (int(hh * 18), int(ss * 4), int(vv * 4))  # 18 tons x 4 x 4
            for grupos in ((grupos_cor,) if ss > 0.18 else ()) + (grupos_todos,):
                soma = grupos.setdefault(chave, [0, 0, 0, 0])
                soma[0] += r; soma[1] += g; soma[2] += b; soma[3] += 1
    total = sum(v[3] for v in grupos_todos.values()) or 1
    coloridos = sum(v[3] for v in grupos_cor.values())
    grupos = grupos_cor if coloridos > total * 0.08 else grupos_todos
    if not grupos:
        return (0.5, 0.5, 0.5)
    r, g, b, n = max(grupos.values(), key=lambda v: v[3])
    return (r / n / 255, g / n / 255, b / n / 255)


def desenhar_capa(ctx, imagem, x, y, lado):
    ctx.save()
    ctx.translate(x, y)
    ctx.scale(lado / imagem.get_width(), lado / imagem.get_height())
    ctx.set_source_surface(imagem, 0, 0)
    ctx.get_source().set_filter(cairo.FILTER_BEST)
    ctx.paint()
    ctx.restore()


def vinil(imagem, saida):
    sup = cairo.ImageSurface(cairo.FORMAT_ARGB32, DISCO, DISCO)
    ctx = cairo.Context(sup)
    c, raio = DISCO / 2, DISCO / 2
    # disco preto
    ctx.arc(c, c, raio, 0, 2 * math.pi)
    ctx.set_source_rgb(0.04, 0.04, 0.05)
    ctx.fill()
    # sulcos (círculos finos levemente mais claros)
    for r in range(int(raio * 0.36), int(raio - 4), 5):
        ctx.arc(c, c, r, 0, 2 * math.pi)
        ctx.set_source_rgba(1, 1, 1, 0.045 if r % 2 else 0.025)
        ctx.set_line_width(1)
        ctx.stroke()
    # reflexo de luz (faixa diagonal) — é ele que deixa visível o disco girando
    for ang, alpha in ((0.6, 0.10), (0.6 + math.pi, 0.06)):
        ctx.move_to(c, c)
        ctx.arc(c, c, raio - 4, ang, ang + 0.35)
        ctx.close_path()
        ctx.set_source_rgba(1, 1, 1, alpha)
        ctx.fill()
    # rótulo: a própria capa, recortada em círculo
    rotulo = raio * 0.34
    ctx.save()
    ctx.arc(c, c, rotulo, 0, 2 * math.pi)
    ctx.clip()
    desenhar_capa(ctx, imagem, c - rotulo, c - rotulo, rotulo * 2)
    ctx.restore()
    # furo do meio
    ctx.arc(c, c, 6, 0, 2 * math.pi)
    ctx.set_source_rgb(0.02, 0.02, 0.02)
    ctx.fill()
    sup.write_to_png(saida)


def cor_viva(cor):
    """Deixa a cor de destaque mais viva (para o brilho aparecer no fundo escuro)."""
    import colorsys
    h, sat, v = colorsys.rgb_to_hsv(*cor)
    if sat < 0.12:                      # capa sem cor (preto e branco/cinza):
        return (0.95, 0.95, 0.95)       # brilho branco, em vez de inventar um tom
    return colorsys.hsv_to_rgb(h, max(sat, 0.55), max(v, 0.9))


def retangulo_arredondado(ctx, x, y, w, h, raio):
    ctx.new_sub_path()
    ctx.arc(x + w - raio, y + raio, raio, -math.pi / 2, 0)
    ctx.arc(x + w - raio, y + h - raio, raio, 0, math.pi / 2)
    ctx.arc(x + raio, y + h - raio, raio, math.pi / 2, math.pi)
    ctx.arc(x + raio, y + raio, raio, math.pi, 3 * math.pi / 2)
    ctx.close_path()


def frente(imagem, cor, saida):
    sup = cairo.ImageSurface(cairo.FORMAT_ARGB32, LARG, ALT)
    ctx = cairo.Context(sup)
    r, g, b = cor_viva(cor)
    # brilho suave na cor do álbum: muitas camadas finas, cada vez mais
    # largas e transparentes (parece uma luz saindo de trás da capa)
    for i in range(90, 0, -1):
        retangulo_arredondado(ctx, CAPA_X - i, CAPA_Y - i, CAPA + 2 * i, CAPA + 2 * i, 12 + i)
        ctx.set_source_rgba(r, g, b, 0.05 * math.exp(-i / 22))
        ctx.fill()
    # sombra embaixo da capa
    for i in range(20, 0, -1):
        retangulo_arredondado(ctx, CAPA_X - i + 8, CAPA_Y - i + 14, CAPA + 2 * i, CAPA + 2 * i, 6 + i)
        ctx.set_source_rgba(0, 0, 0, 0.035)
        ctx.fill()
    desenhar_capa(ctx, imagem, CAPA_X, CAPA_Y, CAPA)
    sup.write_to_png(saida)


TRANSICAO = 2.4    # duração da transição (s)
SAI, ENTRA = 0.9, 1.5   # o antigo sai em 0,9 s; o novo entra em 1,5 s


def transicao(antigo, novo):
    ff = ["nice", "-n", "15", "ffmpeg", "-v", "error", "-y"]
    x0, y0 = DISCO_CX - DISCO // 2, DISCO_CY - DISCO // 2
    longe = 1500                       # quanto as peças andam (px)
    T, V = TRANSICAO, SEGUNDOS
    # progresso da entrada (0 → 1) e a mesma coisa "desacelerando" (ease-out cúbico)
    p = f"clip((t-{SAI})/{ENTRA},0,1)"
    e = f"(1-pow(1-{p},3))"
    # saída: acelera para a esquerda (ease-in quadrático)
    saida = f"-{longe}*pow(clip(t/{SAI},0,1),2)"
    entrada = f"{longe}*(1-{e})"
    # vinil novo: termina no ângulo 0 (igual ao loop) e chega com 3 voltas extras
    ang_novo = f"2*PI*(t-{T})/{V}-6*PI*pow(1-{e},2)"
    entradas = []
    for arq in (antigo / "fundo.png", novo / "fundo.png", antigo / "vinil.png",
                antigo / "frente.png", novo / "vinil.png", novo / "frente.png"):
        entradas += ["-loop", "1", "-framerate", str(QPS), "-t", str(T), "-i", str(arq)]
    filtro = (
        # fundo: mistura suave do antigo para o novo
        f"[0:v][1:v]xfade=transition=fade:duration=1.2:offset=0.3[fundo];"
        # peças antigas: giram, saem para a esquerda e somem
        f"[2:v]format=rgba,rotate=2*PI*t/{V}:c=none:ow=iw:oh=ih,"
        f"fade=t=out:st=0.4:d=0.5:alpha=1[vinil_a];"
        f"[3:v]format=rgba,fade=t=out:st=0.4:d=0.5:alpha=1[frente_a];"
        # peças novas: entram pela direita desacelerando; o vinil chega girando rápido
        f"[4:v]format=rgba,rotate='{ang_novo}':c=none:ow=iw:oh=ih,"
        f"fade=t=in:st={SAI}:d=0.4:alpha=1[vinil_n];"
        f"[5:v]format=rgba,fade=t=in:st={SAI}:d=0.4:alpha=1[frente_n];"
        f"[fundo][vinil_a]overlay=x='{x0}+{saida}':y={y0}:eval=frame[a];"
        f"[a][frente_a]overlay=x='{saida}':y=0:eval=frame[b];"
        f"[b][vinil_n]overlay=x='{x0}+{entrada}':y={y0}:eval=frame[c];"
        f"[c][frente_n]overlay=x='{entrada}':y=0:eval=frame,format=yuv420p"
    )
    subprocess.run(ff + entradas + ["-filter_complex", filtro, "-t", str(T), "-r", str(QPS),
                   "-c:v", "libx264", "-preset", "medium", "-crf", "23", "-an",
                   "-movflags", "+faststart", str(novo / "transicao.mp4")], check=True)


def main():
    if sys.argv[1] == "--transicao":
        transicao(Path(sys.argv[2]), Path(sys.argv[3]))
        return
    capa_png, pasta = Path(sys.argv[1]), Path(sys.argv[2])
    pasta.mkdir(parents=True, exist_ok=True)
    imagem = cairo.ImageSurface.create_from_png(str(capa_png))
    cor = cor_dominante(imagem)

    vinil(imagem, str(pasta / "vinil.png"))
    frente(imagem, cor, str(pasta / "frente.png"))

    ff = ["nice", "-n", "15", "ffmpeg", "-v", "error", "-y"]
    # fundo: capa ampliada para cobrir a tela, bem desfocada e escurecida
    subprocess.run(ff + ["-i", str(capa_png), "-vf",
        f"scale={LARG}:{LARG},crop={LARG}:{ALT},boxblur=30:3,eq=brightness=-0.12:saturation=1.3",
        "-frames:v", "1", str(pasta / "fundo.png")], check=True)

    # vídeo: fundo + disco girando (atrás) + capa com brilho (na frente)
    x, y = DISCO_CX - DISCO // 2, DISCO_CY - DISCO // 2
    subprocess.run(ff + [
        "-loop", "1", "-framerate", str(QPS), "-i", str(pasta / "fundo.png"),
        "-loop", "1", "-framerate", str(QPS), "-i", str(pasta / "vinil.png"),
        "-loop", "1", "-framerate", str(QPS), "-i", str(pasta / "frente.png"),
        "-filter_complex",
        f"[1:v]format=rgba,rotate=2*PI*t/{SEGUNDOS}:c=none:ow=iw:oh=ih[disco];"
        f"[0:v][disco]overlay={x}:{y}[a];[a][2:v]overlay=0:0,format=yuv420p",
        "-t", str(SEGUNDOS), "-r", str(QPS), "-c:v", "libx264", "-preset", "medium",
        "-crf", "23", "-an", "-movflags", "+faststart", str(pasta / "wallpaper.novo.mp4")],
        check=True)
    subprocess.run(ff + ["-i", str(pasta / "wallpaper.novo.mp4"), "-frames:v", "1",
                         str(pasta / "wallpaper.png")], check=True)
    (pasta / "wallpaper.novo.mp4").replace(pasta / "wallpaper.mp4")
    print("#%02x%02x%02x" % tuple(int(v * 255) for v in cor))  # cor dominante (usada pelo matugen)


if __name__ == "__main__":
    main()
