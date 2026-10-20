#import "@preview/deixis:0.2.0": *
#set page(width: 540pt, height: 360pt, margin: 40pt)
#set text(size: 11pt)
#show: deixis-setup-notes

= Notes Within A Local Scope

A callout can contain an independent note scope.

#deixis-mark(id: <reading>, stroke: teal)[The main passage]
#deixis-inset-note-body(of: <reading>, layer: "foreground", width: 315pt,
  placement: body => place(top + left, dx: 40pt, dy: 110pt, body),
  stroke: teal, fill: teal.lighten(96%),
  container-func: deixis-rect-container, container-args: (inset: 8pt))[
  #deixis-block(inset: 4pt)[
    A local detail#deixis-mark(id: <detail>, stroke: teal).
    #deixis-inline-note-body(of: <detail>, inline: false)[
      This annotation starts a separate numbering stream inside the callout.
    ]
  ]
]

#v(120pt)
The document continues#deixis-footnote[This is document note two.].
See @detail for the local explanation.
