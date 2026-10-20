#import "@preview/deixis:0.2.0": *
#set page(width: 360pt, height: 210pt, margin: 20pt)
#set text(size: 10pt)
= Routing Around Shapes

// These ordinary drawing nodes have no note counters or body registration.
#let nodes = (
  (id: <input>, bounds: (left: 10pt, top: 40pt, right: 65pt, bottom: 70pt)),
  (id: <output>, bounds: (left: 250pt, top: 40pt, right: 305pt, bottom: 70pt)),
  (id: <obstacle>, bounds: (left: 100pt, top: 25pt, right: 145pt, bottom: 90pt)),
  (id: <window>, behavior: "cut", bounds: (left: 175pt, top: 0pt, right: 195pt, bottom: 115pt)),
)
#let scene = deixis-routing-scene(nodes: nodes)
#let path = deixis-route(scene: scene, from: <input>, to: <output>, route: "orthogonal")
#assert.eq(path.status, "ok")
#block(width: 320pt, height: 125pt)[
  #for node in nodes {
    let b = node.bounds
    place(top + left, dx: b.left, dy: b.top,
      rect(width: b.right - b.left, height: b.bottom - b.top,
        fill: if node.at("behavior", default: "avoid") == "cut" { blue.lighten(90%) } else { luma(240) },
        stroke: luma(175) + 0.5pt))
  }
  #context {
    let request = deixis-prepare-connector(path, stroke: blue + 1pt, heads: "triangle")
    place(top + left, dx: path.origin.first(), dy: path.origin.last(), deixis-render-connector(request))
  }
]
The route avoids the middle box and disappears inside the pale window.
