#import "@preview/deixis:0.2.0": *
#set page(width: 480pt, height: 280pt, margin: 30pt)
#set text(size: 11pt)
#show: deixis-setup-notes
= An Exit Along The Same Side

#place(top + left, dx: 15pt, dy: 80pt,
  deixis-mark(id: <card>, mark-type: "region", inline: true, marker: none,
    stroke: blue + 0.7pt, fill: blue.transparentize(94%))[
    #box(width: 65pt, height: 55pt, align(center + horizon)[Source])
  ])
#place(top + left, dx: 80pt, dy: 60pt,
  deixis-attach(prefix: none, pins: (tl: (anchor: top + left), br: (anchor: bottom + right)),
    rect(width: 45pt, height: 50pt, fill: luma(235), stroke: luma(180) + 0.5pt,
      align(center + horizon, rotate(-90deg)[A Wall]))))

#deixis-inset-note-body(of: <card>, width: 105pt,
  placement: body => place(top + left, dx: 300pt, dy: 80pt, body),
  fill: blue.lighten(94%), stroke: blue + 0.7pt,
  connector: (route: "orthogonal", radius: 0pt, stroke: blue + 1pt,
    ports: (mark: right, body: left), heads: "triangle",
    scene: _ => deixis-routing-scene(nodes: (
      (mark: <card>), (body: <card>), (pins: (<tl>, <br>)),
    ))))[
  The right side is fixed; the attachment can slide past the wall.
]

#v(180pt)
Use a bare side for automatic attachment. Add `at: 50%` to lock its midpoint.
