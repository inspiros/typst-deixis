#import "../../src/routing/spec.typ": *
#import "../../src/routing/path.typ": _deixis-waypoint-route, _deixis-resolve-waypoints
#import "../../src/routing/geometry.typ": *
#import "../../src/core/internal.typ": _deixis-connector-options, _deixis-resolve-typed-param, _deixis-merge-config
#context {
  for (record, name) in (
    ((kind: "curve"), "curve"), ((kind: "curve", tension: 1.0), "curve"),
    ((kind: "catmull-rom"), "ccr"), ((kind: "catmull-rom", parameterization: "uniform"), "ucr"),
    ((kind: "catmull-rom-centripetal"), "ccr"), ((kind: "catmull-rom-uniform"), "ucr"),
    ((kind: "orthogonal"), "right-angle"), ((kind: "none"), "none"),
  ) {
    assert.eq(_deixis-route-spec(record), name)
    assert.eq(_deixis-route-spec(_deixis-route-spec(record)), name)
  }
  assert.eq(_deixis-route-spec("catmull-rom"), "ccr")
  let vertices = ((35pt, 40pt), (110pt, -15pt))
  for kind in ("curve", "ccr", "ucr") {
    for points in ((), vertices) {
      let ordinary = _deixis-waypoint-route(0pt, 0pt, 180pt, 60pt,
        link-type: kind, waypoints: points, source-normal: (-1, 0), target-normal: (0, -1))
      let explicit = _deixis-waypoint-route(0pt, 0pt, 180pt, 60pt,
        link-type: (kind: kind, tension: 1), waypoints: points, source-normal: (-1, 0), target-normal: (0, -1))
      assert.eq(ordinary, explicit)
      for tension in (0.5, 2, 4) {
        let spec = _deixis-route-spec((kind: kind, tension: tension))
        assert.eq(_deixis-route-spec(spec), spec)
        let configured = _deixis-waypoint-route(0pt, 0pt, 180pt, 60pt,
          link-type: spec, waypoints: points, source-normal: (-1, 0), target-normal: (0, -1))
        assert.eq(configured.segments.map(s => (s.start, s.end)), ordinary.segments.map(s => (s.start, s.end)))
        assert.eq(configured.start-tangent, ordinary.start-tangent)
        assert.eq(configured.end-tangent, ordinary.end-tangent)
        for (a, b) in ordinary.segments.zip(configured.segments) {
          assert(_deixis-distance(_deixis-sub(a.c1, a.start), _deixis-scale(_deixis-sub(b.c1, b.start), tension)) < 0.000001pt)
          assert(_deixis-distance(_deixis-sub(a.c2, a.end), _deixis-scale(_deixis-sub(b.c2, b.end), tension)) < 0.000001pt)
        }
      }
    }
  }
  // Settings have chunk ownership. Switching to a plain curve resets tension.
  let box = (left: 0pt, right: 180pt, top: 0pt, bottom: 60pt, center-x: 90pt, center-y: 30pt)
  let resolved = _deixis-resolve-waypoints(((kind: "curve", tension: 2), (40pt, 20pt),
    "polyline", (40pt, 0pt), (kind: "catmull-rom", parameterization: "uniform", tension: 0.5)),
    0pt, 0pt, box, box)
  assert.eq(resolved.first(), (kind: "curve", tension: 2))
  assert.eq(resolved.last(), (kind: "ucr", tension: 0.5))
  let mixed = _deixis-waypoint-route(0pt, 0pt, 180pt, 60pt, link-type: (kind: "curve", tension: 2),
    waypoints: ((40pt, 20pt), "curve", (100pt, -10pt)), source-dir: "none", target-dir: "none")
  let first = _deixis-waypoint-route(0pt, 0pt, 40pt, 20pt, link-type: (kind: "curve", tension: 2), source-dir: "none", target-dir: "none")
  assert.eq(mixed.segments.first(), first.segments.first())
  let rest = _deixis-waypoint-route(0pt, 0pt, 140pt, 40pt, link-type: "curve",
    waypoints: ((60pt, -30pt),), source-dir: "none", target-dir: "none")
  for (a, b) in mixed.segments.slice(1).zip(rest.segments) {
    for key in ("start", "end", "c1", "c2") {
      assert(_deixis-distance(a.at(key), _deixis-add(b.at(key), (40pt, 20pt))) < 1e-8pt)
    }
  }
  // Shared tension preserves G1 joins; uniform Catmull also preserves C1.
  for kind in ("curve", "ccr", "ucr") {
    for tension in (0.25, 1, 8) {
      let path = _deixis-waypoint-route(0pt, 0pt, 180pt, 60pt,
        link-type: (kind: kind, tension: tension), waypoints: vertices,
        source-dir: "none", target-dir: "none")
      for pair in path.segments.windows(2) {
        let a = _deixis-sub(pair.first().end, pair.first().c2)
        let b = _deixis-sub(pair.last().c1, pair.last().start)
        assert(_deixis-unit(a).zip(_deixis-unit(b)).all(pair => calc.abs(pair.first() - pair.last()) < 1e-8))
        if kind == "ucr" { assert(_deixis-distance(a, b) < 1e-8pt) }
      }
    }
  }
  // Kind records are literal and atomic through inherited updates.
  let old = (route: (kind: "catmull-rom", parameterization: "uniform", tension: 2), heads: "circle")
  assert.eq(_deixis-merge-config(old, (route: (kind: "curve"))), (route: (kind: "curve"), heads: "circle"))
  assert.eq(_deixis-merge-config(old, (route: (tension: 3))), (route: (tension: 3), heads: "circle"))
  let spec = (kind: "catmull-rom", parameterization: "uniform", tension: 2)
  let sys = (stack: (), connector: (inset-note: (route: spec)))
  assert.eq(_deixis-connector-options(sys, "inset-note", auto).route, (kind: "ucr", tension: 2))
  // A route name is shorthand; records merge field by field from outer
  // defaults to the call. none disables, and via/segments replace each other.
  let scoped = (stack: ((connector: (heads: "stealth")),), connector: (inset-note: "curve"))
  let merged = _deixis-connector-options(scoped, "inset-note", (ports: (mark: right)))
  assert.eq((merged.route, merged.heads, merged.ports), ("curve", "stealth", (mark: "right")))
  assert.eq(_deixis-connector-options(scoped, "inset-note", "polyline").route, "straight-line")
  assert.eq(_deixis-connector-options(scoped, "inset-note", none).route, "none")
  let disabled = (stack: ((connector: none),), connector: "curve")
  assert.eq(_deixis-connector-options(disabled, "inset-note", auto).route, "none")
  assert.eq(_deixis-connector-options(disabled, "inset-note", (heads: "bar")).route, "none")
  let paths = (stack: (), connector: (route: "curve", via: ((10pt, 10pt),)))
  assert.eq(_deixis-connector-options(paths, "inset-note", (segments: ((route: "polyline"),))).via, ("straight-line",))
  let segments = _deixis-connector-options(none, "connection", (segments: (
    (route: (kind: "curve", tension: 2), via: ((40pt, 20pt),)), (route: "polyline"))))
  assert.eq(segments.via, ((kind: "curve", tension: 2), (40pt, 20pt), "straight-line"))
}
