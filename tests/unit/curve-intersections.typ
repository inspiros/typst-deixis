#import "../../src/routing/intersections.typ": *
#import "../../src/routing/crossings.typ": *
#import "../../src/routing/geometry.typ": *
#import "../../src/routing/cuts.typ": _deixis-cut-path
#let line(a, b) = (kind: "line", start: a, end: b)
#let arch = (kind: "cubic", start: (0pt, 0pt), c1: (0pt, 100pt), c2: (100pt, 100pt), end: (100pt, 0pt))
#let horizontal(y) = line((-10pt, y), (110pt, y))
#let path(s) = _deixis-crossing-path((s,)).first()
#let intersections(a, b) = _deixis-segment-intersections(path(a), path(b))
#let record(index, segments) = (order: (0, index), shaft: segments, supported: true,
  thickness: 1pt, cap: "butt", page: 1, layer: "foreground", spec: _deixis-crossing-spec("gap"))
#context {
  let hits = intersections(arch, horizontal(50pt))
  assert.eq(hits.len(), 2)
  let t = (1 - calc.sqrt(1 / 3)) / 2
  assert(calc.abs(hits.first().t - t) < 0.0000001)
  assert(calc.abs(hits.last().t - (1 - t)) < 0.0000001)
  for h in hits {
    assert(_deixis-distance(h.point, _deixis-segment-point(arch, h.t)) < 0.000001pt)
    assert(calc.abs(h.point.last() - 50pt) < 0.000001pt)
  }
  assert.eq(intersections(arch, horizontal(75pt)), ()) // exact tangency
  assert.eq(intersections(arch, horizontal(75.01pt)), ()) // near miss
  assert.eq(intersections(arch, arch), ()) // coincident curves
  assert.eq(intersections(arch, horizontal(0pt)), ()) // shared path endpoints
  assert.eq(intersections(arch, horizontal(74.9pt)).len(), 2)
  let vertical = line((50pt, -30pt), (50pt, 120pt))
  assert.eq(intersections(arch, vertical).len(), 1) // dyadic subdivision boundary
  let flipped = arch + (start: (0pt, 75pt), end: (100pt, 75pt), c1: (0pt, -25pt), c2: (100pt, -25pt))
  assert.eq(intersections(arch, flipped).len(), 2)
  // Swapping, reversing, reflecting, and translating preserve physical roots.
  for (sx, sy) in ((1, 1), (-1, 1), (1, -1), (-1, -1)) {
    let transform(s) = {
      for key in ("start", "end", "c1", "c2") {
        if key in s { s.at(key) = (s.at(key).first() * sx + 200pt, s.at(key).last() * sy - 40pt) }
      }
      s
    }
    let a = transform(arch)
    let b = transform(horizontal(50pt))
    assert.eq(intersections(a, b).len(), 2)
    assert.eq(intersections(b, a).len(), 2)
    assert.eq(intersections(_deixis-reverse-segments((a,)).first(), b).len(), 2)
  }
  // Smooth joins are eligible once; a true corner remains a contact.
  let (left, right) = _deixis-split-segment(arch, 0.5)
  let joined = _deixis-crossing-plans((record(0, (left, right)), record(1, (vertical,))))
  assert.eq(joined.at("0").hits.len(), 1)
  let protected = record(0, (left, right))
  protected.spec.clearance = 120pt
  assert.eq(_deixis-crossing-plans((protected, record(1, (vertical,)))).at("0").skipped.len(), 1)
  let corner = (left, line(left.end, (70pt, 120pt)))
  assert.eq(_deixis-crossing-plans((record(0, corner), record(1, (vertical,)))).at("0").hits, ())
  let plan = _deixis-crossing-plans((record(0, (arch,)), record(1, (horizontal(50pt),)))).at("0")
  assert.eq(plan.cuts.len(), 2)
  let visible = _deixis-cut-path((arch,), plan.cuts)
  assert.eq(visible.len(), 3)
  assert(visible.all(s => s.kind == "cubic"))
  // Every sampled surviving point remains on the original analytic arch.
  for s in visible {
    for u in (0, 0.25, 0.5, 0.75, 1) {
      let p = _deixis-segment-point(s, u)
      let root = calc.sqrt(calc.max(0, 1 - 4 * p.last() / 300pt))
      let t = if p.first() <= 50pt { (1 - root) / 2 } else { (1 + root) / 2 }
      assert(calc.abs(p.first() - (300 * t * t - 200 * t * t * t) * 1pt) < 0.0001pt)
    }
  }
  // Closed cubics and collinear reversals must not flatten to their zero chord.
  let loop = arch + (end: arch.start, c2: (100pt, 100pt))
  assert(_deixis-intersection-tree(loop).leaves > 1)
  assert.eq(intersections(loop, horizontal(50pt)).len(), 2)
  let reversal = arch + (c1: (200pt, 0pt), c2: (-100pt, 0pt))
  assert(_deixis-intersection-tree(reversal).leaves > 1)
  assert.eq(intersections(reversal, vertical).len(), 3)
  let middle = (kind: "cubic", start: (50pt, -50pt), c1: (50pt, -20pt), c2: (50pt, 20pt), end: (50pt, 50pt))
  let bottom = line((0pt, 1pt), (100pt, 1pt))
  let diagonal = line((45pt, -5pt), (55pt, 5pt))
  let triple = _deixis-crossing-plans((record(0, (bottom,)), record(1, (middle,)), record(2, (diagonal,))))
  assert.eq(triple.at("0").hits.len(), 1)
  assert.eq(triple.at("0").hits.first().over, (0, 2))
  let missing = _deixis-cut-path((arch,), ((from: 90pt, to: 110pt),))
  assert.eq(_deixis-crossing-plans((record(0, (vertical,)), record(1, missing))).at("0").hits, ())
  let huge = arch
  for key in ("start", "end", "c1", "c2") { huge.at(key) = huge.at(key).map(v => v * 1e8) }
  let limited = _deixis-intersection-tree(huge)
  assert(not limited.resolved)
  assert(limited.leaves <= 1024)
}
