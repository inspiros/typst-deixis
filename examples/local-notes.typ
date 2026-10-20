#import "@preview/deixis:0.2.0": *
#set page(width: 440pt, height: 400pt, margin: 32pt, numbering: "1")
#set text(size: 11pt)
#show: deixis-setup-notes

= Table Notes

// Wrap the complete object and caption. Notes collect after both.
#deixis-block[
  #figure(
    kind: table,
    caption: [Measured values#deixis-footnote(numbering: "a")[All values use the same calibration.].],
  )[
    #table(
      columns: (1fr, 1fr), inset: 8pt,
      table.header([Sample], [Result]),
      [Control], [12.4],
      [Treatment], [18.7#deixis-footnote(numbering: "a")[The treatment mean excludes one damaged sample.]],
    )
  ]
]

The local series ends with the table. Ordinary prose uses its own numbering
#deixis-footnote[This is a page footnote, independently numbered.].

#pagebreak()
= Floating Figure Notes

// Float the complete local block, including its figure, caption and notes.
// Use one ordinary inner figure to keep native figure numbering/references.
#place(bottom, float: true, scope: "parent")[
  #deixis-block[
    #figure(caption: [A local explanation#deixis-footnote(numbering: "a")[The caption shares the diagram's note series.].])[
      #rect(width: 100%, height: 52pt, inset: 12pt,
        fill: rgb("eef3f6"), stroke: rgb("8da5b3"))[
        A diagram#deixis-footnote(numbering: "a")[This note moves with the diagram, even in a parent-scope float.].
      ]
    ]
  ]
]
The floating unit contains the diagram, its caption, and the local collection.
No page-footer allocation is needed inside the float.

#pagebreak()
= Repeating Table Headers

// A long native figure needs a breakable block. Its caption appears once.
#show figure: set block(breakable: true)
#deixis-block(breakable: true)[
  #figure(
    kind: table,
    caption: [Repeated measurements#deixis-mark(id: <units>, numbering: "a").],
  )[
    #table(
      columns: (1fr, 1fr), inset: 7pt,
      // Reuse has no occurrence name: each header copy is a distinct mark.
      table.header([Sample], [Value#deixis-mark(of: <units>)]),
      ..range(1, 15).map(i => ([Sample #i], [#lorem(9)])).flatten(),
    )
  ]
  #deixis-footnote-body(of: <units>, backlink: true)[
    All values share one unit convention. The caption creates the annotation
    once; each header reuses its mark, including before that declaration.
  ]
]
