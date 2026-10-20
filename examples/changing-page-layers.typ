#import "@preview/deixis:0.2.0": *
#set page(width: 440pt, height: 270pt, margin: (left: 35pt, right: 130pt, y: 35pt),
  foreground: place(top + right, dx: -15pt, dy: 12pt, text(size: 8pt, fill: gray)[Draft]))
#set text(size: 11pt)
// Bind setup once; nondefault setup options belong in this binding too.
#let annotations = deixis-setup-notes
#show: annotations
= The First Page Style
This page keeps its native Draft decoration and the Deixis overlay.

#v(25pt)
#deixis-margin-note(id: <first>, side: right, width: 95pt,
  connector: (route: "orthogonal", radius: 0pt, stroke: blue + 0.8pt))[A first passage][The first annotation.]

#pagebreak()
#set page(foreground: place(top + right, dx: -15pt, dy: 12pt, text(size: 8pt, fill: blue)[Reviewed]))
// Restore overlay composition after replacing one native page layer.
#show: annotations
= A Different Page Style
Replacing the foreground changes its decoration. Reapplying setup restores the
annotation compositor without resetting note identities or numbering.

#v(20pt)
#deixis-margin-note(id: <second>, side: right, width: 95pt,
  connector: (route: "orthogonal", radius: 0pt, stroke: blue + 0.8pt))[A second passage][The next annotation.]

The earlier note is still available: @first.
