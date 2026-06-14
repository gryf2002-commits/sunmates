#!/usr/bin/env python3
# ============================================================
# SunMates — générateur d'icônes app / favicon / PWA
# Produit le jeu complet de PNG (+ favicon.svg) aux tailles
# exactes utilisées par le Service Worker / le manifest.
#
#   python3 tools-app-icons.py
#
# Pour matcher la DA choisie dans la console : change C1/C2/C3
# (dégradé du fond, haut→milieu→bas) et INK (couleur du soleil).
# Le rendu est fait en pixels (PIL) pour éviter les rayures de
# rasterisation SVG sur les dégradés. Dépendance : Pillow.
# ============================================================
from PIL import Image, ImageDraw
import math, os

# ---- Couleurs (à aligner sur la DA active) ----
C1 = (255, 209, 92)   # haut   #FFD15C
C2 = (255, 138, 61)   # milieu #FF8A3D
C3 = (255, 79, 109)   # bas    #FF4F6D
INK = (255, 246, 233) # soleil #FFF6E9

OUT = os.path.join(os.path.dirname(__file__), "app-icons")
os.makedirs(OUT, exist_ok=True)

def lerp(a, b, t): return tuple(round(a[i] + (b[i]-a[i])*t) for i in range(3))
def grad(t): return lerp(C1, C2, t/0.5) if t < 0.5 else lerp(C2, C3, (t-0.5)/0.5)

def rounded_mask(size, rx, ss=4):
    m = Image.new('L', (size*ss, size*ss), 0)
    ImageDraw.Draw(m).rounded_rectangle([0,0,size*ss-1,size*ss-1], radius=rx*ss, fill=255)
    return m.resize((size, size), Image.LANCZOS)

def draw_sun(img, cx, cy, R, ink, ss=4):
    S = img.size[0]
    lay = Image.new('RGBA', (S*ss, S*ss), (0,0,0,0))
    d = ImageDraw.Draw(lay)
    cxs, cys, Rs = cx*ss, cy*ss, R*ss
    d.ellipse([cxs-Rs, cys-Rs, cxs+Rs, cys+Rs], fill=ink+(255,))
    rw = max(2, int(R*0.34))*ss
    r0, r1 = Rs*1.55, Rs*2.25
    for k in range(8):
        a = math.radians(k*45)
        x0, y0 = cxs+math.cos(a)*r0, cys+math.sin(a)*r0
        x1, y1 = cxs+math.cos(a)*r1, cys+math.sin(a)*r1
        d.line([x0, y0, x1, y1], fill=ink+(255,), width=rw)
        for (px, py) in [(x0, y0), (x1, y1)]:
            d.ellipse([px-rw/2, py-rw/2, px+rw/2, py+rw/2], fill=ink+(255,))
    img.alpha_composite(lay.resize((S, S), Image.LANCZOS))

def make(size, rx, sunR_frac, transparent=False, mono=None):
    img = Image.new('RGBA', (size, size), (0,0,0,0))
    if not transparent:
        base = Image.new('RGBA', (size, size)); px = base.load()
        for y in range(size):
            c = grad(y/(size-1))
            for x in range(size): px[x, y] = c+(255,)
        if rx > 0: base.putalpha(rounded_mask(size, rx))
        img.alpha_composite(base)
    draw_sun(img, size/2, size/2, size*sunR_frac, mono if mono else INK)
    return img

# nom, taille, rayon, rayon-soleil(%), transparent, mono
SPECS = [
    ("icon-512.png",          512, 112, 0.115, False, None),
    ("icon-192.png",          192,  42, 0.115, False, None),
    ("icon-180.png",          180,  40, 0.115, False, None),   # apple-touch-icon
    ("icon-maskable-512.png", 512,   0, 0.095, False, None),   # full-bleed (zone sûre)
    ("favicon-32.png",         32,   7, 0.130, False, None),
    ("badge-96.png",           96,   0, 0.160, True, (255,255,255)),  # notif Android (mono)
]
for name, size, rx, frac, tr, mono in SPECS:
    make(size, rx, frac, tr, mono).save(os.path.join(OUT, name))
    print("wrote", name)

# favicon.svg scalable (le dégradé marche dans un vrai navigateur)
svg = f"""<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 64 64'>
<defs><linearGradient id='g' x1='0' y1='0' x2='0' y2='1'>
<stop offset='0' stop-color='rgb{C1}'/><stop offset='.5' stop-color='rgb{C2}'/><stop offset='1' stop-color='rgb{C3}'/>
</linearGradient></defs>
<rect width='64' height='64' rx='14' fill='url(#g)'/>
<g stroke='rgb{INK}' stroke-width='3.4' stroke-linecap='round'>
<line x1='32' y1='8' x2='32' y2='15'/><line x1='32' y1='49' x2='32' y2='56'/>
<line x1='8' y1='32' x2='15' y2='32'/><line x1='49' y1='32' x2='56' y2='32'/>
<line x1='15' y1='15' x2='20' y2='20'/><line x1='49' y1='15' x2='44' y2='20'/>
<line x1='15' y1='49' x2='20' y2='44'/><line x1='49' y1='49' x2='44' y2='44'/></g>
<circle cx='32' cy='32' r='11' fill='rgb{INK}'/></svg>"""
open(os.path.join(OUT, "favicon.svg"), "w", encoding="utf-8").write(svg)
print("wrote favicon.svg")
print("\nFini →", OUT)
