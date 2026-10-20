#import "../../src/lib.typ": *
#set page(width: 380pt, height: 250pt, margin: 30pt)
#show: deixis-setup-notes
#deixis-mark(id: <n>)[Original]
#deixis-pin(<top>, padding: 0pt)
#deixis-region-mark(of: <n>, occurrence: <region>, padding: 3pt)[
  First Page
  #colbreak()
  Second Page
  #colbreak()
  Last Page
]
#set page(width: 460pt, height: 280pt)
#deixis-pin(<bottom>, padding: 0pt)
#deixis-inset-note-body(of: <n>, connector: none, width: 70pt, layer: "foreground")[Body]
#context {
  let scene = deixis-routing-scene(nodes: (
    (id: <first>, mark: <n>),
    (id: <fragment>, mark: <n>, occurrence: <region>, page: 2),
    (id: <last>, body: <n>),
    (id: <top>, pin: <top>), (id: <bottom>, pin: <bottom>)))
  assert.eq(scene.nodes.map(n => n.page), (1, 2, 4, 1, 4))
  let region = scene.nodes.at(scene.ids.at("fragment"))
  assert.eq(region.bounds.top, 30pt)
  assert.eq(region.bounds.bottom, 220pt)
  let one = scene.planes.find(p => p.page == 1)
  let last = scene.planes.find(p => p.page == 4)
  assert.eq(one.bounds.right, 380)
  assert.eq(last.bounds.right, 460)
  assert.eq(one.nodes.map(n => n.id), ("first", "top"))
  assert.eq(last.nodes.map(n => n.id), ("last", "bottom"))
  let route = deixis-route(scene: scene, from: <top>, to: (0pt, 0pt), route: "orthogonal")
  assert.eq(route.page, 1)
}
