#import "../../src/lib.typ": *
#set page(width: 260pt, height: auto, margin: 12pt)
#set text(size: 13pt)
#let teal = rgb("32736D")
#show: deixis-setup-notes

// BEGIN EXAMPLE
#deixis-endnote(
  mark-type: "region", inline: true,
  layer: (mark: "background"),
  fill: teal.lighten(92%),
  stroke: teal,
)[$a^2 + b^2 = c^2$][
  A relation worth explaining.
]

#deixis-print-endnotes()
// END EXAMPLE
