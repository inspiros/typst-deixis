#set page(width: 300pt, height: 240pt, margin: (x: 1cm, rest: 1cm))

#import "../src/lib.typ": *
#show: deixis-setup-notes
#show raw: set text(size: 0.85em)

#set par(justify: true)

Le
#deixis-inline-mark(  // celibate mark
  inline-mode: "underline",
  stroke: gray,
  fill: gray.transparentize(90%),
)[chercheur]
a ressenti un immense
#deixis-inline-mark(id: <soulagement>,
  stroke: red,
  fill: red.transparentize(95%),
)[soulagement]
en découvrant enfin la
#deixis-inline-mark(id: <cle-de-voute>,
  stroke: teal,
  fill: teal.transparentize(95%),
)[clé de voûte]
de son argumentation.

#deixis-inline-note-body(id: <soulagement>)[
  *soulagement*: Relief.
]
#deixis-inline-note-body(id: <cle-de-voute>)[
  *clé de voûte*: Keystone _(metaphorically: the cornerstone or central principle of an argument)_.
]
#deixis-inline-note-body(  // celibate note
  stroke: gray,
  fill: gray.transparentize(95%),
)[
  Without an unique `id`, standalone bodies become celibate (no marker) like this one.
]
