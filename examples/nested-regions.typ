#import "@preview/deixis:0.2.0": *
#set page(width: 470pt, height: 330pt, margin: 40pt)
#set text(size: 11pt)
#show: deixis-setup-notes
#let highlight = deixis-region-mark.with(
  inline: true, layer: "foreground", stroke: teal + 0.7pt, padding: 3pt, radius: 2pt,
)

#text(size: 19pt, weight: "bold")[Regions Beyond Prose]

A region can enclose #highlight[$f(x) = x^2$] or #highlight[`square(x)`].

Regions also work inside tables and other regions:

#deixis-region-mark(layer: "foreground", stroke: gray + 0.5pt, padding: 5pt, radius: 4pt)[
  #table(
    columns: (auto, auto), inset: 9pt, stroke: none,
    table.header([*Function*], [*Output Range*]),
    [Sigmoid], [$0 < y < 1$],
    [ReLU], [#deixis-footnote(mark-type: "region", inline: true,
      layer: (mark: "foreground", body: "flow"), stroke: teal + 0.7pt,
      padding: 3pt, radius: 2pt)[$y >= 0$][A region mark can share an identity with an ordinary note body.]],
  )
]
