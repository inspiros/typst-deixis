#import "@preview/deixis:0.2.0": *
#set page(width: 490pt, height: 350pt, margin: 40pt)
#set text(size: 11pt)
#show: deixis-setup-notes

= Notes Inside A Block

#deixis-block(id: <first>, thread: <reading>, inset: 12pt, stroke: gray, radius: 4pt)[
  This block has its own note#deixis-footnote[Printed at the end of this block.].
]

A thread lets a later block continue the same numbering. Strings and labels
name the same thread.

#deixis-block(id: "last", thread: "reading", inset: 12pt, stroke: gray, radius: 4pt)[
  The next block continues the series#deixis-footnote[Number two, printed in the second block.].
]

The surrounding document has a separate counter#deixis-footnote[A page footnote, numbered independently.].
