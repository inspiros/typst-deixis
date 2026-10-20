#import "../../src/routing/path.typ": _deixis-waypoint-route, _deixis-render-waypoint-path
#import "../../src/routing/geometry.typ": *
#import "../../src/routing/gaps.typ": *
#context {
  for kind in ("polyline", "orthogonal", "chamfer", "curve", "ccr", "ucr") {
    for target in ((100pt, 60pt), (-100pt, 60pt), (100pt, -60pt), (-100pt, -60pt)) {
      let a = _deixis-scale(target, 0.4)
      let b = _deixis-scale(target, 0.6)
      let route = _deixis-waypoint-route(0pt, 0pt, ..target, link-type: kind,
        waypoints: (a, "none", b, kind), fixed-waypoints: (a, b), link-radius: 5pt)
      assert.eq(route.gaps.len(), 1)
      assert.eq((route.gaps.first().start, route.gaps.first().end), (a, b))
      for vector in (route.gaps.first().start-tangent, route.gaps.first().end-tangent) {
        assert(calc.abs(vector.at(0) * vector.at(0) + vector.at(1) * vector.at(1) - 1) < 0.0001)
      }
      let trimmed = _deixis-path-gaps(_deixis-trim-path(route.segments, start: 1pt, end: 1pt)).first()
      assert.eq((trimmed.start, trimmed.end), (a, b))
      for key in ("start-tangent", "end-tangent") {
        assert(trimmed.at(key).zip(route.gaps.first().at(key)).all(((a, b)) => calc.abs(a - b) < 0.000001))
      }
    }
  }
  let path = (kind: "line", start: (0pt, 0pt), end: (20pt, 0pt))
  let other = (kind: "line", start: (40pt, 0pt), end: (60pt, 0pt))
  let gaps = _deixis-path-gaps((path, other))
  assert.eq(gaps, ((start: (20pt, 0pt), end: (40pt, 0pt), start-tangent: (1, 0), end-tangent: (1, 0)),))
  assert.eq(_deixis-path-gaps(_deixis-trim-path((path, other), start: 30pt)), ())
  assert.eq(_deixis-path-gaps(_deixis-trim-path((path, other), end: 30pt)), ())
  assert.eq(_deixis-path-gaps(()), ())
  assert.eq(_deixis-path-gaps((path,)), ())
  for waypoints in (("none", (40pt, 0pt), "polyline"), ((40pt, 0pt), "none"), ("none",)) {
    assert.eq(_deixis-waypoint-route(0pt, 0pt, 100pt, 0pt, waypoints: waypoints).gaps, ())
  }
  for shape in ("bar", "slash") {
    let spec = _deixis-prepare-gap-marks((shape: shape, size: 0.6em), blue + 1pt)
    assert.eq(spec.size, (0.6em).to-absolute())
    assert.eq(_deixis-paint-gap-marks(gaps, spec).len(), 2)
  }
  let spec = _deixis-prepare-gap-marks("slash", stroke(paint: blue, thickness: 2pt, dash: "dotted"))
  assert.eq(spec.size, 8pt)
  assert.eq(spec.stroke.dash, none)
  assert.eq(_deixis-prepare-gap-marks("bar", none), none)
  assert.eq(_deixis-prepare-gap-marks((stroke: none), blue), none)
  // Degenerate cubic handles still supply a useful gap tangent.
  let cubic = (kind: "cubic", start: (0pt, 0pt), c1: (5pt, 0pt), c2: (20pt, 0pt), end: (20pt, 0pt))
  assert.eq(_deixis-path-gaps((cubic, other)).first().start-tangent, (1, 0))
}
