#import "../../src/routing/cuts.typ": *
#import "../../src/routing/path.typ": _deixis-waypoint-route, _deixis-render-waypoint-path
#import "../../src/routing/geometry.typ": *
#import "../../src/routing/gaps.typ": _deixis-path-gaps
#import "../../src/routing/heads.typ": deixis-arrowhead
#context {
  let line = (kind: "line", start: (0pt, 0pt), end: (100pt, 0pt))
  let specs = _deixis-cut-specs((at: 50%, length: 12pt))
  let cuts = _deixis-prepare-cuts(specs, 100pt)
  assert.eq(cuts, ((from: 44pt, to: 56pt),))
  let shaft = _deixis-cut-path((line,), cuts)
  assert.eq(shaft.len(), 2)
  assert(_deixis-distance(shaft.first().end, (44pt, 0pt)) < 0.000001pt)
  assert(_deixis-distance(shaft.last().start, (56pt, 0pt)) < 0.000001pt)
  assert.eq((shaft.first().start, shaft.last().end), (line.start, line.end))
  assert.eq(_deixis-cut-path((line,), ()), (line,))
  assert.eq(_deixis-cut-specs(none), ())
  assert.eq(_deixis-cut-specs(()), ())
  let merged = _deixis-prepare-cuts(_deixis-cut-specs((
    (from: 30%, to: 60%), (from: 10pt, to: 35pt), (from: 60pt, to: 70pt),
    (from: 90pt, to: 80pt), (from: 95pt, to: 95pt), (from: 200pt, to: 300pt),
  )), 100pt)
  assert.eq(merged, ((from: 10pt, to: 70pt),))
  assert.eq(_deixis-prepare-cuts(specs, 0pt), ())
  assert.eq(_deixis-cut-path((line,), ((from: 0pt, to: 100pt),)), ())
  let clipped = _deixis-prepare-cuts(_deixis-cut-specs((at: 0%, length: 20pt)), 100pt)
  assert.eq(clipped, ((from: 0pt, to: 10pt),))
  assert.eq(_deixis-path-gaps(_deixis-cut-path((line,), clipped)), ())

  // An analytic cubic proves subdivision retains the original curve, including
  // every sampled point on either side of the missing central interval.
  let cubic = (kind: "cubic", start: (0pt, 0pt), c1: (0pt, 100pt), c2: (100pt, 100pt), end: (100pt, 0pt))
  let length = _deixis-segment-length(cubic)
  let kept = _deixis-cut-path((cubic,), _deixis-prepare-cuts(_deixis-cut-specs((from: 40%, to: 60%)), length))
  assert.eq(kept.len(), 2)
  assert.eq(kept.first().start, cubic.start)
  assert.eq(kept.last().end, cubic.end)
  assert(calc.abs(kept.first().end.at(0) + kept.last().start.at(0) - 100pt) < 0.01pt)
  for segment in kept {
    for u in (0, 0.25, 0.5, 0.75, 1) {
      let p = _deixis-split-segment(segment, u).first().end
      let root = calc.sqrt(calc.max(0, 1 - 4 * p.at(1) / 300pt))
      let t = if p.at(0) <= 50pt { (1 - root) / 2 } else { (1 + root) / 2 }
      assert(calc.abs(p.at(0) - (300 * t * t - 200 * t * t * t) * 1pt) < 0.0001pt)
    }
  }
  for kind in ("polyline", "orthogonal", "chamfer", "curve", "ccr", "ucr") {
    let route = _deixis-waypoint-route(0pt, 0pt, 150pt, 80pt,
      link-type: kind, waypoints: ((40pt, 50pt), (90pt, 25pt)), link-radius: 8pt)
    let shaft = _deixis-cut-path(route.segments,
      _deixis-prepare-cuts(_deixis-cut-specs((at: 50%, length: 12pt)), route.length))
    assert.eq(shaft.first().start, route.start)
    assert.eq(shaft.last().end, route.end)
    assert.eq(_deixis-path-gaps(shaft).len(), 1)
    let remaining = shaft.map(s => _deixis-segment-length(s)).fold(0pt, (a, b) => a + b)
    assert(calc.abs(route.length - remaining - 12pt) < 0.03pt)
  }
  // Old discontinuities have zero arc-length measure. New cuts can overlap
  // them without joining subpaths, and endpoint cuts leave no marker pair.
  let other = line + (start: (130pt, 0pt), end: (230pt, 0pt))
  let shaft = _deixis-cut-path((line, other), ((from: 90pt, to: 110pt),))
  assert.eq(shaft.len(), 2)
  assert(_deixis-distance(shaft.first().end, (90pt, 0pt)) < 0.000001pt)
  assert(_deixis-distance(shaft.last().start, (140pt, 0pt)) < 0.000001pt)
  // Cut positions keep the original source-distance basis despite head trim.
  for mark in (none, "circle") {
    let check(request) = {
      assert.eq(request.heads.mark != none, mark != none)
      assert(request.heads.body != none)
      assert.eq(request.cuts, cuts)
      assert(_deixis-distance(request.gaps.first().start, (44pt, 0pt)) < 0.000001pt)
      assert(_deixis-distance(request.gaps.first().end, (56pt, 0pt)) < 0.000001pt)
      assert.eq(request.route.start, (0pt, 0pt))
      assert.eq(request.route.end, (100pt, 0pt))
      []
    }
    let output = _deixis-render-waypoint-path(0pt, 0pt, 100pt, 0pt, link-cuts: specs,
      link-heads: (mark: mark, body: "triangle"), link-render: check)
  }
  let after-old-gap(request) = {
    assert.eq(request.uncut-shaft.first().start, (130pt, 0pt))
    assert(_deixis-distance(request.shaft.first().start, (140pt, 0pt)) < 0.000001pt)
    assert.eq(request.gaps, ())
    []
  }
  let output = _deixis-render-waypoint-path(0pt, 0pt, 230pt, 0pt,
    waypoints: ((100pt, 0pt), "none", (130pt, 0pt), "polyline"),
    link-cuts: (from: 90pt, to: 110pt),
    link-heads: (mark: deixis-arrowhead(trim: 120pt)), link-render: after-old-gap)
  let all-hidden(request) = {
    assert.eq(request.shaft, ())
    assert(request.uncut-shaft.len() > 0)
    assert(request.heads.mark != none and request.heads.body != none)
    assert.eq(request.gaps, ())
    []
  }
  let output = _deixis-render-waypoint-path(0pt, 0pt, 100pt, 0pt,
    link-cuts: (from: 0pt, to: 100%), link-heads: (mark: "circle", body: "triangle"), link-render: all-hidden)
}
