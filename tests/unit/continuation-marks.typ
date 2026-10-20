#import "../../src/lib.typ": *
#import "../../src/routing/continuation-marks.typ": *
#import "../../src/routing/path.typ": _deixis-render-waypoint-path
#context {
  for cap in ("butt", "round", "square") {
    let line = stroke(paint: blue, thickness: 1pt, cap: cap, dash: "dashed")
    let portal = _deixis-prepare-continuation-mark(_deixis-continuation-spec("portal"), line)
    assert.eq(portal.fill, none)
    assert.eq(portal.stroke.dash, none)
    assert.eq(portal.size, 4pt)
    let protrusion = if cap == "butt" { 0pt } else { 0.5pt }
    assert.eq(portal.trim - protrusion, portal.radius - portal.stroke.thickness / 2)
    for incoming in (false, true) {
      for cuts in (none, (at: 50%, length: 8pt)) {
        let inspect(r) = {
          assert.eq(r.heads, (mark: none, body: none))
          assert.eq((r.route.start, r.route.end), ((0pt, 0pt), (100pt, 0pt)))
          let start = if incoming { (portal.trim, 0pt) } else { (0pt, 0pt) }
          let end = if incoming { (100pt, 0pt) } else { (100pt - portal.trim, 0pt) }
          assert.eq((r.shaft.first().start, r.shaft.last().end), (start, end))
          if cuts != none {
            // Portal trimming must not shift cuts' original arc-length basis.
            assert(calc.abs(r.gaps.first().start.first() - 46pt) < 0.000001pt)
            assert(calc.abs(r.gaps.first().end.first() - 54pt) < 0.000001pt)
          }
          []
        }
        let result = _deixis-render-waypoint-path(0pt, 0pt, 100pt, 0pt,
          link-stroke: line, link-render: inspect, link-cuts: cuts,
          continuation-mark: portal, continuation-endpoint: if incoming { "mark" } else { "body" })
        assert.eq(result.len(), 2)
      }
    }
    assert.eq(_deixis-prepare-continuation-mark(_deixis-continuation-spec("portal"), none), none)
    assert.eq(_deixis-prepare-continuation-mark(_deixis-continuation-spec((stroke: none)), line), none)
  }
  let stealth = deixis-prepare-connector(deixis-route(from: (0pt, 0pt), to: (100pt, 0pt)),
    heads: deixis-arrowhead(shape: "stealth", length: 10pt, width: 9pt))
  let triangle = deixis-prepare-connector(deixis-route(from: (0pt, 0pt), to: (100pt, 0pt)),
    heads: deixis-arrowhead(shape: "triangle", length: 10pt, width: 9pt))
  assert.eq(stealth.heads.body.bounds, triangle.heads.body.bounds)
  assert(stealth.shaft.last().end.first() > triangle.shaft.last().end.first())
  assert(stealth.heads.body.request.fill != none)
  let ring = _deixis-prepare-continuation-mark(_deixis-continuation-spec("portal"), black + 1pt)
  let missing = _deixis-render-waypoint-path(0pt, 0pt, 100pt, 0pt,
    link-type: "none", continuation-mark: ring, link-render: _ => [])
  assert.eq(missing.len(), 1) // No orphaned ring at a deliberately undrawn end.
  {
    set text(size: 20pt)
    context assert.eq(_deixis-continuation-spec((size: 0.5em)).size, 10pt)
  }
}
