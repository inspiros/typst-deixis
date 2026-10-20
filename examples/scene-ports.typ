#import "@preview/deixis:0.2.0": *
#set page(width: 480pt, height: 270pt, margin: 30pt)
#set text(size: 11pt)
#show: deixis-setup-notes
= A Clear Way Out

#place(top + left, dx: 15pt, dy: 85pt,
  deixis-mark(id: <card>, mark-type: "region", inline: true,
    marker: none, stroke: blue + 0.7pt, fill: blue.transparentize(94%))[
    #box(width: 65pt, height: 35pt, align(center + horizon)[Source])
  ])

#place(top + left, dx: 80pt, dy: 65pt,
  deixis-attach(prefix: none, pins: (tl: (anchor: top + left), br: (anchor: bottom + right)),
    rect(width: 45pt, height: 85pt, fill: luma(235), stroke: luma(180) + 0.5pt,
      align(center + horizon, rotate(-90deg)[A Wall]))))

#deixis-inset-note-body(of: <card>, width: 105pt,
  placement: body => place(top + left, dx: 300pt, dy: 90pt, body),
  fill: blue.lighten(94%), stroke: blue + 0.7pt,
  connector: (route: "orthogonal", radius: 0pt, stroke: blue + 1pt,
    heads: "triangle", scene: _ => deixis-routing-scene(nodes: (
      (mark: <card>), (body: <card>), (pins: (<tl>, <br>)),
    ))))[
  The nearest exit is blocked. Another permitted port provides a clear route.
]

#v(165pt)
A scene enables avoidance and automatic port fallback. Explicit sockets stay fixed.
