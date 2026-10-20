#import "../../src/lib.typ": deixis-routing-scene
#import "../../src/routing/connector-scene.typ": _deixis-connector-scene-plan
#let scene = deixis-routing-scene(nodes: ((page: 1, bounds: (left: 38pt, right: 48pt, top: 15pt, bottom: 25pt)),),
  pages: ((page: 1, bounds: (left: 0pt, right: 120pt, top: 0pt, bottom: 80pt)),))
#let prepared = (scene: scene, plane: scene.planes.first())
#let start = (point: (40pt, 20pt), normal: (1, 0))
#let other = (point: (30pt, 30pt), normal: (0, 1))
#let end = (point: (90pt, 20pt), normal: (-1, 0))
#let doc = (page: 1, is-incoming: false, is-outgoing: false, fragment: (logical: (source: none, target: none)))
#let ports = (source: (other,), target: ())
#let plan(p, a, b, via: (), choices: ports) = _deixis-connector-scene-plan(p, a, b, via, doc, "right-angle", 0pt, ports: choices)
#assert.eq(plan(prepared, start, end, choices: none).status, "endpoint-blocked")
#let selected = plan(prepared, start, end)
#assert.eq(selected.status, "ok")
#assert.eq(selected.origin, other.point)
#assert.eq(selected.selection.source.normal, other.normal)
#assert.eq(selected.search.attempts, 2)
// A feasible preference stays put even if the alternative route would be shorter.
#let preferred = plan(prepared, other, end, choices: (source: ((point: (80pt, 30pt), normal: (0, 1)),), target: ()))
#assert.eq(preferred.origin, other.point)
#assert("selection" not in preferred)
// Already resolved relative visits keep their absolute point when the origin moves.
#let via = plan(prepared, start, end, via: ((0pt, 30pt),))
#assert.eq(via.status, "ok")
#assert(via.segments.any(s => s.end.zip(via.origin).map(((v, o)) => v + o) == (40pt, 50pt)))
// Target-only fallback and both blocked ends use the same graph, not N*M searches.
#let reversed = plan(prepared, end, start, choices: (source: (), target: (other,)))
#assert.eq(reversed.status, "ok")
#assert.eq(reversed.selection.target.point, other.point)
#let both = plan(prepared, start, start, choices: (source: (other,), target: ((point: (90pt, 40pt), normal: (-1, 0)),)))
#assert.eq(both.status, "ok")
#assert.eq(both.search.attempts, 2)
// Fixed blocked counterpart, blocked hard visit and budgets are not overridden.
#assert.eq(plan(prepared, other, start).status, "endpoint-blocked")
#assert.eq(plan(prepared, start, end, via: ((0pt, 0pt),)).status, "waypoint-blocked")
#for limits in ((max-cells: 1), (max-expansions: 1)) {
  let p = prepared + (scene: scene + limits)
  assert.eq(plan(p, start, end).status, "budget")
}
// A disconnected preferred route can spend its budget before trying alternatives.
#let wall = deixis-routing-scene(nodes: ((page: 1, bounds: (left: 55pt, right: 65pt, top: -5pt, bottom: 85pt)),),
  pages: ((page: 1, bounds: (left: 0pt, right: 120pt, top: 0pt, bottom: 80pt)),))
#let p = (scene: wall, plane: wall.planes.first())
#let disconnected = plan(p, other, end, choices: none)
#assert.eq(disconnected.status, "no-path")
#let choices = (source: ((point: (80pt, 40pt), normal: (1, 0)),), target: ())
#assert.eq(plan(p, other, end, choices: choices).status, "ok")
#for extra in (0, 1) {
  let cap = disconnected.stats.expanded + extra
  let limited = plan(p + (scene: wall + (max-expansions: cap)), other, end, choices: choices)
  assert.eq(limited.status, "budget")
  assert(limited.stats.expanded <= cap + 1)
}
// Fixed page relays can coexist with automatic real ports. Only the real end
// may move; an explicitly positioned blocked boundary remains a failure.
#let outgoing = doc + (is-outgoing: true)
#let relay = (point: (90pt, 60pt), normal: (0, -1))
#let fixed = _deixis-connector-scene-plan(prepared, start, relay, (), outgoing, "right-angle", 0pt, ports: ports)
#assert.eq(fixed.status, "ok")
#assert.eq(fixed.selection.target.point, relay.point)
#let incoming = doc + (is-incoming: true)
#let fixed-in = _deixis-connector-scene-plan(prepared, relay, start, (), incoming, "right-angle", 0pt,
  ports: (source: (), target: (other,)))
#assert.eq(fixed-in.status, "ok")
#assert.eq(fixed-in.selection.source.point, relay.point)
#assert.eq(_deixis-connector-scene-plan(prepared, other, start, (), outgoing, "right-angle", 0pt,
  ports: (source: (end,), target: ())).status, "endpoint-blocked")
