#import "@preview/deixis:0.2.0": *
#set page(width: 500pt, height: 280pt, margin: 30pt)
#set text(size: 11pt)
#show: deixis-setup-notes
= Notes Around Figures

#place(top + left, dy: 100pt, deixis-mark(id: <detail>, stroke: blue + 0.6pt)[A passage])
#deixis-inset-note-body(of: <detail>, width: 95pt,
  placement: body => place(top + left, dx: 325pt, dy: 95pt, body),
  fill: blue.lighten(92%), stroke: blue + 0.6pt,
  connector: (
    route: "orthogonal", radius: 0pt, heads: "triangle", stroke: blue + 1pt,
    scene: _ => deixis-routing-scene(nodes: (
      (mark: <detail>), (body: <detail>), (pins: (<tl>, <br>)),
    )),
  ))[The connector routes around the registered figure.]

#place(top + left, dx: 150pt, dy: 35pt,
  deixis-attach(prefix: none, pins: (tl: (anchor: top + left), br: (anchor: bottom + right)),
    rect(width: 75pt, height: 115pt, fill: luma(235), stroke: luma(170) + 0.5pt,
      align(center + horizon)[A Figure])))

#v(165pt)
Register fixed obstacles explicitly; notes keep their accepted positions.
