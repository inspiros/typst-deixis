#import "@preview/deixis:0.2.0": *
#set page(width: 340pt, height: 225pt, margin: 20pt)
#set text(size: 10pt)
= Routing A Small Group

#let nodes = (
  (id: <hub>, behavior: "ignore", bounds: (left: 25pt, top: 45pt, right: 25pt, bottom: 45pt)),
  (id: <first>, bounds: (left: 220pt, top: 30pt, right: 280pt, bottom: 60pt)),
  (id: <second>, bounds: (left: 180pt, top: 85pt, right: 240pt, bottom: 115pt)),
)
#let scene = deixis-routing-scene(nodes: nodes, escape: 8pt)
#let plan = deixis-route-group(scene: scene, spacing: 8pt, (
  (from: (node: <hub>, side: right), to: <first>),
  (from: (node: <hub>, side: right), to: <second>),
))
#assert(plan.routes.all(r => r.status == "ok"))
#block(width: 300pt, height: 130pt)[
  #context for (index, path) in plan.routes.enumerate() {
    let request = deixis-prepare-connector(path,
      stroke: (blue, orange).at(index) + 1pt, heads: "triangle")
    place(top + left, dx: path.origin.first(), dy: path.origin.last(), deixis-render-connector(request))
  }
  #place(top + left, dx: 15pt, dy: 40pt, circle(radius: 5pt, fill: luma(235), stroke: black + 0.6pt))
  #for (node, caption) in nodes.slice(1).zip(([First], [Second])) {
    let b = node.bounds
    place(top + left, dx: b.left, dy: b.top,
      rect(width: b.right - b.left, height: b.bottom - b.top, fill: luma(245),
        stroke: luma(160) + 0.6pt, inset: 6pt)[#align(center + horizon, caption)])
  }
]
The connectors share the hub's short exit. Each result uses the ordinary arrow
painter; this drawing needs no note setup.
