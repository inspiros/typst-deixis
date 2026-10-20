#import "../../src/lib.typ": *
#set page(width: 260pt, height: auto, margin: 12pt)
#set text(size: 13pt)
#let teal = rgb("32736D")
#show: deixis-setup-notes

// BEGIN EXAMPLE
A detail#deixis-endnote(
  container-func: deixis-rect-container,
  container-args: (inset: 7pt),
  stroke: (mark: none, body: teal),
)[A boxed explanation.]

#deixis-print-endnotes(
  render-group:
    deixis-native-render-group,
)
// END EXAMPLE
