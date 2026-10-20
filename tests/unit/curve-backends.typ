#import "../../src/routing/path.typ": _deixis-waypoint-route
#import "../../src/routing/geometry.typ": *
#import "../../src/routing/curves.typ": _deixis-curve-cmds
#context {
  // Direction-free pin endpoints follow their neighboring knot, rather than
  // acquiring the note adapter's vertical/horizontal fallback constraints.
  for kind in ("curve", "ccr", "ucr") {
    for end in ((120pt, 70pt), (-120pt, 70pt), (0pt, 70pt), (120pt, 0pt)) {
      let path = _deixis-waypoint-route(0pt, 0pt, ..end, link-type: kind,
        source-dir: "none", target-dir: "none")
      assert(_deixis-distance(path.start-tangent.map(v => v * 1pt),
        _deixis-unit(end).map(v => v * 1pt)) < 0.000001pt, message: kind + " free source")
      assert(_deixis-distance(path.end-tangent.map(v => v * 1pt),
        _deixis-unit(end).map(v => v * 1pt)) < 0.000001pt, message: kind + " free target")
    }
    let first = (35pt, 20pt)
    let last = (80pt, -10pt)
    let end = (120pt, 60pt)
    let path = _deixis-waypoint-route(0pt, 0pt, ..end, link-type: kind,
      source-dir: "none", target-dir: "none", waypoints: (first, last))
    assert(_deixis-distance(path.start-tangent.map(v => v * 1pt),
      _deixis-unit(first).map(v => v * 1pt)) < 0.000001pt)
    assert(_deixis-distance(path.end-tangent.map(v => v * 1pt),
      _deixis-unit(_deixis-sub(end, last)).map(v => v * 1pt)) < 0.000001pt)
  }
  // A waypoint at the destination is still a real earlier visit when followed
  // by more waypoints. Only consecutive duplicate knots may be collapsed.
  for kind in ("polyline", "orthogonal", "chamfer", "curve", "ccr", "ucr") {
    let end = (120pt, 60pt)
    let path = _deixis-waypoint-route(0pt, 0pt, ..end, link-type: kind,
      source-dir: "none", target-dir: "none", waypoints: (end, (60pt, 80pt)), fixed-waypoints: (end,))
    assert.eq(path.segments.filter(s => s.end == end).len(), 2, message: kind + " lost earlier destination visit")
    let once = _deixis-waypoint-route(0pt, 0pt, ..end, link-type: kind,
      source-dir: "none", target-dir: "none", waypoints: ((60pt, 80pt), end), fixed-waypoints: (end,))
    assert.eq(once.segments.filter(s => s.end == end).len(), 1)
  }
  // Catmull-Rom is C1 in its knot parameter. Uniform knots give matching local
  // cubic derivatives; centripetal knots weight those derivatives by distance.
  let points = ((0pt, 0pt), (15pt, 40pt), (140pt, 10pt), (190pt, 60pt))
  for kind in ("ccr", "ucr") {
    let commands = _deixis-curve-cmds(points, kind: kind)
    for j in range(1, points.len() - 1) {
      let left = _deixis-sub(points.at(j), commands.at(j - 1).c2)
      let right = _deixis-sub(commands.at(j).c1, points.at(j))
      let l = if kind == "ccr" { calc.sqrt(_deixis-distance(points.at(j - 1), points.at(j)) / 1pt) } else { 1 }
      let r = if kind == "ccr" { calc.sqrt(_deixis-distance(points.at(j), points.at(j + 1)) / 1pt) } else { 1 }
      assert(_deixis-distance(left.map(v => v / l), right.map(v => v / r)) < 0.000001pt)
    }
    // Canonical interpolation is invariant under physical scale; the old
    // additive knot epsilon perturbed small and large paths differently.
    let reference = _deixis-curve-cmds(points, kind: kind)
    for factor in (0.0001, 10000) {
      let scaled = _deixis-curve-cmds(points.map(p => p.map(v => v * factor)), kind: kind)
      for (a, b) in reference.zip(scaled) {
        assert(_deixis-distance(a.c1, b.c1.map(v => v / factor)) < 0.000001pt)
        assert(_deixis-distance(a.c2, b.c2.map(v => v / factor)) < 0.000001pt)
      }
    }
  }
  assert.eq(_deixis-curve-cmds(((0pt, 0pt), (0pt, 0pt))), ())
  for kind in ("curve", "ccr", "ucr") {
    assert.eq(_deixis-waypoint-route(0pt, 0pt, 0pt, 0pt, link-type: kind,
      source-normal: (0, -1), target-normal: (0, 1)).segments, ())
  }
  // A type switch at the destination is a genuine chunk boundary.
  let switched = _deixis-waypoint-route(0pt, 0pt, 100pt, 40pt, link-type: "polyline",
    waypoints: ((100pt, 40pt), "none"))
  assert.eq(switched.segments.last().end, (100pt, 40pt))
  // Both explicit axes and forced normals apply even on an axis-aligned chord.
  for kind in ("curve", "ccr", "ucr") {
    let path = _deixis-waypoint-route(0pt, 0pt, 0pt, 70pt, link-type: kind,
      source-dir: "horizontal", target-dir: "horizontal")
    assert.eq(path.start-tangent, (1.0, 0.0))
    assert.eq(path.end-tangent, (1.0, 0.0))
  }
}
