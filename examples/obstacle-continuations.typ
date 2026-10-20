#import "@preview/deixis:0.2.0": *
#set page(width: 420pt, height: 280pt, margin: 30pt)
#set text(size: 11pt)
#show: deixis-setup-notes
#let scene(doc) = deixis-routing-scene(nodes: (
  (mark: <detail>), (body: <detail>),
  (pins: ((name: "tl", page: doc.page), (name: "br", page: doc.page))),
))
#let continuation(request) = place(right + horizon, dx: -4pt,
  link(request.peer.destination, text(size: 8pt, fill: blue, [A → p. #request.peer-page])))

= A Connection Across Pages
#place(top + left, dy: 60pt, deixis-mark(id: <detail>, stroke: blue + 0.6pt)[Read This])
#place(top + left, dx: 10pt, dy: 205pt,
  deixis-attach(prefix: none, pins: (tl: (anchor: top + left), br: (anchor: bottom + right)),
    rect(width: 150pt, height: 30pt, fill: luma(235), stroke: none,
      align(center + horizon)[Registered Obstacle])))
#v(80pt)
#block(width: 300pt, inset: (left: 50pt))[
The preferred continuation is blocked. The router chooses a reachable position
on this page's boundary.
]

#pagebreak()
#v(30pt)
= The Same Connection
#deixis-inset-note-body(of: <detail>, width: 95pt,
  placement: body => place(top + left, dx: 250pt, dy: 90pt, body),
  fill: blue.lighten(92%), stroke: blue + 0.6pt,
  connector: (route: "orthogonal", radius: 0pt, scene: scene,
    heads: "triangle", stroke: blue + 1pt, continuation: continuation))[
  Each page finds its own clear continuation. Both A markers link to the real peer.
]
#place(top + left, dx: 10pt, dy: -15pt,
  deixis-attach(prefix: none, pins: (tl: (anchor: top + left), br: (anchor: bottom + right)),
    rect(width: 150pt, height: 30pt, fill: luma(235), stroke: none)))
