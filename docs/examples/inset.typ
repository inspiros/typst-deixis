#import "../../src/lib.typ": *
#set page(width: 260pt, height: 145pt, margin: 12pt)
#set text(size: 13pt)
#let teal = rgb("32736D")
#show: deixis-setup-notes

// BEGIN EXAMPLE
An #deixis-inset-note(
  layer: "foreground", width: 90pt,
  dx: 95pt, dy: 38pt,
  connector: (route: "curve",
    heads: (body: "stealth")),
)[idea][A compact explanation.]
can point to a callout.
// END EXAMPLE
