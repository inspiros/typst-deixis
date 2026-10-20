// Unitless-pt fixtures exercise the same production core as the public adapter.
// Only the strict sequential diagnostic policy lives here, never in src/lib.typ.
#import "../../src/routing/scene.typ": deixis-routing-scene
#import "../../src/routing/avoid.typ": _deixis-avoid
#import "../../src/routing/group-plan.typ": _deixis-plan-group, solve, new-book, empty, validate-input
#import "../../src/routing/group-geometry.typ": endpoint, validate-junctions, metrics
#import "../../src/route-group.typ": deixis-route-group

#let prepare(input) = {
  let length-rect(r) = (left: r.left * 1pt, right: r.right * 1pt, top: r.top * 1pt, bottom: r.bottom * 1pt)
  deixis-routing-scene(
    nodes: input.at("obstacles", default: ()).map(r => (id: r.id, bounds: length-rect(r), page: r.at("page", default: none))),
    bounds: if input.at("bounds", default: none) == none { none } else { length-rect(input.bounds) },
    pages: input.at("pages", default: ()).map(p => (page: p.page, bounds: length-rect(p.bounds))),
    clearance: input.at("clearance", default: 0) * 1pt,
    escape: input.at("escape", default: 1) * 1pt,
    bend-cost: input.at("bend-cost", default: 5) * 1pt,
    max-cells: input.at("max-cells", default: 65536),
    max-expansions: input.at("max-expansions", default: 50000))
}

#let resolved(scene, edges) = edges.map(edge => {
  let resolve-port(value) = {
    let e = endpoint(value)
    if e.owner != none { e.owner = scene.ids.at(e.owner) }
    e
  }
  for role in ("from", "to") {
    edge.insert(role, resolve-port(edge.at(role)))
  }
  if "allocation" in edge {
    for role in ("source", "target") {
      edge.allocation.at(role) = edge.allocation.at(role).map(resolve-port)
    }
  }
  edge
})

#let repair(scene, edges, ..options) = _deixis-plan-group(scene, resolved(scene, edges), ..options)

#let sequence(scene, edges, policy: "soft", spacing: 3, weight: 4,
  max-searches: 64, max-expansions: 50000, cost-options: (:),
) = {
  edges = resolved(scene, edges)
  validate-input(edges, spacing, weight, max-searches, max-expansions)
  assert(policy in ("independent", "soft", "reserved"))
  validate-junctions(scene, edges)
  let book = new-book(max-searches, max-expansions); let records = ()
  for (i, edge) in edges.enumerate() {
    let call = solve(scene, edges, i, records, book, spacing, weight, policy: policy, cost-options: cost-options)
    book = call.book
    records.push(if call.record == none { empty(edge, i) } else { call.record })
  }
  (records: records, searches: book.searches, expanded: book.expanded,
    metrics: metrics(scene, edges, records, spacing: spacing, weight: weight))
}

// Exercise the public units/endpoint/result adapter on anonymous fixture ports.
// Shared named sockets have their own installed-package document fixtures.
#let public-plan(input, options) = {
  let point(p) = p.map(v => v * 1pt)
  let port(value) = {
    let e = endpoint(value)
    let p = (point: point(e.point))
    if e.normal != none { p.normal = e.normal }
    if e.owner != none { p.owner = e.owner }
    p
  }
  let edges = input.edges.map(e => (id: e.id, page: e.at("page", default: none),
    from: port(e.from), to: port(e.to), via: e.at("via", default: ()).map(point)))
  let o = options
  if "spacing" in o { o.spacing *= 1pt }
  let plan = deixis-route-group(edges, scene: prepare(input), ..o)
  let records = plan.routes.map(r => {
    let record = (status: r.status, page: r.page, id: r.id, edge-index: r.index)
    if r.status == "ok" {
      let points = (r.origin,) + r.segments.map(s => s.end.zip(r.origin).map(((a,b)) => a + b))
      record += (points: points.map(p => p.map(v => v.pt())), length: r.length.pt(),
        bends: r.search.bends, score: r.search.score.pt(),
        stats: (cells: r.search.cells, expanded: r.search.expanded, queued: r.search.queued))
    } else { record += (detail: r.detail, stats: r.stats) }
    record
  })
  let quality(m) = m.pairs().fold((:), (result, pair) => result +
    ((pair.first()): if type(pair.last()) == length { pair.last().pt() } else { pair.last() }))
  (records: records, before: quality(plan.quality.before), after: quality(plan.quality.after), stats: plan.stats)
}
