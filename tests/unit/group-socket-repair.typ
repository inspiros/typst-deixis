#import "../../src/lib.typ": deixis-routing-scene
#import "../../src/routing/group-plan.typ": _deixis-plan-group
#import "../../src/routing/group-sockets.typ": _deixis-socket-pairs
#import "../../src/routing/group-geometry.typ": metrics
#let scene = deixis-routing-scene(bounds: (left: 0pt, top: 0pt, right: 100pt, bottom: 80pt),
  clearance: 0pt, escape: 4pt, bend-cost: 5pt)
#let port(point, normal) = (point: point, normal: normal, owner: none, junction: none)
#let a = port((10, 20), (1, 0)); #let b = port((90, 20), (-1, 0))
#let c = port((10, 40), (1, 0)); #let d = port((90, 40), (-1, 0))
#let edge = (id: none, from: a, to: b, allocation: (source: (a, c), target: (b, d), boundary: none, reverse: false))
#let edges = (edge, edge)
#let plan = _deixis-plan-group(scene, edges, reselect: true)
#assert.eq(plan.metrics.exposure, 0)
#assert(plan.history.any(p => p.kind == "socket" and p.decision == "accept"))
#assert(plan.records.any(r => "selection" in r and r.selection.source == c and r.selection.target == d))
#assert.eq(plan.baseline-metrics, metrics(scene, edges, plan.baseline))
#assert.eq(plan.records.map(r => r.length), (80, 80))
#assert(plan.searches.len() <= 64 and plan.expanded <= 50000)
// Each candidate search is fixed, with its actual semantic socket masks. Failed
// or rejected proposals cannot change any accepted route/selection in the book.
#assert(plan.searches.filter(s => "sockets" in s).all(s => s.record.status != "ok"
  or (s.record.points.first() == s.sockets.source.point and s.record.points.last() == s.sockets.target.point)))
#for options in ((rounds: 0), (weight: 0), (independent: true)) {
  let before = _deixis-plan-group(scene, edges, ..options)
  let after = _deixis-plan-group(scene, edges, reselect: true, ..options)
  assert.eq(before, after)
}
#let fixed = edges.map(e => e + (allocation: e.allocation + (source: (a,), target: (b,))))
#assert.eq(_deixis-plan-group(scene, fixed), _deixis-plan-group(scene, fixed, reselect: true))
// Respect per-edge eligibility: explicit cross-page halves use this even with
// an exact split (whose boundary record is absent).
#let remote = edges.map(e => e + (reselect: false))
#assert.eq(_deixis-plan-group(scene, remote), _deixis-plan-group(scene, remote, reselect: true))
#for budget in range(2, 14) {
  let limited = _deixis-plan-group(scene, edges, reselect: true, max-searches: budget)
  assert(limited.records.all(r => r.status == "ok"))
  assert(limited.searches.len() <= budget)
  assert(limited.metrics.energy <= limited.baseline-metrics.energy)
}
// Candidate lists are bounded before the Cartesian product. Exact visits add a
// safe length lower bound; they are not translated when a socket moves.
#let many = edge + (allocation: edge.allocation + (
  source: range(50).map(y => port((10, y), (1, 0))), target: range(50).map(y => port((90, y), (-1, 0)))),)
#let proposals = _deixis-socket-pairs(scene, (many, edge), plan.baseline, 0, 3, 200)
#assert(proposals.len() <= 63)
#assert.eq(_deixis-socket-pairs(scene, (edge + (via: ((50, 75),)), edge), plan.baseline, 0, 3, 80), ())
