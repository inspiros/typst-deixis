#import "../../src/lib.typ": *
#set page(width: 440pt, height: auto, margin: (x: 65pt, y: 25pt))
#show: deixis-setup-notes
#let painter(request) = {
  let doc = request.route.document
  let frame = query(<deixis-page-frame>).find(f=>f.value.page == doc.page).value
  if doc.is-outgoing {
    assert(calc.abs(doc.endpoints.body.point.at(1) - (frame.height - frame.margins.bottom)) < 0.001pt)
  }
  if doc.is-incoming { assert(calc.abs(doc.endpoints.mark.point.at(1) - calc.min(frame.margins.top, doc.nodes.body.bounds.top)) < 0.001pt) }
  [#metadata(doc.page)<auto-route>]
  for segment in request.shaft {
    place(top + left, curve(stroke: request.stroke, curve.move(segment.start),
      if segment.kind == "line" { curve.line(segment.end) } else { curve.cubic(segment.c1, segment.c2, segment.end) }))
  }
}
#let page-waypoint(request) = {
  let doc = request.route.document
  let frame = query(<deixis-page-frame>).find(f=>f.value.page == doc.page).value
  let point = request.route.segments.first().end
  let origin = doc.endpoints.mark.point
  assert(calc.abs(point.at(0) + origin.at(0) - frame.width / 2) < 0.001pt)
  assert(calc.abs(point.at(1) + origin.at(1) - frame.height / 2) < 0.001pt)
  [#metadata(doc.page)<page-waypoint>]
}
#deixis-inline-mark(id: <cross>)[A source on a short page.]
#block(height: 80pt)[First page content.]
#pagebreak()
#deixis-inset-note-body(of: <cross>, layer: "foreground", width: 90pt,
  placement: body => place(top + right, body), connector: (route: "straight-line", heads: none, render: painter))[Destination.]
#block(height: 130pt)[Second page content.]
Percentages#deixis-inset-note(layer: "foreground", width: 70pt, dx: 70pt, dy: 30pt,
  connector: (route: "polyline", via: ((relative-to: "page", offset: (50%, 50%)),), heads: none, render: page-waypoint))[Waypoint destination.]
#context {
  assert.eq(query(<auto-route>).map(m=>m.value), (1, 2))
  assert.eq(query(<page-waypoint>).map(m=>m.value), (2,))
}
