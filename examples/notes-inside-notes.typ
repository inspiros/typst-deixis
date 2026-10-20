#import "@preview/deixis:0.2.0": *
#set page(width: 560pt, height: 310pt, margin: (x: 120pt, y: 38pt))
#set text(size: 11pt)
#show: deixis-setup-notes

#text(size: 19pt, weight: "bold")[An Explanation Can Have A Note]

A note's contents can introduce another annotation, with its own number and body.

#deixis-margin-note(width: 105pt, side: right, backlink: true)[
  A compact definition
][
  A #deixis-inline-mark(id: <detail>)[local explanation] may need more context.
]

#deixis-inset-note-body(of: <detail>, layer: "foreground", width: 205pt,
  placement: it => place(top + left, dx: 120pt, dy: 190pt, it),
  backlink: true, stroke: teal, fill: teal.lighten(95%))[
  This second note belongs to the marked passage inside the margin note.
  Its number follows the first note's number.
]
