#import "../../src/lib.typ": *
#set page(width: 260pt, height: auto, margin: 12pt)
#set text(size: 13pt)
#let teal = rgb("32736D")
#show: deixis-setup-notes

// BEGIN EXAMPLE
#deixis-attach(prefix: none,
  pins: (
    begin: (anchor: top + left),
    end: (anchor: bottom + right),
  ),
  rect(inset: 12pt, stroke: none)[
    $sum_(i=1)^n i = (n(n+1))/2$
  ],
)
#deixis-region-mark(
  pins: (<begin>, <end>),
  padding: 3pt, stroke: teal,
)
// END EXAMPLE
