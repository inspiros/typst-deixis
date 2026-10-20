#import "../../src/routing/hobby.typ": _deixis-hobby-cmds
#import "../../src/routing/geometry.typ": *
#import "../../src/routing/path.typ": _deixis-waypoint-route
#import "../../src/routing/spec.typ": _deixis-route-spec
#import "../../src/core/internal.typ": _deixis-connector-options
#context {
  let oracle = json("../fixtures/hobby-metapost.json")
  for case in oracle.cases {
    let points = case.points.map(p => p.map(x => x * 1pt))
    let actual = _deixis-hobby-cmds(points, tension: case.tension, curl: case.curl,
      source-normal: if case.source == none { auto } else { case.source },
      target-normal: if case.target == none { auto } else { case.target })
    assert.eq(actual.len(), case.segments.len())
    for (a, b) in actual.zip(case.segments) {
      for (point, index) in ((a.c1, 1), (a.c2, 2), (a.end, 3)) {
        assert(_deixis-distance(point, b.at(index).map(x => x * 1pt)) < oracle.tolerance_pt * 1pt)
      }
    }
  }
  for spec in ((kind: "hobby"), (kind: "hobby", tension: 1, curl: 1),
    (kind: "hobby", curl: (:)), (kind: "hobby", curl: (body: 1))) {
    assert.eq(_deixis-route-spec(spec), "hobby")
  }
  let partial = _deixis-route-spec((kind: "hobby", curl: (mark: 0)))
  assert.eq(partial, (kind: "hobby", curl: (mark: 0, body: 1)))
  assert.eq(_deixis-route-spec(partial), partial)
  let points = ((0pt, 0pt), (25pt, 65pt), (145pt, -20pt), (180pt, 40pt))
  for tension in (0.75, 1, 2, 4) {
    for curl in ((mark: 0, body: 0), (mark: 1, body: 1), (mark: 2, body: 0.25)) {
      let reference = _deixis-hobby-cmds(points, tension: tension, curl: curl)
      let segments = _deixis-path-segments((_deixis-move(points.first()),) + reference)
      assert.eq(segments.map(s => s.end), points.slice(1))
      for pair in segments.windows(2) {
        let a = _deixis-segment-tangent(pair.first(), end: true)
        let b = _deixis-segment-tangent(pair.last())
        assert(a.zip(b).all(v => calc.abs(v.first() - v.last()) < 1e-8))
      }
      // Similarities preserve the open solution; free endpoint curls have no
      // physical minimum-handle policy or unit-dependent knot epsilon.
      for factor in (0.001, 1000) {
        let transformed = _deixis-hobby-cmds(points.map(p => p.map(v => v * factor)), tension: tension, curl: curl)
        for (a, b) in reference.zip(transformed) {
          for key in ("c1", "c2", "end") {
            assert(_deixis-distance(a.at(key), b.at(key).map(v => v / factor)) < 1e-8pt)
          }
        }
      }
      for normal in ((1, 0), (-1, 0), (0, 1), (0, -1)) {
        let path = _deixis-waypoint-route(..points.first(), ..points.last(),
          link-type: (kind: "hobby", tension: tension, curl: curl), waypoints: points.slice(1, -1),
          source-normal: normal, target-normal: normal)
        assert.eq(path.start-tangent, normal)
        assert.eq(path.end-tangent, normal.map(x => -x))
      }
    }
  }
  // Curl is the free-boundary condition. Fixed directions replace it before
  // solving all interior angles, rather than rotating finished handles.
  assert.eq(_deixis-hobby-cmds(points, curl: (mark: 0, body: 2), source-normal: (-1, 0), target-normal: (0, -1)),
    _deixis-hobby-cmds(points, source-normal: (-1, 0), target-normal: (0, -1)))
  assert.eq(_deixis-hobby-cmds(((0pt, 0pt), (0pt, 0pt))), ())
  assert.eq(_deixis-waypoint-route(0pt, 0pt, 0pt, 0pt, link-type: "hobby",
    source-normal: (0, -1), target-normal: (0, 1)).segments, ())
  let repeated = (points.first(), points.first(), points.at(1), points.at(1)) + points.slice(2)
  assert.eq(_deixis-hobby-cmds(repeated), _deixis-hobby-cmds(points))
  let line = _deixis-hobby-cmds((points.first(), points.last()), tension: 2).first()
  assert(_deixis-distance(line.c1, _deixis-scale(points.last(), 1 / 6)) < 1e-8pt)
  assert(_deixis-distance(line.c2, _deixis-scale(points.last(), 5 / 6)) < 1e-8pt)
  let loose = _deixis-hobby-cmds(points)
  let tight = _deixis-hobby-cmds(points, tension: 2)
  assert(_deixis-distance(_deixis-scale(loose.first().c1, 0.5), tight.first().c1) > 0.1pt,
    message: "Hobby tension must participate in the global angle solve.")
  // An explicit equal route switch delimits a fresh global solve. The public
  // segments and via forms must preserve precisely the same ownership.
  for spec in ("hobby", (kind: "hobby", tension: 2, curl: (mark: 0, body: 2))) {
    let options = _deixis-connector-options(none, "connection", (segments: (
      (route: spec, via: (points.at(1),)), (route: spec, via: (points.at(2),)))))
    let via = (spec, points.at(1), spec, points.at(2))
    assert.eq(options.via, via)
    let path = _deixis-waypoint-route(..points.first(), ..points.last(),
      link-type: spec, waypoints: via, source-dir: "none", target-dir: "none")
    let first = _deixis-waypoint-route(..points.first(), ..points.at(1),
      link-type: spec, source-dir: "none", target-dir: "none")
    assert.eq(path.segments.first(), first.segments.first())
    let rest = _deixis-hobby-cmds(points.slice(1),
      tension: if type(spec) == dictionary { spec.tension } else { 1 },
      curl: if type(spec) == dictionary { spec.curl } else { (mark: 1, body: 1) })
    assert.eq(path.segments.slice(1), _deixis-path-segments((_deixis-move(points.at(1)),) + rest))
  }
  let loop = _deixis-waypoint-route(0pt, 0pt, 0pt, 0pt, link-type: "hobby",
    waypoints: points.slice(1), source-dir: "none", target-dir: "none")
  assert.eq(loop.segments.len(), points.len())
  assert(loop.has-start and loop.has-end)
}
