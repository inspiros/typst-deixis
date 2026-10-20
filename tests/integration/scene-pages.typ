#import "../../src/lib.typ": *
#set page(width: 280pt, height: 190pt, margin: 20pt)
#let bounds = (left: 0pt, top: 0pt, right: 220pt, bottom: 140pt)
#let obstacle = (left: 90pt, top: 30pt, right: 130pt, bottom: 90pt)
#let scene = deixis-routing-scene(nodes: (
  (id: <cut>, page: 1, behavior: "cut", bounds: obstacle),
  (id: <avoid>, page: 2, bounds: obstacle),
  (id: <cross>, page: 2, behavior: "cross", bounds: (left: 160pt, top: 0pt, right: 170pt, bottom: 140pt)),
  // Unpaged geometry must never leak into physical page routes.
  (bounds: (left: 0pt, top: 0pt, right: 220pt, bottom: 140pt))),
  pages: ((page: 1, bounds: bounds), (page: 2, bounds: bounds)))
#let draw(page) = context {
  let r = deixis-route(scene: scene, page: page, from: (10pt, 60pt), to: (210pt, 60pt), route: "orthogonal")
  assert.eq(r.status, "ok")
  assert.eq(r.interactions.map(e => e.page), (page,))
  assert.eq(r.interactions.first().behavior, if page == 1 { "cut" } else { "cross" })
  if page == 1 { assert.eq(r.length, 200pt) } else { assert(r.length > 200pt) }
  place(top + left, dx: obstacle.left, dy: obstacle.top,
    rect(width: obstacle.right - obstacle.left, height: obstacle.bottom - obstacle.top, fill: luma(235)))
  let request = deixis-prepare-connector(r, stroke: blue + 1pt, heads: "triangle")
  assert.eq(request.cuts.len(), if page == 1 { 1 } else { 0 })
  place(top + left, dx: r.origin.first(), dy: r.origin.last(), deixis-render-connector(request))
  [#metadata((page: page, length: r.length, cuts: request.cuts.len()))<scene-page>]
}
#draw(1)
Cut Node
#pagebreak()
#set page(width: 310pt, height: 210pt)
#draw(2)
Avoid And Cross Nodes
#context { assert.eq(query(<scene-page>).map(n => n.value.page), (1, 2)) }
