#import "@preview/deixis:0.2.0": *
#set page(width: 500pt, height: 270pt, margin: 30pt)
#set text(size: 11pt)
#show: deixis-setup-notes
= Routing Measured Content

#deixis-inset-note-body(id: <answer>, layer: "foreground", width: 90pt,
  placement: body => place(top + left, dx: 330pt, dy: 80pt, body),
  fill: blue.lighten(92%), stroke: blue + 0.6pt)[An annotation body is just another node.]
#place(top + left, dx: 10pt, dy: 85pt,
  deixis-attach(prefix: none, pins: ((<input-tl>, (anchor: top + left)), (<input-br>, (anchor: bottom + right))),
    rect(width: 65pt, height: 35pt, inset: 6pt)[Input]))
#place(top + left, dx: 140pt, dy: 55pt,
  deixis-attach(prefix: none,
    pins: ((<tl>, (anchor: top + left)), (<br>, (anchor: bottom + right))),
    rect(width: 65pt, height: 100pt, fill: luma(235), inset: 6pt)[Obstacle]))

#context {
  let scene = deixis-routing-scene(nodes: (
    (id: <a>, pins: (<input-tl>, <input-br>)),
    (id: <b>, body: <answer>),
    (pins: (<tl>, <br>)),
  ))
  let route = deixis-route(scene: scene, from: <a>, to: <b>, route: "orthogonal")
  assert.eq(route.status, "ok")
  let request = deixis-prepare-connector(route, stroke: blue + 1pt, heads: "triangle")
  deixis-absolute-place(top + left, dx: route.origin.first(), dy: route.origin.last(),
    deixis-render-connector(request))
}

#v(145pt)
Pins supply the figure's geometry; the body supplies its accepted frame.
