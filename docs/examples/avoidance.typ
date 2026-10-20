#import "../../src/lib.typ": *
#set page(width: 260pt, height: 140pt, margin: 12pt)
#set text(size: 13pt)
#let teal = rgb("32736D")
#show: deixis-setup-notes

// BEGIN EXAMPLE
#show: deixis-routing.with(
  policy: "avoid", clearance: 5pt)
#let node(id, body) = deixis-attach(
  id: id, rect(inset: 6pt, body))
#grid(columns: (auto, auto, auto),
  gutter: 25pt, align: horizon,
  node(<a>)[A],
  deixis-attach(behavior: "avoid",
    rect(width: 45pt, height: 65pt,
      fill: luma(235), stroke: none)),
  node(<b>)[B],
)
#deixis-connect(from: (node: <a>),
  to: (node: <b>),
  connector: (heads: "stealth"))
// END EXAMPLE
