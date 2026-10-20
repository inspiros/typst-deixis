#import "../../src/lib.typ": *
#set page(width: 260pt, height: 75pt, margin: 12pt)
#set text(size: 13pt)
#let teal = rgb("32736D")
#show: deixis-setup-notes

// BEGIN EXAMPLE
#grid(columns: (1fr, 1fr),
  gutter: 45pt,
  deixis-attach(id: <a>,
    rect(inset: 5pt)[Source]),
  deixis-attach(id: <b>,
    rect(inset: 5pt)[Target]),
)
#deixis-connect(
  from: (node: <a>),
  to: (node: <b>),
  connector: (heads: "stealth"),
)
// END EXAMPLE
