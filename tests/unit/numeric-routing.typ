#import "../../src/lib.typ": deixis-route, deixis-prepare-connector
#import "../../src/routing/geometry.typ": *
#import "../../src/routing/hobby.typ": _deixis-hobby-cmds
#import "../../src/routing/bspline.typ": _deixis-bspline-cmds

// Deliberately outside context: even rounded routing must remain numeric.
#let start = (20pt, -30pt)
#let end = (200pt, 60pt)
#let knots = ((55pt, 40pt), (120pt, -10pt))
#let kinds = ("straight-line", "right-angle", "chamfer", "curve", "ccr", "ucr", "hobby",
  (kind: "b-spline", controls: knots))
#for kind in kinds {
  let via = if type(kind) == dictionary { () } else { knots }
  let route = deixis-route(from: start, to: end, route: kind, via: via, radius: 6pt)
  assert.eq((route.kind, route.frame), ("deixis-route", "source-local-x-right-y-down"))
  assert.eq((route.origin, route.start, route.end), (start, (0pt, 0pt), (180pt, 90pt)))
  assert(route.has-start and route.has-end and route.length > 0pt)
  assert(route.segments.all(s => s.kind in ("line", "cubic")))
  if type(kind) != dictionary {
    for p in knots { assert(route.segments.any(s => s.end == _deixis-sub(p, start))) }
  }
  // Absolute input plane, local output plane: translating all supplied points
  // changes only origin, including off-curve controls and explicit sections.
  let delta = (-80pt, 140pt)
  let shifted = deixis-route(from: _deixis-add(start, delta), to: _deixis-add(end, delta),
    via: via.map(p => _deixis-add(p, delta)), radius: 6pt,
    route: if type(kind) == dictionary { kind + (controls: knots.map(p => _deixis-add(p, delta))) } else { kind })
  assert.eq(shifted + (origin: start), route)
  for normal in (left, top, right, bottom) {
    let r = deixis-route(from: (point: start, normal: normal), to: (point: end, normal: normal),
      route: kind, via: via, radius: 6pt)
    if kind != "straight-line" {
      let vector = (left: (-1, 0), top: (0, -1), right: (1, 0), bottom: (0, 1)).at(repr(normal))
      assert.eq(r.start-tangent, vector)
      assert.eq(r.end-tangent, vector.map(v => -v))
    }
  }
}
#let line = deixis-route(from: start, to: end)
#assert.eq(line.segments, ((kind: "line", start: (0pt, 0pt), end: (180pt, 90pt)),))
#assert.eq(line.bounds, (left: 0pt, top: 0pt, right: 180pt, bottom: 90pt, center-x: 90pt, center-y: 45pt))
#for kind in ("curve", "ccr", "ucr", "hobby", "b-spline", "orthogonal", "chamfer", "none") {
  let empty = deixis-route(from: start, to: start, route: kind)
  assert.eq(empty.segments, ())
  assert(not empty.has-start and not empty.has-end and empty.length == 0pt)
}
#for kind in ("curve", "ccr", "ucr", "hobby", (kind: "b-spline", controls: knots)) {
  let via = if type(kind) == dictionary { () } else { knots }
  let a = deixis-route(from: (point: start, normal: (1, 1)), to: (point: end, normal: (-3, 4)), route: kind, via: via)
  let b = deixis-route(from: (point: start, normal: (1e308, 1e308)), to: (point: end, normal: (-3e-300, 4e-300)), route: kind, via: via)
  for (u, v) in ((a.start-tangent, (1 / calc.sqrt(2), 1 / calc.sqrt(2))), (a.end-tangent, (0.6, -0.8))) {
    assert(u.zip(v).all(pair => calc.abs(pair.first() - pair.last()) < 1e-8))
  }
  for (u, v) in a.segments.zip(b.segments) {
    for key in ("start", "end", "c1", "c2") { assert(_deixis-distance(u.at(key), v.at(key)) < 1e-8pt) }
  }
}
#let spec = (kind: "b-spline", controls: ((40pt, -10pt),))
#let sections = ((route: spec, via: (knots.first(),)), (route: spec, via: (knots.last(),)), (route: "hobby"))
#let mixed = deixis-route(from: start, to: end, segments: sections)
#let via-mixed = deixis-route(from: start, to: end, via: (spec, knots.first(), spec, knots.last(), "hobby"))
#assert.eq(mixed, via-mixed)
#let first = _deixis-bspline-cmds((0pt, 0pt), _deixis-sub(knots.first(), start), controls: ((_deixis-sub(spec.controls.first(), start)),))
#assert.eq(mixed.segments.first(), _deixis-path-segments((_deixis-move((0pt, 0pt)),) + first).first())
#let last = _deixis-hobby-cmds((_deixis-sub(knots.last(), start), _deixis-sub(end, start)))
#assert.eq(mixed.segments.last().c1, last.first().c1)
#let gap = deixis-route(from: start, to: end, via: (knots.first(), "none", knots.last(), "polyline"))
#assert.eq(gap.segments.len(), 2)
#assert.eq(gap.gaps.len(), 1)
#assert.eq(gap.length, _deixis-distance(start, knots.first()) + _deixis-distance(knots.last(), end))
#let no-ends = deixis-route(from: start, to: end, route: "none", via: (knots.first(), "hobby", knots.last(), "none"))
#assert(not no-ends.has-start and not no-ends.has-end)
// Hard numeric points retain a rounded corner's exact visit, including tiny
// offsets above the core's 0.00001pt geometric cleanup threshold.
#let near = deixis-route(from: start, to: end, route: "orthogonal",
  via: (_deixis-add(start, (0.02pt, 0.03pt)),), radius: 8pt)
#assert(near.segments.any(s => _deixis-distance(s.end, (0.02pt, 0.03pt)) < 1e-10pt))
