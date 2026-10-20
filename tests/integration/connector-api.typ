#import "../../src/lib.typ": *
#import "../../src/routing/path.typ": _deixis-route-connection
#import "../../src/routing/connections.typ": *
#set page(width: 600pt, height: 520pt, margin: 80pt)
#show: deixis-setup-notes
#deixis-set(connector: (inset-note: (radius: 3pt)))

#let ports(x, y) = (
  (x: x + 10pt, y: y, dir: "vertical", id: "top"),
  (x: x + 10pt, y: y + 20pt, dir: "vertical", id: "bottom"),
  (x: x, y: y + 10pt, dir: "horizontal", id: "left"),
  (x: x + 20pt, y: y + 10pt, dir: "horizontal", id: "right"),
)
#let capture(args) = {
  assert.eq((args.S-x + args.waypoints.first().at(0), args.S-y + args.waypoints.first().at(1)), (0pt, 100pt))
  [#metadata("legacy")<connector-event>]
}
#context {
  _deixis-route-connection(_deixis-prepared-connection(
    _deixis-connection-node("mark", 1, ports(0pt, 0pt)),
    _deixis-connection-node("body", 1, ports(80pt, 80pt)),
    _deixis-connection-options((link: capture, link-ports: (mark: "top", body: "top"),
      link-waypoints: (("mark-left", "body-bottom"),))),
  ), 1).join()
}
#let head(request) = (
  body: place(top + left, [#metadata(request.endpoint)<custom-head>]),
  trim: 2pt, bounds: (left: -4pt, top: -3pt, right: 0pt, bottom: 3pt),
)
#deixis-inset-note(layer: "foreground", dx: 100pt, dy: 30pt, width: 80pt,
  connector: (route: "catmull-rom-centripetal", ports: (mark: (side: right, at: 25%, gap: 2pt), body: left),
    via: ((relative-to: "mark", offset: (30pt, 0pt)),), heads: (mark: head, body: head)),
)[Structured][Custom heads.]
#v(100pt)
#let renderer(request) = {
  assert.eq(request.frame, "source-local-x-right-y-down")
  assert(request.route.document.nodes.mark.bounds.left <= request.route.document.nodes.mark.bounds.right)
  assert(request.route.segments.len() > 0 and request.shaft.len() > 0)
  assert(request.heads.mark == none and request.heads.body != none)
  [#metadata("modern")<connector-event>]
  for s in request.shaft {
    place(top + left, curve(stroke: request.stroke, curve.move(s.start),
      if s.kind == "line" { curve.line(s.end) } else { curve.cubic(s.c1, s.c2, s.end) }))
  }
  deixis-render-head(request.heads.body, request.route.end, request.route.end-tangent)
}
#deixis-margin-note(connector: (route: "orthogonal", ports: (right, left),
  heads: (body: "diamond"), render: renderer))[Renderer.]
#v(50pt)
#deixis-inset-note(layer: "background", dx: 120pt, dy: 20pt, width: 70pt,
  connector: (segments: ((route: "curve", via: ((20pt, 10pt),)), (route: "polyline",)),
    heads: (body: deixis-arrowhead(shape: "triangle", length: 7pt, width: 5pt))))[Mixed][Segments.]
#v(30pt)
#let legacy(request) = {
  assert.eq(request.dx, request.E-x - request.S-x)
  assert.eq(request.dy, request.E-y - request.S-y)
  [#metadata("public-legacy")<connector-event>]
  line(end: (request.dx, request.dy), stroke: request.stroke)
}
#deixis-margin-note(connector: (route: legacy, ports: (right, left)))[Public legacy callback.]
#context {
  assert.eq(query(<connector-event>).map(n => n.value).sorted(), ("legacy", "modern", "public-legacy"))
  assert.eq(query(<custom-head>).map(n => n.value).sorted(), ("body", "mark"))
}
