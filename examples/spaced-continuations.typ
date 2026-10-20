#import "@preview/deixis:0.2.0": *
#set page(width: 340pt, height: 260pt, margin: 25pt)
#set text(size: 10pt)
#show: deixis-setup-notes
#show: deixis-routing.with(spacing: 18pt, weight: 8)
#let card(id, x, y, body) = place(top + left, dx: x, dy: y,
  deixis-attach(id: id, rect(width: 60pt, height: 28pt, inset: 3pt,
    radius: 3pt, fill: white, stroke: luma(160) + 0.6pt,
    align(center + horizon, body))))
= Give Spill Points Room

The lines share a source. Automatic spill points can separate to give each
line room at the page edge.
#card(<source>, 115pt, 85pt)[One Source]
#for (id, color) in ((<a>, blue), (<b>, orange.darken(15%))) {
  deixis-connect(from: (node: <source>), to: (node: id), connector: (
    ports: (mark: bottom, body: top), stroke: color + 1pt, heads: "triangle"))
}
#pagebreak()
#set page(width: 380pt, height: 320pt)
#card(<a>, 20pt, 95pt)[Target A]
#card(<b>, 245pt, 125pt)[Target B]
#place(top + left, dy: 180pt, block(width: 330pt)[
  = Independent Page Geometry

  Each page uses its own dimensions and obstacles. The objects stay fixed.

  Use `policy: "avoid"` to skip separation repair, or an explicit split
  coordinate to keep a particular spill position.
])
