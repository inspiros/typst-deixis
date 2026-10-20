#import "../../src/lib.typ": *
#set page(width: 260pt, height: auto, margin: 12pt)
#set text(size: 13pt)
#show: deixis-setup-notes

// BEGIN EXAMPLE
#deixis-set(stroke: blue)
#deixis-mark[Outer Style]

#deixis-block(inset: 5pt)[
  #deixis-set(stroke: orange)
  #deixis-mark[Local Style]
]

#deixis-mark[Outer Style Again]
// END EXAMPLE
