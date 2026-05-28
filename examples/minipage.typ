#set page(width: 300pt, height: 240pt, margin: 1cm)

#import "@preview/deixis:0.1.0": *
#show: deixis-setup-notes
#show raw: set text(size: 0.85em)

Notice the numbers#deixis-footnote[A page-level footnote.].
#deixis-block(
  id: <gray-block>,
  fill: gray.lighten(80%),
  inset: (right: 2cm, rest: 5pt),
)[
  Minipages are very handy for creating locally rendered notes
  #deixis-footnote[A block-level footnote.]
  #deixis-margin-note[A block-level margin note.].
]

#deixis-block(
  sync-counters-with: <gray-block>,
  fill: green.lighten(80%),
  inset: 5pt,
)[
  Moreover, they can maintain a separate counter system, or sync with each other #deixis-footnote[This block shares the counters with ```typst <gray-block>.```].
]
