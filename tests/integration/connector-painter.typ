#import "../../src/lib.typ": deixis-render-connector, deixis-arrowhead
#import "../../src/routing/path.typ": _deixis-render-waypoint-path
#set page(width: 600pt, height: 620pt, margin: 20pt)
#let painter = sys.inputs.at("painter", default: "native")
#let rendered = state("connector-painter-heads", ())
#let custom(request) = {
  // The helper reuses prepared content, without calling this callback again.
  (body: [#rendered.update(xs => xs + (request.endpoint,))#place(top + left,
    curve(fill: request.fill, stroke: none, curve.move((0pt, 0pt)),
      curve.line((-7pt, -3pt)), curve.line((-7pt, 3pt)), curve.close()))],
    trim: 7pt, bounds: (left: -7pt, top: -3pt, right: 0pt, bottom: 3pt))
}
#let delegate(request) = {
  assert.eq(request.frame, "source-local-x-right-y-down")
  let snapshot = request
  let output = deixis-render-connector(request)
  assert.eq(request, snapshot)
  output
}
#context {
  for (i, route) in ("polyline", "orthogonal", "chamfer", "curve", "ccr", "ucr").enumerate() {
    for (j, thickness) in (0.5pt, 2pt, 4pt).enumerate() {
      let sx = 20pt + j * 180pt
      let sy = 15pt + i * 80pt
      _deixis-render-waypoint-path(sx, sy, sx + 135pt, sy + 50pt,
        waypoints: ((45pt, 25pt), (75pt, 25pt)), link-type: route, link-radius: 8pt,
        link-stroke: stroke(paint: blue, thickness: thickness,
          dash: (none, "dashed", "dotted").at(j), cap: ("butt", "round", "square").at(j)),
        source-dir: "horizontal", target-dir: "vertical",
        link-heads: (mark: deixis-arrowhead(shape: "circle", length: 6pt, width: 8pt), body: custom),
        link-render: if painter == "native" { none } else { delegate }).join()
    }
  }
  // Discontinuous shafts, disabled shafts, consumed shafts, and no endpoint path.
  for (i, data) in (
    (waypoints: ((40pt, 0pt), "none", (70pt, 0pt), "polyline")),
    (link-stroke: none),
    (link-heads: (mark: deixis-arrowhead(length: 180pt), body: "triangle")),
    (waypoints: ("none",)),
  ).enumerate() {
    _deixis-render-waypoint-path(20pt + i * 140pt, 535pt, 130pt + i * 140pt, 535pt,
      link-stroke: data.at("link-stroke", default: red + 1pt),
      link-heads: data.at("link-heads", default: (mark: "bar", body: "diamond")),
      waypoints: data.at("waypoints", default: ()),
      link-gap-marks: "slash",
      link-cuts: (at: 50%, length: 12pt),
      link-render: if painter == "native" { none } else { delegate }).join()
  }
}
#let verify() = assert.eq(rendered.final(), ("body",) * 18)
