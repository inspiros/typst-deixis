#set page(width: 300pt, height: 240pt, margin: (x: 2.5cm, rest: 1cm))

#import "../src/lib.typ": *
#show: deixis-setup-notes
#show raw: set text(size: 0.85em)

#deixis-inline-mark(
  id: <celibate>,  // linked to no note body
)[A celibate marked text]
#deixis-footnote(
  stroke: gray,
)[A footnote.]
#deixis-endnote(
  stroke: green,
  fill: green.transparentize(95%),
  numbering: "i",
)[An endnote.]
#deixis-margin-note(
  stroke: orange,
  fill: orange.transparentize(95%),
  container-func: rect,
)[A margin note.]
#deixis-inset-note(
  stroke: blue,
  fill: blue.transparentize(95%),
  placement: body => deixis-absolute-place(top + left, dx: 5pt, dy: 5pt, body),
)[An inset note.]

#deixis-note-outline(
  fill: repeat[.],
  include-celibates: "mark",
)
