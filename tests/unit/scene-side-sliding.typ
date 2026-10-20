#import "../../src/lib.typ": deixis-routing-scene
#import "../../src/routing/connector-scene.typ": _deixis-connector-scene-plan
#let scene = deixis-routing-scene(nodes: ((page: 1, bounds: (left: 38pt, right: 48pt, top: 15pt, bottom: 25pt)),),
  pages: ((page: 1, bounds: (left: 0pt, right: 120pt, top: 0pt, bottom: 80pt)),))
#let prepared = (scene: scene, plane: scene.planes.first())
#let start = (point: (40pt, 20pt), normal: (1, 0))
#let end = (point: (90pt, 20pt), normal: (-1, 0))
#let doc = (page: 1, is-incoming: false, is-outgoing: false, fragment: (logical: (source: none, target: none)))
#let source = start + (sliding: (axis: 1, min: 5pt, max: 40pt))
#let ports = (source: (source,), target: ())
#let plan(p, a, b, choices, via: ()) = _deixis-connector-scene-plan(p, a, b, via, doc, "right-angle", 0pt, ports: choices)
#let route = plan(prepared, start, end, ports, via: ((0pt, 30pt),))
#assert.eq(route.status, "ok")
#assert.eq(route.origin.first(), 40pt)
#assert.eq(route.selection.source.normal, (1, 0))
#assert(5pt <= route.origin.last() and route.origin.last() <= 40pt)
#assert(route.segments.any(s => s.end.zip(route.origin).map(((v, o)) => v + o) == (40pt, 50pt)))
#assert.eq(plan(prepared, start, end, (source: (start,), target: ())).status, "endpoint-blocked")
// A microscopic valid band must not disappear under fixed-distance sampling.
#let slit = deixis-routing-scene(clearance: 0pt, nodes: (
  (page: 1, bounds: (left: 38pt, right: 48pt, top: -1pt, bottom: 20.001pt)),
  (page: 1, bounds: (left: 38pt, right: 48pt, top: 20.002pt, bottom: 81pt))),
  pages: ((page: 1, bounds: (left: 0pt, right: 120pt, top: 0pt, bottom: 80pt)),))
#let result = plan((scene: slit, plane: slit.planes.first()), start, end, ports)
#assert.eq(result.status, "ok")
#assert(20.001pt <= result.origin.last() and result.origin.last() <= 20.002pt)
// Successful preferences are retained, including their exact side coordinate.
#let clear = start + (point: (40pt, 35pt))
#assert.eq(plan(prepared, clear, end, ports).origin, clear.point)
// Each fallback obeys the same bounded search controls.
#for cap in ((max-cells: 1), (max-expansions: 1)) {
  assert.eq(plan(prepared + (scene: scene + cap), start, end, ports).status, "budget")
}
// Moving outside an explicitly narrower registered owner must drop its stub
// exemption instead of asserting or ignoring that owner everywhere.
#let owned = deixis-routing-scene(nodes: (
  (page: 1, bounds: (left: 0pt, right: 40pt, top: 15pt, bottom: 25pt)),
  (page: 1, bounds: (left: 38pt, right: 48pt, top: 15pt, bottom: 25pt))))
#let plane = owned.planes.first()
#let _ = plane.nodes.at(0).insert("entity", (role: "mark", annotation: "note", occurrence: none, point: none))
#let owner-doc = doc + (fragment: (logical: (source: (identity: "note"), target: none)))
#let moved = _deixis-connector-scene-plan((scene: owned, plane: plane), start, end, (), owner-doc,
  "right-angle", 0pt, ports: ports)
#assert.eq(moved.status, "ok")
#assert(moved.origin.last() < 15pt or moved.origin.last() > 25pt)
