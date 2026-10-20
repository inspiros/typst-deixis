#import "../../src/lib.typ": *
#import "../../src/routing/scene-interactions.typ": _deixis-scene-interactions, _deixis-scene-point
#import "../../src/routing/geometry.typ": _deixis-segment-length

#let b = (left: 40pt, top: 40pt, right: 60pt, bottom: 60pt)
#let nodes = ((id: "square", index: 0, behavior: "cut", bounds: b),)
#let line(a, z) = (kind: "line", start: a, end: z)
#let cubic(a, p, q, z) = (kind: "cubic", start: a, c1: p, c2: q, end: z)
#let specimens = (
  // Diagonal crossing, wholly contained, boundary overlap, tangent corner.
  (s: line((0pt, 0pt), (100pt, 100pt)), count: 1),
  (s: line((45pt, 45pt), (55pt, 55pt)), count: 1),
  (s: line((0pt, 40pt), (100pt, 40pt)), count: 0),
  (s: line((0pt, 80pt), (80pt, 0pt)), count: 0),
  // A cubic crossing the same rectangle three times, without flattening.
  (s: cubic((0pt, 50pt), (200pt, 50pt), (-100pt, 50pt), (100pt, 50pt)), count: 3),
  // Double derivative root and tangent touch at y=40: no interior entry.
  (s: cubic((0pt, 10pt), (0pt, 50pt), (100pt, 50pt), (100pt, 10pt)), count: 0),
  (s: cubic((0pt, 50pt), (10pt, 80pt), (90pt, 20pt), (100pt, 50pt)), count: 1),
)
#for specimen in specimens {
  let s = specimen.s
  let hits = _deixis-scene-interactions((origin: (0pt, 0pt), segments: (s,)), nodes, none)
  assert.eq(hits.len(), specimen.count)
  for hit in hits {
    assert(hit.from < hit.to and hit.from >= 0pt and hit.to <= _deixis-segment-length(s) + 0.01pt)
    if not (s.start.first() > b.left and s.start.first() < b.right and s.start.last() > b.top and s.start.last() < b.bottom) {
      assert(calc.min(calc.abs(hit.entry.first() - b.left), calc.abs(hit.entry.first() - b.right),
        calc.abs(hit.entry.last() - b.top), calc.abs(hit.entry.last() - b.bottom)) < 0.00001pt)
    }
  }
}
// A genuine gap remains two events, even at the same drawable arc distance.
#let gap = _deixis-scene-interactions((origin: (0pt, 0pt), segments: (
  line((0pt, 50pt), (45pt, 50pt)), line((55pt, 50pt), (100pt, 50pt)))), nodes, 3)
#assert.eq(gap.len(), 2)
#assert.eq(gap.map(h => h.page), (3, 3))
// Native cut preparation restricts the curve's existing locus and leaves its
// heads/uncut route intact. Use an off-curve B-spline control, not hard visits.
#let scene = deixis-routing-scene(nodes: nodes.map(n => (id: n.id, behavior: n.behavior, bounds: n.bounds)))
#let route = deixis-route(scene: scene, from: (0pt, 50pt), to: (100pt, 50pt),
  route: (kind: "b-spline", controls: ((40pt, 80pt), (60pt, 20pt))))
#assert.eq(route.interactions.len(), 1)
#context {
  let prepared = deixis-prepare-connector(route, heads: "triangle")
  assert(prepared.heads.body != none)
  assert.eq(prepared.route.segments, route.segments)
  assert.eq(prepared.shaft.len(), 2)
  let hit = route.interactions.first()
  assert(calc.abs(prepared.shaft.first().end.first() - hit.entry.first()) < 0.01pt)
  assert(calc.abs(prepared.shaft.last().start.first() - hit.exit.first()) < 0.01pt)
}
