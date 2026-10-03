#!/usr/bin/env python3
"""Build SimonSymbol.otf from simon.svg. Glyph is U+E000 (also mapped to 's').
Needs: pip install fonttools skia-pathops"""
import pathlib, xml.etree.ElementTree as ET
import pathops
from fontTools.svgLib.path import SVGPath
from fontTools.pens.recordingPen import RecordingPen
from fontTools.pens.transformPen import TransformPen
from fontTools.pens.t2CharStringPen import T2CharStringPen
from fontTools.fontBuilder import FontBuilder

here = pathlib.Path(__file__).parent
svgfile = here / "simon.svg"
vb = [float(v) for v in ET.parse(svgfile).getroot().get("viewBox").split()]
UPM, TOP, SIZE = 1000, 860, 1000          # glyph spans y -140..860, like an SF Symbol
s = SIZE / vb[3]
side = 40
xf = (s, 0, 0, -s, -vb[0] * s + side, TOP + vb[1] * s)

# each SVG element is evenodd; normalise each, then union everything (nonzero for fonts)
ns = "{http://www.w3.org/2000/svg}"
root = ET.parse(svgfile).getroot()
total = pathops.Path()
for el in root.iter():
    if el.tag.replace(ns, "") not in ("path", "rect", "ellipse", "circle"):
        continue
    wrapper = ET.Element("svg"); wrapper.append(el)
    p = pathops.Path(); p.fillType = pathops.FillType.EVEN_ODD
    SVGPath.fromstring(ET.tostring(wrapper)).draw(TransformPen(p.getPen(), xf))
    p.simplify(fix_winding=True)
    total = pathops.op(total, p, pathops.PathOp.UNION)
total.simplify(fix_winding=True)

adv = int(vb[2] * s + 2 * side)
cs = T2CharStringPen(adv, None); total.draw(cs)
fb = FontBuilder(UPM, isTTF=False)
fb.setupGlyphOrder([".notdef", "simon"])
fb.setupCharacterMap({0xE000: "simon", ord("s"): "simon"})
nd = T2CharStringPen(adv, None)
fb.setupCFF("SimonSymbol-Regular", {"FullName": "Simon Symbol"},
            {".notdef": nd.getCharString(), "simon": cs.getCharString()}, {})
fb.setupHorizontalMetrics({".notdef": (adv, 0), "simon": (adv, side)})
fb.setupHorizontalHeader(ascent=900, descent=-200)
fb.setupNameTable({"familyName": "Simon Symbol", "styleName": "Regular"})
fb.setupOS2(sTypoAscender=900, sTypoDescender=-200, usWinAscent=900, usWinDescent=200)
fb.setupPost()
fb.save(str(here / "SimonSymbol.otf"))
print("wrote SimonSymbol.otf")
