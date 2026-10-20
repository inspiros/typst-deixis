#import "../../src/routing/path.typ": *
#import "../../src/routing/geometry.typ": *
#import "../../src/routing/heads.typ": *
#import "../../src/layout/geometry.typ": *
#context {
  let bounds = _deixis-box-bounds(10pt, 20pt, 30pt, 40pt)
  let p = _deixis-select-port((), (side: "right", at: 25%, gap: 3pt), bounds)
  assert.eq((p.x, p.y, p.normal), (33pt, 25pt, (1, 0)))
  // Explicit automatic sides slide; fixed percentages retain exact positions.
  let sliding = _deixis-select-port((), "right", bounds)
  let fixed = _deixis-select-port((), (side: "left", at: 25%), bounds)
  let (s, d) = _deixis-resolve-best-ports((sliding,), ((x: 90pt, y: 100pt, id: "pin", dir: "none"),))
  assert.eq((s.x, s.y), (30pt, 40pt))
  let (s, d) = _deixis-resolve-best-ports((sliding,), (fixed,))
  assert.eq((s.y, d.y), (25pt, 25pt))
  let other = _deixis-select-port((), "left", _deixis-box-bounds(80pt, 30pt, 100pt, 50pt))
  let (s, d) = _deixis-resolve-best-ports((sliding,), (other,))
  assert.eq((s.y, d.y), (35pt, 35pt))
  let (reverse-d, reverse-s) = _deixis-resolve-best-ports((other,), (sliding,))
  assert.eq((s.x, s.y, d.x, d.y), (reverse-s.x, reverse-s.y, reverse-d.x, reverse-d.y))
  // Pin waypoints are exact visits even when surrounding corners are rounded.
  for route in ("right-angle", "chamfer") {
    let pin = (20pt, 30pt)
    let path = _deixis-waypoint-route(0pt, 0pt, 100pt, 60pt,
      link-type: route, link-radius: 8pt, waypoints: (pin,), fixed-waypoints: (pin,))
    assert(path.segments.any(s => s.end == pin))
    let near = (0.05pt, 0.05pt)
    let path = _deixis-waypoint-route(0pt, 0pt, 100pt, 60pt,
      link-type: route, waypoints: (near,), fixed-waypoints: (near,))
    assert(path.segments.any(s => s.end == near))
  }
  let reference = _deixis-resolve-waypoints((
    (relative-to: "mark", anchor: top + left, offset: (2pt, 3pt)),
    (relative-to: "previous", offset: (5pt, -2pt)),
    (relative-to: "page", offset: (50%, 25%)),
  ), 0pt, 0pt, bounds, bounds, page-bounds: _deixis-box-bounds(0pt, 0pt, 200pt, 100pt))
  assert.eq(reference, ((12pt, 23pt), (17pt, 21pt), (100pt, 25pt)))
  // Every route stays finite and trims on its actual geometry in every quadrant.
  for kind in ("straight-line", "right-angle", "chamfer", "curve", "ccr", "ucr") {
    for end in ((100pt, 60pt), (-100pt, 60pt), (100pt, -60pt), (-100pt, -60pt), (100pt, 0pt), (0pt, 100pt)) {
      for wps in ((), ((20pt, 30pt),), ((20pt, 30pt), (20pt, 30pt), (40pt, -10pt))) {
        let route = _deixis-waypoint-route(0pt, 0pt, ..end, link-type: kind, waypoints: wps,
          link-radius: 20pt, source-dir: "horizontal", target-dir: "vertical")
        assert(route.length >= 0pt)
        assert.eq(route.segments.first().start, (0pt, 0pt))
        assert.eq(route.segments.last().end, end)
        let shaft = _deixis-trim-path(route.segments, start: 3pt, end: 2pt)
        let remaining = shaft.map(s => _deixis-segment-length(s)).fold(0pt, (a, b) => a + b)
        assert(calc.abs(route.length - remaining - 5pt) < 0.04pt,
          message: "Incorrect arc-length trim for " + kind)
        if kind in ("curve", "ccr", "ucr") and wps.len() > 0 {
          assert(calc.abs(route.start-tangent.at(1)) < 0.0001)
          assert(calc.abs(route.end-tangent.at(0)) < 0.0001)
        }
      }
    }
  }
  let mixed = _deixis-waypoint-route(0pt, 0pt, 100pt, 60pt, link-type: "straight-line",
    waypoints: ("curve", (30pt, 40pt), "straight-line"), source-dir: "horizontal")
  assert.eq(mixed.segments.first().kind, "cubic")
  assert.eq(mixed.segments.last().kind, "line")
  assert.eq(mixed.start-tangent.at(1), 0)
  for kind in ("right-angle", "chamfer", "curve", "ccr", "ucr") {
    for normal in ((1, 0), (-1, 0), (0, 1), (0, -1)) {
      let axis = if normal.at(0) == 0 { "vertical" } else { "horizontal" }
      let route = _deixis-waypoint-route(0pt, 0pt, 100pt, 0pt, link-type: kind,
        source-dir: axis, target-dir: axis, source-normal: normal, target-normal: normal)
      assert.eq(route.start-tangent, normal, message: kind + ": source must exit its forced side")
      assert.eq(route.end-tangent, _deixis-scale(normal, -1), message: kind + ": target must enter its forced side")
    }
  }
  let short = _deixis-waypoint-route(0pt, 0pt, 5pt, 0pt)
  // Equal global sections at the destination are empty. A different empty
  // route or zero-distance none switch must not absorb the visible endpoint's
  // constraint, while genuine none spans still interrupt the shaft.
  for kind in ("curve", "ccr", "ucr", "hobby", "b-spline", "right-angle", "chamfer") {
    let baseline = _deixis-waypoint-route(0pt, 0pt, 100pt, 60pt, link-type: kind,
      source-normal: (-1, 0), target-normal: (0, -1))
    for terminal in (kind, "none", "curve", "hobby", "b-spline") {
      let empty-end = _deixis-waypoint-route(0pt, 0pt, 100pt, 60pt, link-type: kind,
        waypoints: ((100pt, 60pt), terminal), source-normal: (-1, 0), target-normal: (0, -1))
      assert.eq(empty-end, baseline, message: kind + ": empty terminal " + terminal)
    }
    let empty-start = _deixis-waypoint-route(0pt, 0pt, 100pt, 60pt, link-type: "b-spline",
      waypoints: ((0pt, 0pt), kind), source-normal: (-1, 0), target-normal: (0, -1))
    assert.eq(empty-start, baseline)
    let gap = _deixis-waypoint-route(0pt, 0pt, 100pt, 60pt, link-type: "none",
      waypoints: ((20pt, 10pt), kind, (80pt, 40pt), "none"),
      source-normal: (-1, 0), target-normal: (0, -1))
    assert(not gap.has-start and not gap.has-end)
    assert.eq((gap.segments.first().start, gap.segments.last().end), ((20pt, 10pt), (80pt, 40pt)))
  }
  assert.eq(_deixis-trim-path(short.segments, start: 9.4pt, end: 9.4pt), ())
  assert.eq(_deixis-render-waypoint-path(0pt, 0pt, 0pt, 0pt, link-marks: "both"), ())
  assert.eq(_deixis-draw-direct-link(0pt, 0pt, 50pt, 50pt, link-marks: "mark", is-incoming: true).len(), 2)
  assert.eq(_deixis-draw-direct-link(0pt, 0pt, 50pt, 50pt, link-marks: "body", is-outgoing: true).len(), 2)
  for shape in ("stealth", "triangle", "vee", "circle", "diamond", "bar") {
    let head = _deixis-prepare-head(shape, 0.5pt, "body")
    assert.eq(head.request.stroke.paint, black)
    assert(head.trim >= 0pt and head.bounds.left <= head.bounds.right)
  }
  // Custom painters receive an explicitly disabled shaft as none; heads may
  // still be styled independently, including when using a direct layout hook.
  let no-shaft(request) = {
    assert.eq(request.stroke, none)
    assert(request.heads.body != none)
    []
  }
  let result = _deixis-render-waypoint-path(0pt, 0pt, 30pt, 40pt,
    link-stroke: none, link-heads: "circle", link-render: no-shaft)
  assert.eq(result.len(), 1)
  for kind in ("right-angle", "chamfer") {
    let result = _deixis-render-waypoint-path(0pt, 0pt, 30pt, 40pt,
      link-type: kind, link-radius: auto, link-stroke: none, link-heads: "circle", link-render: no-shaft)
    assert.eq(result.len(), 1)
  }
}
