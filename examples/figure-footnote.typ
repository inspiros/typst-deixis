#import "@preview/deixis:0.2.0": *
#set page(width: 480pt, height: 360pt, margin: 35pt)
#set text(size: 11pt)
#show: deixis-setup-notes

= A Note About A Floating Figure

#figure(placement: top, scope: "parent", caption: [A shared illustration.])[
  #rect(width: 100%, inset: 16pt, fill: rgb("eef5f8"), stroke: rgb("8baab7"))[
    An important diagram#deixis-mark(id: <diagram>).
  ]
]

// Keep the mark in the parent-scope float. Put the native page-footer
// allocation in main flow; its declaration determines the footer page.
#deixis-footnote-body(of: <diagram>)[
  A source or qualification for the diagram.
]
The illustration carries the mark; this paragraph allocates its footnote.
The two declarations share an ID and one number.

For a floating figure in the ordinary column scope, a direct call works:
#figure(placement: bottom, caption: [A local illustration.])[
  #rect(width: 100%, inset: 16pt, fill: rgb("f4f2ec"), stroke: rgb("b3a37d"))[
    Another diagram#deixis-footnote[A note allocated by the column-scope float.].
  ]
]
