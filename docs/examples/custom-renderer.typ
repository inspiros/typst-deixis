#import "../../src/lib.typ": *
#set page(width: 260pt, height: auto, margin: 12pt)
#set text(size: 13pt)
#let teal = rgb("32736D")
#show: deixis-setup-notes

// BEGIN EXAMPLE
#let card(n, ..args) = block(
  inset: 8pt, fill: teal.lighten(94%),
  stroke: (left: teal + 2pt),
)[
  #deixis-generate-body-marker(n)
  #deixis-generate-body-content(n)
]

#deixis-endnote(render-single: card)[
  A custom card with native links.
]
#deixis-print-endnotes(
  render-group:
    deixis-native-render-group,
)
// END EXAMPLE
