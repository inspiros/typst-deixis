#set page(width: 300pt, height: 240pt, margin: (x: 1cm, rest: 1cm))

#import "@preview/deixis:0.1.0": *
#show: deixis-setup-notes
#show raw: set text(size: 0.85em)

#lorem(10)
#deixis-footnote[A plain footnote.]
#lorem(10)
#deixis-footnote(marker: lorem(2))[
  A footnote with very long marker, aligned with other notes.
]
#deixis-footnote-body[
  A celibate footnote body without linked mark.
]

#lorem(10)
#deixis-footnote(
  marker-style: (body: it => text(fill: orange, super(it))),
  stroke: red,
  fill: red.transparentize(95%),
  container-func: deixis-alert-container,
)[A marked text][A colorful footnote.].
