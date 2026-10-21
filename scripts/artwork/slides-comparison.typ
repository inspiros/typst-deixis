// Both panels are actual frames of examples/touying-reveals.typ.
#set page(width: 932pt, height: 310pt, margin: 0pt, fill: rgb("F3F5F3"))
#set text(font: "DejaVu Sans", size: 10pt, fill: rgb("526B70"))
#let first = sys.inputs.at("first", default: "../../assets/readme/slide-1.svg")
#let second = sys.inputs.at("second", default: "../../assets/readme/slide-2.svg")
#place(top + left, dx: 14pt, dy: 14pt, [FRAME 1 / BEFORE THE PAUSE])
#place(top + left, dx: 474pt, dy: 14pt, [FRAME 2 / REVEALED WITH THE IDEA])
#place(top + left, dx: 12pt, dy: 37pt,
  block(stroke: 0.6pt + rgb("D4DFDD"), radius: 5pt, inset: 4pt, fill: white,
    image(first, width: 440pt)))
#place(top + left, dx: 472pt, dy: 37pt,
  block(stroke: 0.6pt + rgb("D4DFDD"), radius: 5pt, inset: 4pt, fill: white,
    image(second, width: 440pt)))
