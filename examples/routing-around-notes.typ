#import "@preview/deixis:0.2.0": *
#set page(width: 420pt, height: 300pt, margin: 25pt)
#set text(size: 10pt)
#show: deixis-setup-notes
#show: deixis-routing.with(policy: "avoid", nodes: ((body: <detail>),))
= Routing Around A Note

Register an existing note body by its ID. Its accepted frame becomes an obstacle;
its position and content stay unchanged.
#let card(id, x, body) = place(top + left, dx: x, dy: 110pt,
  deixis-attach(id: id, rect(width: 55pt, height: 26pt, inset: 3pt,
    radius: 3pt, fill: white, stroke: luma(150) + 0.6pt,
    align(center + horizon, body))))
#card(<a>, 10pt)[Source]
#card(<b>, 305pt)[Target]
#deixis-connect(from: (node: <a>), to: (node: <b>),
  connector: (stroke: blue + 1pt, heads: "triangle"))
#deixis-inset-note-body(id: <detail>, connector: none, width: 100pt,
  fill: blue.lighten(95%), stroke: blue + 0.5pt, radius: 3pt,
  placement: x => place(top + left, dx: 135pt, dy: 85pt, x))[
  #block(height: 70pt)[An ordinary note body. No extra routing wrapper or ID is needed here.]
]
#place(top + left, dy: 220pt, block(width: 365pt)[
  Use `behavior: "ignore"`, `"cut"` or `"cross"` in the node entry to change
  how the scope treats this frame. Omit `nodes:` to keep the default behavior.
])
