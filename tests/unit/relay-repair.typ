#import "../../src/lib.typ": deixis-routing-scene
#import "../../src/routing/group-plan.typ": _deixis-plan-group
#import "../../src/routing/group-sockets.typ": _deixis-socket-pairs
#let bounds = (left: 0, top: 0, right: 100, bottom: 80)
#let scene = deixis-routing-scene(pages: ((page: 1, bounds:
  bounds.pairs().fold((:), (out, p) => out + ((p.first()): p.last() * 1pt))),),
  clearance: 0pt, escape: 3pt, bend-cost: 3pt)
#let port(p, normal) = (point: p, normal: normal, owner: none, junction: none)
#let edge(x, y) = {
  let source = port((x, y), (0, 1))
  let target = port((40, 80), (0, -1))
  (id: none, page: 1, from: source, to: target, reselect: true,
    allocation: (source: (source,), target: (target,), reverse: false,
      boundary: bounds + (preferred: 40)))
}
#let edges = (edge(10, 20), edge(70, 35))
#let before = _deixis-plan-group(scene, edges)
#let plan = _deixis-plan-group(scene, edges, reselect: true)
#assert(before.metrics.overlap > 0)
#assert.eq(plan.metrics.overlap, 0)
#assert.eq(plan.metrics.exposure, 0)
#assert.eq(plan.metrics.contacts, 0)
#assert(plan.history.any(h => h.kind == "socket" and h.decision == "accept"))
#for (r, e) in plan.records.zip(edges) {
  assert.eq(r.points.first(), e.from.point)
  assert.eq(r.points.last().last(), e.to.point.last())
  if "selection" in r {
    assert.eq(r.selection.source, e.from)
    assert.eq(r.selection.target.normal, e.to.normal)
    assert.eq(r.preference, calc.abs(r.points.last().first() - 40))
  }
}
// Reversed fragments move their source relay, preserving the real target.
#let incoming = edges.map(e => e + (from: e.to, to: e.from, allocation: e.allocation + (
  source: e.allocation.target, target: e.allocation.source, reverse: true)))
#let reversed = _deixis-plan-group(scene, incoming, reselect: true)
#assert.eq(reversed.metrics.exposure, 0)
#for (r, e) in reversed.records.zip(incoming) {
  assert.eq(r.points.last(), e.to.point)
  assert.eq(r.points.first().last(), e.from.point.last())
}
// Optional policy, literal splits, isolated routes and limits retain contracts.
#for options in ((rounds: 0), (weight: 0), (independent: true)) {
  assert.eq(_deixis-plan-group(scene, edges, ..options),
    _deixis-plan-group(scene, edges, reselect: true, ..options))
}
#let fixed = edges.map(e => e + (reselect: false, allocation: e.allocation + (boundary: none)))
#assert.eq(_deixis-plan-group(scene, fixed), _deixis-plan-group(scene, fixed, reselect: true))
#assert.eq(_deixis-plan-group(scene, edges.slice(0, 1)),
  _deixis-plan-group(scene, edges.slice(0, 1), reselect: true))
#for limit in range(2, 13) {
  let limited = _deixis-plan-group(scene, edges, reselect: true, max-searches: limit)
  assert(limited.records.all(r => r.status == "ok"))
  assert(limited.searches.len() <= limit and limited.expanded <= 50000)
  assert(limited.metrics.energy <= limited.baseline-metrics.energy)
}
#let proposals = _deixis-socket-pairs(scene, edges, before.baseline, 0, 3, 1000)
#assert(proposals.len() <= 7)
#assert(proposals.all(p => p.from == edges.first().from and p.to.point.last() == 80))
#assert.eq(_deixis-socket-pairs(scene, edges, before.baseline, 0, 3, 1), ())
// Remote geometry cannot even supply candidate rails on this page.
#let remote-record = before.baseline.first() + (page: 3, edge-index: 2,
  points: ((39.5, 0), (39.5, 80)))
#assert.eq(_deixis-socket-pairs(scene, edges + (edges.first() + (page: 3),),
  before.baseline + (remote-record,), 0, 3, 1000), proposals)
