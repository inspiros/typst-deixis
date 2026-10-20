#import "@preview/deixis:0.2.0": *
#set page(width: 550pt, height: 300pt, margin: (x: 110pt, y: 35pt))
#set text(size: 11pt)
#show: deixis-setup-notes

#text(size: 19pt, weight: "bold")[Regions Inside Notes]

A note can highlight its own formula while its body is measured and positioned.

#deixis-inline-mark(id: <formula>)[A formula worth explaining].
#deixis-margin-note-body(of: <formula>, width: 95pt, side: right, backlink: true)[
  The same relation:
  #deixis-region-mark(of: <formula>, marker: none, inline: true, layer: "flow",
    stroke: teal, fill: teal.lighten(92%), padding: 2pt)[$x^2 + y^2$].
]

#deixis-inset-note(layer: "foreground", width: 175pt,
  placement: it => place(top + left, dx: 110pt, dy: 175pt, it))[
  A different expression
][
  A region can also wrap a block:
  #deixis-region-mark(layer: "flow", stroke: blue, padding: 3pt)[
    $f(x) = frac(1, 1 + e^(-x))$
  ]
  Its painter runs only in the live body.
]
