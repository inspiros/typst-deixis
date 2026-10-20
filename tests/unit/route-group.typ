#import "../../src/lib.typ": *

#let empty = deixis-route-group(())
#assert.eq(empty.routes, ())
#assert.eq(empty.stats, (searches: 0, expanded: 0, rounds: 0, limits-hit: ()))
#assert.eq(empty.quality.before, empty.quality.after)
#assert.eq(empty.quality.after.energy, 0pt)

#let edges = ((from: (0pt, 0pt), to: (100pt, 0pt)),
  (id: <second>, from: (0pt, 1pt), to: (100pt, 1pt)))
#let plan = deixis-route-group(edges)
#assert.eq(plan.kind, "deixis-route-group")
#assert.eq(plan.routes.map(r => (r.index, r.id, r.status)), ((0, none, "ok"), (1, "second", "ok")))
#assert.eq(plan.quality.before.exposure, 100pt)
#assert.eq(plan.quality.after.exposure, 0pt)
#assert(plan.quality.after.energy < plan.quality.before.energy)
#for (path, edge) in plan.routes.zip(edges) {
  assert.eq(path.origin, edge.from)
  assert.eq(path.end, edge.to.zip(edge.from).map(((a,b)) => a - b))
  assert.eq(path.interactions, ())
  assert.eq(path.scene-cuts, ())
}

// Independent plans remain directly comparable to ordinary single-route calls.
#let neutral = deixis-route-group(edges, weight: 0)
#let capped = deixis-route-group(edges, max-searches: 2)
#assert.eq(neutral.quality.before, neutral.quality.after)
#assert.eq(capped.stats.limits-hit, ("searches",))
#let no-growth = deixis-route-group(edges, max-detour: 0%)
#assert.eq(no-growth.quality.after, no-growth.quality.before)
#let initial-only = deixis-route-group(edges, rounds: 0)
#assert.eq(initial-only.stats.rounds, 0)
#assert(initial-only.quality.after.energy < initial-only.quality.before.energy)
#let partial = deixis-route-group(edges, max-searches: 1)
#assert.eq(partial.routes.map(r => r.status), ("ok", "budget"))
#assert.eq(partial.quality.after.missing, 1)
#assert(not ("segments" in partial.routes.last()))
#let scene = deixis-routing-scene()
#for (index, edge) in edges.enumerate() {
  let single = deixis-route(scene: scene, from: edge.from, to: edge.to, route: "orthogonal")
  assert.eq(neutral.routes.at(index), single + (id: if index == 0 { none } else { "second" }, index: index))
  assert.eq(capped.routes.at(index), neutral.routes.at(index))
}
#assert.eq(deixis-route-group((edges.first(), edges.last() + (id: "0"))).routes.map(r => r.id), (none, "0"))

// Scene sockets, labels and strings supply junction identity. The shared ink
// is limited to the actual common outward stub, not the surrounding band.
#let point = (left: 2pt, top: 10pt, right: 2pt, bottom: 10pt)
#let hub = deixis-routing-scene(nodes: ((id: <hub>, behavior: "ignore", bounds: point),),
  clearance: 0pt, escape: 1pt, bend-cost: 5pt)
#let shared = ((from: (node: <hub>, side: right), to: (38pt, 10pt)),
  (from: (node: "hub", side: right), to: (30pt, 18pt)))
#let joined = deixis-route-group(shared, scene: hub)
#assert.eq(joined.quality.after.shared, 1pt)
#assert.eq(joined.quality.after.overlap, 0pt)
#assert.eq(joined.quality.after.contacts, 0)
#let unnamed = shared.map(e => e + (from: (point: (2pt, 10pt), normal: right)))
#let anonymous = deixis-route-group(unnamed, scene: hub)
#assert.eq(anonymous.quality.after.shared, 0pt)
#assert(anonymous.quality.after.overlap >= 1pt)
#let aliases = deixis-routing-scene(nodes: (
  (id: <one>, behavior: "ignore", bounds: point), (id: <two>, behavior: "ignore", bounds: point)))
#let distinct = deixis-route-group(((from: <one>, to: (30pt, 20pt)),
  (from: <two>, to: (30pt, 0pt))), scene: aliases)
#assert.eq(distinct.quality.before.shared, 0pt)
#assert(distinct.quality.before.contacts > 0)

// Zero geometry and failures keep the ordinary native result contracts.
#let zero = deixis-route-group(((from: (1pt, 1pt), to: (1pt, 1pt)),))
#assert.eq(zero.routes.first().segments, ())
#assert.eq(zero.routes.first().length, 0pt)
#let failed = deixis-route-group(edges, scene: deixis-routing-scene(max-cells: 1))
#assert.eq(failed.quality.after.missing, 2)
#assert.eq(failed.stats.limits-hit, ("cells",))
#assert(failed.routes.all(r => r.kind == "deixis-route-failure" and r.status == "budget" and not ("segments" in r)))

// Only accepted geometry receives native scene cut/cross interaction records.
#let window = deixis-routing-scene(nodes: ((id: <window>, behavior: "cut",
  bounds: (left: 30pt, top: -10pt, right: 40pt, bottom: 10pt)),))
#let cut = deixis-route-group((edges.first(),), scene: window).routes.first()
#assert.eq(cut.interactions.map(e => e.behavior), ("cut",))
#context {
  let request = deixis-prepare-connector(cut)
  assert.eq(request.cuts.len(), 1)
  assert.eq(request.shaft.len(), 2)
}

// Input order is preserved across independent differently sized page planes.
#let paged = deixis-routing-scene(pages: (
  (page: 1, bounds: (left: 0pt, top: 0pt, right: 100pt, bottom: 80pt)),
  (page: 2, bounds: (left: 0pt, top: 0pt, right: 200pt, bottom: 120pt))))
#let pages = deixis-route-group((
  (id: <same>, page: 2, from: (10pt, 10pt), to: (190pt, 10pt)),
  (id: "same", page: 1, from: (10pt, 10pt), to: (90pt, 10pt))), scene: paged)
#assert.eq(pages.routes.map(r => (r.id, r.page, r.length)), (("same", 2, 180pt), ("same", 1, 80pt)))
