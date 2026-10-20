#import "@preview/deixis:0.2.0": *
#set page(width: 460pt, height: 240pt, margin: (x: 105pt, y: 30pt))
#set text(size: 10pt)
#show: deixis-setup-notes
#deixis-set(overflow: "error")

= Check The Final Frame

The first annotation#deixis-margin-note(side: right, width: 90pt)[
  #block(height: 100pt)[This explanation fits beside the first page.]
] leaves little margin space.

A second annotation#deixis-margin-note(side: right, width: 90pt)[
  #block(height: 100pt)[This one spills into the next available page.]
] needs another frame.

#pagebreak()
= Use The Next Frame

Checking overflow uses the final placement after spillover.
It does not add pages or change the route.

Use `overflow: "allow"` on a note to retain deliberate out-of-frame placement.
