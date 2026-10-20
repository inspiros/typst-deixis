#import "../../src/routing/crossings.typ": *
#let segment(a, b) = (kind: "line", start: a, end: b)
#let horizontal = segment((0pt, 0pt), (100pt, 0pt))
#let vertical = segment((50pt, -50pt), (50pt, 50pt))
#context {
  let spec = _deixis-crossing-spec("gap")
  assert.eq(_deixis-crossing-spec(none), none)
  assert.eq(_deixis-crossing-spec((group: <diagram>)).group, _deixis-crossing-spec((group: "diagram")).group)
  let record(index, shaft, priority: 0, group: "default", layer: "foreground", page: 1,
    thickness: 1pt, clearance: 4pt, cap: "butt") = (
    order: (priority, index), shaft: shaft, spec: spec + (group: group, clearance: clearance),
    supported: true, thickness: thickness, cap: cap, page: page, layer: layer)
  let under = record(0, (horizontal,))
  let over = record(1, (vertical,))
  let plans = _deixis-crossing-plans((over, under))
  assert.eq(plans.at("0").cuts, ((from: 46pt, to: 54pt),))
  assert.eq(plans.at("1").cuts, ())
  assert.eq(plans, _deixis-crossing-plans((under, over)))
  assert.eq(_deixis-crossing-plans(()), (:))
  for upper in (over + (page: 2), over + (layer: "background"),
    over + (spec: spec + (group: "separate")), over + (thickness: 0pt)) {
    assert.eq(_deixis-crossing-plans((under, upper)).at("0").cuts, ())
  }
  let raised = _deixis-crossing-plans((under + (order: (2, 0)), over))
  assert.eq(raised.at("0").cuts, ())
  assert.eq(raised.at("1").hits.len(), 1)
  // Straight-through waypoints are interior points; real corners are contacts.
  let split = record(0, (segment((0pt, 0pt), (50pt, 0pt)), segment((50pt, 0pt), (100pt, 0pt))))
  assert.eq(_deixis-crossing-plans((split, over)).at("0").cuts, plans.at("0").cuts)
  let corner = record(0, (segment((0pt, 0pt), (50pt, 0pt)), segment((50pt, 0pt), (50pt, 20pt))))
  assert.eq(_deixis-crossing-plans((corner, over)).at("0").cuts, ())
  for contact in (segment((0pt, 0pt), (100pt, 0pt)), segment((100pt, 0pt), (100pt, 50pt)),
    segment((0pt, 10pt), (100pt, 10pt))) {
    assert.eq(_deixis-crossing-plans((under, record(1, (contact,)))).at("0").cuts, ())
  }
  let hidden-middle = record(1, (segment((50pt, -50pt), (50pt, -5pt)), segment((50pt, 5pt), (50pt, 50pt))))
  assert.eq(_deixis-crossing-plans((under, hidden-middle)).at("0").cuts, ())
  let near = record(1, (segment((5pt, -50pt), (5pt, 50pt)),))
  assert.eq(_deixis-crossing-plans((under, near)).at("0").skipped.first().reason, "clearance")
  assert.eq(_deixis-crossing-plans((under + (spec: spec + (clearance: 0pt)), near)).at("0").hits.len(), 1)
  let wide = _deixis-crossing-plans((under, over + (thickness: 12pt))).at("0").cuts.first()
  assert.eq(wide.to - wide.from, 12pt)
  let angled = record(1, (segment((0pt, -10pt), (100pt, 10pt)),))
  let widened = _deixis-crossing-plans((under, angled)).at("0").cuts.first()
  assert(widened.to - widened.from > 8pt)
  let doubled = _deixis-crossing-plans((under, over,
    record(2, (segment((53pt, -50pt), (53pt, 50pt)),))))
  assert.eq(doubled.at("0").cuts, ((from: 46pt, to: 57pt),))
  // The middle line is already gapped under the diagonal. Its absent middle
  // must not cause a second cut in the lowest horizontal line.
  let bottom = record(0, (segment((0pt, 1pt), (100pt, 1pt)),))
  let diagonal = record(2, (segment((45pt, -5pt), (55pt, 5pt)),))
  let triple = _deixis-crossing-plans((bottom, over, diagonal)).at("0")
  assert.eq(triple.hits.len(), 1)
  assert.eq(triple.hits.first().over, (0, 2))
  assert(calc.abs(triple.cuts.first().from - 47pt) < 0.00001pt)
}
