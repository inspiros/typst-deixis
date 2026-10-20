#import "@preview/deixis:0.2.0": *
#set page(width: 700pt, height: 450pt,
  margin: (left: 35pt, right: 205pt, top: 40pt, bottom: 36pt), fill: white)
#set text(font: "Libertinus Serif", size: 14pt, fill: rgb("263E48"))
#set par(leading: 0.65em, spacing: 1.1em)
#set heading(numbering: none)
#show heading: set text(font: "DejaVu Sans", weight: "bold", size: 23pt)
#show: deixis-setup-notes
#deixis-set(palette: (rgb("32736D"), rgb("526F9B")), overflow: "error",
  body-style: it => text(size: 11.5pt, it))

#text(font: "DejaVu Sans", size: 9pt, tracking: 0.12em, fill: rgb("76868B"))[FIELD NOTES / 01]
= Leave Room For The Idea

A good explanation can stay close to its subject without interrupting the
argument. Start with a #deixis-margin-note(id: <assumption>, side: right,
  width: 160pt, dx: 24pt,
  connector: (route: "right-angle", radius: 5pt),
)[shared assumption][*One Explanation* \
  Several passages can point to this same note. The number and body stay together.]
and keep the main text moving.

#v(7pt)
For repeated observations, the sample mean gives each value equal weight:

#align(center, text(size: 23pt)[
  #deixis-margin-note(mark-type: "region", inline: true, side: right,
    width: 160pt, dx: 24pt, padding: (x: 6pt, y: 9pt), radius: 4pt,
    layer: (mark: "background"),
    connector: (route: "curve", heads: (body: "stealth")),
  )[#box(inset: (x: 4pt, y: 6pt))[$overline(x) = 1/n sum_(i=1)^n x_i$]][*Explain The Notation* \
    A region can enclose a whole equation. Its explanation follows the measured bounds.]
])

#v(9pt)
Return to the #deixis-mark(of: <assumption>)[same assumption]
later in the discussion. Reuse adds another passage, rather than another note.

Small supporting details#deixis-footnote(series: "sources")[Native footnotes keep supporting material in the page footer.]
still have a place of their own.
