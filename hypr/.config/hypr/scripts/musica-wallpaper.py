#!/usr/bin/env python3
# =============================================================
#  musica-wallpaper.py — monta o papel de parede animado do álbum
# =============================================================
#  Uso: musica-wallpaper.py <capa.png> <pasta-de-saída>
#
#  Desenha (com cairo) as peças do papel de parede e o ffmpeg junta
#  tudo num vídeo curto em loop:
#    fundo.png   → a capa ampliada, desfocada e escurecida (parado)
#    vinil.png   → disco de vinil com a capa no rótulo (este GIRA)
#    frente.png  → a capa pequena com sombra e um brilho na cor do álbum
#  Saída: wallpaper.mp4 (4 s, 24 quadros/s, loop perfeito) e wallpaper.png
#  (o primeiro quadro, usado no modo economia).
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


def cor_de_destaque(imagem):
    """Cor mais 'viva' da capa: média dos pixels mais saturados."""
    w, h = imagem.get_width(), imagem.get_height()
    dados = imagem.get_data()
    passo = imagem.get_stride()
    pixels = []
    for y in range(0, h, 8):
        for x in range(0, w, 8):
            b, g, r = dados[y * passo + x * 4: y * passo + x * 4 + 3]
            mx, mn = max(r, g, b), min(r, g, b)
            sat = 0 if mx == 0 else (mx - mn) / mx
            pixels.append((sat * (mx / 255), r, g, b))
    pixels.sort(reverse=True)
    topo = pixels[: max(1, len(pixels) // 10)]
    r = sum(p[1] for p in topo) / len(topo) / 255
    g = sum(p[2] for p in topo) / len(topo) / 255
    b = sum(p[3] for p in topo) / len(topo) / 255
    return r, g, b


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


def main():
    capa_png, pasta = Path(sys.argv[1]), Path(sys.argv[2])
    pasta.mkdir(parents=True, exist_ok=True)
    imagem = cairo.ImageSurface.create_from_png(str(capa_png))
    cor = cor_de_destaque(imagem)

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
    print("#%02x%02x%02x" % tuple(int(v * 255) for v in cor))  # cor de destaque


if __name__ == "__main__":
    main()
