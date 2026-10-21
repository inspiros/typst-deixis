// Both panels are actual builds of examples/editorial-review.typ.
#set page(width: 932pt, height: 322pt, margin: 0pt, fill: rgb("F3F5F3"))
#set text(font: "DejaVu Sans", size: 10pt, fill: rgb("526B70"))
#let draft = sys.inputs.at("draft", default: "../../assets/readme/review-draft.svg")
#let final = sys.inputs.at("final", default: "../../assets/readme/review-final.svg")
#place(top + left, dx: 14pt, dy: 14pt, [DRAFT / REVIEW INCLUDED])
#place(top + left, dx: 474pt, dy: 14pt, [FINAL / REVIEW OMITTED])
#place(top + left, dx: 12pt, dy: 37pt,
  block(stroke: 0.6pt + rgb("D4DFDD"), radius: 5pt, inset: 4pt, fill: white,
    image(draft, width: 440pt)))
#place(top + left, dx: 472pt, dy: 37pt,
  block(stroke: 0.6pt + rgb("D4DFDD"), radius: 5pt, inset: 4pt, fill: white,
    image(final, width: 440pt)))
