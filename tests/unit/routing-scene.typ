#import "../../src/lib.typ": *
#import "../../src/routing/scene-index.typ": _deixis-scene-index, _deixis-index-blocked

#let box(l, t, r, b) = (left: l*1pt, top: t*1pt, right: r*1pt, bottom: b*1pt)
#let a = (id: <source>, bounds: box(0, 20, 20, 40))
#let b = (id: "target", bounds: box(160, 20, 180, 40))
#let middle = (id: <obstacle>, bounds: box(60, 10, 90, 50))
#let scene = deixis-routing-scene(nodes: (a, b, middle))
#let route = deixis-route(scene: scene, from: "source", to: <target>, route: "orthogonal")
#assert.eq(route.status, "ok")
#assert.eq(route.origin, (20pt, 30pt))
#assert.eq(route.end, (140pt, 0pt))
#assert.eq(route.start-tangent, (1, 0))
#assert.eq(route.end-tangent, (1, 0))
#assert.eq(route.interactions, ())
#assert.eq(route.scene-cuts, ())
#assert(route.segments.any(s => s.end.last() in (-24pt, 24pt)))
// Repeated routes share an immutable prepared scene. Enumeration is irrelevant
// to geometric choices; endpoint IDs are normalized independently of note IDs.
#let other = deixis-route(scene: deixis-routing-scene(nodes: (middle, b, a)),
  from: <source>, to: "target", route: "orthogonal")
#assert.eq(other, route)
#assert.eq(deixis-route(scene: scene, from: (node: <source>, side: right, at: 50%),
  to: (node: <target>, side: left), route: "orthogonal"), route)
#assert.eq(deixis-route(scene: scene, from: (point: route.origin, normal: right, owner: <source>),
  to: (node: <target>, side: left), route: "orthogonal"), route)
#let bad = deixis-route(scene: deixis-routing-scene(nodes: (a, b, middle,
  (bounds: box(20, 25, 30, 35)))), from: <source>, to: <target>, route: "orthogonal")
#assert.eq(bad.status, "endpoint-blocked")
#let blocked = deixis-route(scene: scene, from: <source>, to: <target>,
  route: "orthogonal", via: ((75pt, 30pt),))
#assert.eq(blocked.status, "waypoint-blocked")
#assert.eq(deixis-route(scene: deixis-routing-scene(nodes: (middle,), max-cells: 1),
  from: (0pt, 0pt), to: (150pt, 0pt), route: "orthogonal").status, "budget")
// Page planes never acquire foreign or unpaged obstacles, including different
// physical page sizes. Page is inferred only from named endpoints on one plane.
#let paged = deixis-routing-scene(nodes: (middle,
  a + (page: 1), b + (page: 1),
  (id: <foreign>, bounds: box(60, 0, 90, 100), page: 2)),
  pages: ((page: 1, bounds: box(0, 0, 200, 100)), (page: 2, bounds: box(0, 0, 300, 200))))
#let first = deixis-route(scene: paged, from: <source>, to: <target>, route: "orthogonal")
#assert.eq(first.page, 1)
#assert.eq(first.length, 140pt)
#let second = deixis-route(scene: paged, page: 2, from: (10pt, 50pt), to: (180pt, 50pt), route: "orthogonal")
#assert.eq(second.page, 2)
#assert(second.length > 170pt)
// Open intervals preserve a channel exactly on two touching rectangle borders.
#let index = _deixis-scene-index(((left: 0, top: 0, right: 10, bottom: 10),
  (left: 10, top: 0, right: 20, bottom: 10)))
#assert(not _deixis-index-blocked(index, 5, 10, 10))
#assert(_deixis-index-blocked(index, 5, 9, 11))
#let zero = deixis-route(scene: deixis-routing-scene(), from: (1pt, 1pt), to: (1pt, 1pt), route: "orthogonal")
#assert.eq(zero.segments, ())
#assert.eq(zero.length, 0pt)
// Cut/cross are independent of avoidance and work for ordinary native routes.
#let interactions = deixis-routing-scene(nodes: (
  (id: <ignored>, behavior: "ignore", bounds: box(20, -10, 30, 10)),
  (id: <window>, behavior: "cut", bounds: box(40, -10, 60, 10)),
  (id: <crossed>, behavior: "cross", bounds: box(80, -10, 90, 10))))
#let straight = deixis-route(scene: interactions, from: (0pt, 0pt), to: (100pt, 0pt))
#assert.eq(straight.interactions.map(e => (e.node, e.behavior)), (("window", "cut"), ("crossed", "cross")))
#for (hit, expected) in straight.interactions.zip(((40pt, 60pt), (80pt, 90pt))) {
  assert(calc.abs(hit.from - expected.first()) < 0.00001pt and calc.abs(hit.to - expected.last()) < 0.00001pt)
}
#context {
  let prepared = deixis-prepare-connector(straight, cuts: (from: 50pt, to: 70pt))
  assert.eq(prepared.cuts.len(), 1)
  assert(calc.abs(prepared.cuts.first().from - 40pt) < 0.00001pt and prepared.cuts.first().to == 70pt)
  assert.eq(prepared.shaft.len(), 2)
  assert(calc.abs(prepared.shaft.first().end.first() - 40pt) < 0.00001pt)
  assert.eq(prepared.shaft.last().start, (70pt, 0pt))
  assert.eq(prepared.route.segments, straight.segments)
}
