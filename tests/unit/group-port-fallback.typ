#import "../../src/lib.typ": deixis-routing-scene
#import "../../src/routing/group-plan.typ": _deixis-plan-group
#let scene = deixis-routing-scene(nodes: ((bounds: (left: 38pt, right: 48pt, top: 15pt, bottom: 25pt)),),
  bounds: (left: 0pt, right: 120pt, top: 0pt, bottom: 80pt))
#let port(point, normal: none, junction: none) = (point: point, normal: normal, owner: none, junction: junction)
#let a = port((40, 20), normal: (1, 0), junction: ("a", (40, 20)))
#let other = port((30, 30), normal: (0, 1), junction: ("a", (30, 30)))
#let b = port((90, 20), normal: (-1, 0))
#let options = (source: (a, other), target: (b,), boundary: none, reverse: false)
#let edge = (id: none, page: none, from: a, to: b, via: (), allocation: options)
#let plan(e, ..args) = _deixis-plan-group(scene, (e,), ..args)
#let selected = plan(edge)
#assert.eq(selected.records.first().status, "ok")
#assert.eq(selected.records.first().selection.source, other)
#assert.eq(selected.records.first().points.first(), other.point)
#assert.eq(selected.baseline.first().selection.source.junction, other.junction)
// Exact endpoints cannot borrow unrelated alternatives, or move a blocked visit.
#assert.eq(plan(edge + (allocation: options + (source: (a,),))).records.first().status, "endpoint-blocked")
#assert.eq(plan(edge + (via: ((40, 20),))).records.first().status, "waypoint-blocked")
#let failed = plan(edge, max-searches: 1)
#assert.eq(failed.records.first().status, "endpoint-blocked")
#assert.eq(failed.searches.len(), 1)
#assert("searches" in failed.limits-hit)
// Empty independent work still consumes one search; fallback never resets caps.
#let capped = plan(edge, max-expansions: 1)
#assert.eq(capped.records.first().status, "budget")
#assert.eq(capped.expanded, 1)
#assert(capped.searches.len() <= 2)
// Retain a successful preference even when a different socket is shorter.
#let clear = edge + (from: other, allocation: options + (source: (other, port((80, 30), normal: (0, 1))),))
#assert.eq(plan(clear).records.first().points.first(), other.point)
#assert("selection" not in plan(clear).records.first())
// Allocated real sockets keep their identity across a multi-edge repair. The
// two permitted departure stubs share only their common owned socket.
#let edges = (edge, edge + (to: port((90, 50)), allocation: options + (target: (port((90, 50)),),)))
#let group = _deixis-plan-group(scene, edges)
#assert(group.records.all(r => r.status == "ok" and r.selection.source == other))
#assert(group.metrics.energy <= group.baseline-metrics.energy)
#assert.eq(group.metrics.missing, 0)
// A disconnected fixed preference can spend the per-edge allowance before its
// alternative. Global headroom must not provide a fresh scene allowance.
#let wall = deixis-routing-scene(nodes: ((bounds: (left: 55pt, right: 65pt, top: -5pt, bottom: 85pt)),),
  bounds: (left: 0pt, right: 120pt, top: 0pt, bottom: 80pt))
#let disconnected = edge + (from: other, allocation: options + (source: (other, port((80, 40), normal: (1, 0))),))
#let fixed = _deixis-plan-group(wall, (disconnected + (allocation: options + (source: (other,),)),))
#let spent = fixed.records.first().stats.expanded
#let limited = _deixis-plan-group(wall + (max-expansions: spent + 1), (disconnected,))
#assert.eq(limited.records.first().status, "budget")
#assert(limited.expanded <= spent + 1)
