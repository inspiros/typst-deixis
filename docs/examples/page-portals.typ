#import "../../src/lib.typ": *
#set page(width: 260pt, height: 135pt, margin: 12pt)
#set text(size: 13pt)
#let teal = rgb("32736D")
#show: deixis-setup-notes

// BEGIN EXAMPLE
#deixis-mark(id: <across>)[Start Here]
#pagebreak()
#deixis-inset-note-body(of: <across>,
  layer: "foreground", width: 95pt,
  dx: 95pt, dy: 40pt,
  connector: (route: "orthogonal",
    continuation: "portal",
    heads: (body: "stealth")),
)[The explanation is on page two.]
Destination Page.
// END EXAMPLE
