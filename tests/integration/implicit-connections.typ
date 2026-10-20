#import "../../src/lib.typ": *
#set page(width: 600pt, height: 430pt, margin: (x: 120pt, y: 40pt))
#show: deixis-setup-notes
#let ticks = state("implicit-connection-bodies", 0)
#let body = [#ticks.update(n => n + 1)One live body.]
#let painter(name, request) = {
  let doc = request.route.document
  assert.eq(request.heads.mark != none, request.route.has-start and not doc.is-incoming)
  assert.eq(request.heads.body != none, request.route.has-end and not doc.is-outgoing)
  [#metadata((name: name, document: doc, origin: request.route.origin,
    drawable: (request.route.has-start, request.route.has-end),
    segments: request.route.segments, shaft: request.shaft,
    start: request.route.start, end: request.route.end,
    start-tangent: request.route.start-tangent, end-tangent: request.route.end-tangent,
    head-trims: (if request.heads.mark == none { none } else { request.heads.mark.trim },
      if request.heads.body == none { none } else { request.heads.body.trim }),
  ))<implicit-route>]
  for s in request.shaft {
    place(top + left, curve(stroke: request.stroke, curve.move(s.start),
      if s.kind == "line" { curve.line(s.end) } else { curve.cubic(s.c1, s.c2, s.end) }))
  }
  deixis-render-head(request.heads.mark, request.route.start, request.route.start-tangent.map(v => -v))
  deixis-render-head(request.heads.body, request.route.end, request.route.end-tangent)
}
#let options(name) = (route: "curve", heads: (mark: "triangle", body: "circle"), render: painter.with(name))
#for (i, layer) in ("foreground", "background", "flow").enumerate() {
  if i > 0 { pagebreak() }
  let kind = if i == 2 { "region" } else { "inline" }
  deixis-margin-note(mark-type: kind, layer: layer, side: left, width: 85pt,
    connector: options("margin-" + layer))[Margin passage][#body]
  v(50pt)
  deixis-inset-note(mark-type: kind, layer: layer, width: 95pt, dx: 100pt, dy: 50pt,
    connector: options("inset-" + layer) + (
      ports: (mark: (side: right, at: 25%, gap: 2pt), body: left),
      via: ((relative-to: "mark", offset: (30pt, 15pt)),),
    ))[Inset passage][#body]
}
#pagebreak()
#deixis-inline-mark(id: <forward-edge>)[Forward source]
#deixis-inset-note-body(of: <backward-edge>, width: 95pt, layer: "background",
  placement: it => place(top + right, it), connector: options("backward"))[#body]
#pagebreak()
#deixis-inline-mark(id: <backward-edge>)[Backward source]
#deixis-inset-note-body(of: <forward-edge>, width: 95pt, layer: "flow",
  dx: 100pt, dy: 80pt, connector: options("forward"))[#body]
#pagebreak()
#deixis-set(margin-layout: "adaptive")
#for i in range(4) {
  deixis-margin-note(side: right, layer: "foreground", width: 85pt,
    connector: options("spill-" + str(i)))[#block(height: 90pt)[#body]]
}
#pagebreak()
Room for the final margin body.
#context {
  assert.eq(ticks.final(), 12)
  assert.eq(query(<deixis-rendered-start>).len(), 12)
}
