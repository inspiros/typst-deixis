#import "../../src/routing/bspline.typ": _deixis-bspline-cmds
#import "../../src/routing/geometry.typ": *
#import "../../src/routing/path.typ": _deixis-waypoint-route, _deixis-resolve-waypoints
#import "../../src/routing/spec.typ": _deixis-route-spec
#context {
  let start = (0pt, 0pt)
  let end = (180pt, 40pt)
  let points = ((25pt, -45pt), (70pt, 60pt), (70pt, 60pt), (140pt, -20pt), (155pt, 30pt))
  assert.eq(_deixis-route-spec((kind: "b-spline")), "b-spline")
  assert.eq(_deixis-route-spec((kind: "b-spline", controls: ())), "b-spline")
  assert.eq(_deixis-bspline-cmds(start, start, controls: (start, start)), ())
  assert.eq(_deixis-waypoint-route(..start, ..start, link-type: "b-spline",
    source-normal: (0, -1), target-normal: (0, 1)).segments, ())
  let loop = _deixis-waypoint-route(..start, ..start,
    link-type: (kind: "b-spline", controls: points), source-dir: "none", target-dir: "none")
  assert(loop.segments.len() > 0 and loop.has-start and loop.has-end)
  for n in range(points.len() + 1) {
    let controls = points.slice(0, n)
    let commands = _deixis-bspline-cmds(start, end, controls: controls)
    let segments = _deixis-path-segments((_deixis-move(start),) + commands)
    assert.eq(segments.len(), calc.max(1, n - 1))
    assert.eq((segments.first().start, segments.last().end), (start, end))
    if n == 0 { assert.eq(commands, (_deixis-line(end),)) }
    if n == 1 {
      assert.eq(commands.first().c1, _deixis-lerp(start, points.first(), 2 / 3))
      assert.eq(commands.first().c2, _deixis-lerp(end, points.first(), 2 / 3))
      assert(_deixis-distance(_deixis-split-segment(segments.first(), 0.5).first().end, points.first()) > 10pt)
    }
    if n == 2 { assert.eq(commands, (_deixis-cubic(..controls, end),)) }
    if n >= 3 {
      for pair in segments.windows(2) {
        let a = pair.first()
        let b = pair.last()
        assert(_deixis-distance(_deixis-sub(a.end, a.c2), _deixis-sub(b.c1, b.start)) < 1e-8pt)
        let second(s, terminal) = if terminal {
          _deixis-add(_deixis-sub(s.end, _deixis-scale(s.c2, 2)), s.c1)
        } else { _deixis-add(_deixis-sub(s.start, _deixis-scale(s.c1, 2)), s.c2) }
        assert(_deixis-distance(second(a, true), second(b, false)) < 1e-8pt)
      }
    }
    // The free control polygon, including multiplicities, is affine covariant.
    let transform(p) = _deixis-add(_deixis-scale(p, 0.03), (15pt, -7pt))
    let moved = _deixis-bspline-cmds(transform(start), transform(end), controls: controls.map(transform))
    for (a, b) in commands.zip(moved) {
      for key in if n == 0 { ("end",) } else { ("c1", "c2", "end") } {
        assert(_deixis-distance(transform(a.at(key)), b.at(key)) < 1e-8pt)
      }
    }
    for normal in ((1, 0), (-1, 0), (0, 1), (0, -1)) {
      let forced = _deixis-waypoint-route(..start, ..end, link-type: (kind: "b-spline", controls: controls),
        source-dir: "none", target-dir: "none", source-normal: normal, target-normal: normal)
      assert.eq(forced.start-tangent, normal)
      assert.eq(forced.end-tangent, normal.map(v => -v))
    }
  }
  // Repeated equal route records still delimit independently owned sections.
  let spec = (kind: "b-spline", controls: ((30pt, -20pt),))
  let mixed = _deixis-waypoint-route(..start, ..end, link-type: spec,
    waypoints: ((70pt, 20pt), spec), source-dir: "none", target-dir: "none")
  assert.eq(mixed.segments.len(), 2)
  assert.eq(mixed.segments.first().end, (70pt, 20pt))
  assert.eq(mixed.segments.last().c1, _deixis-lerp((70pt, 20pt), (30pt, -20pt), 2 / 3))
  let box = (left: 0pt, top: 0pt, right: 180pt, bottom: 40pt, center-x: 90pt, center-y: 20pt)
  let resolved = _deixis-resolve-waypoints(((kind: "b-spline", controls: (
    (10pt, 15pt), (relative-to: "previous", offset: (20pt, -5pt)),
    (relative-to: "body", anchor: bottom + right, offset: (-10pt, -5pt)),
  )), (35pt, 5pt)), 5pt, 7pt, box, box)
  assert.eq(resolved.first().controls, ((15pt, 22pt), (35pt, 17pt), (170pt, 35pt)))
  assert.eq(resolved.last(), (40pt, 12pt)) // Influences never advance the hard-waypoint origin.
}
