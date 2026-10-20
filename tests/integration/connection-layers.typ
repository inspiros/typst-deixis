#import "../../src/lib.typ": *
#set page(width: 560pt, height: 430pt, margin: (x: 110pt, y: 40pt))
#show: deixis-setup-notes
#let ticks = state("connection-layer-bodies", 0)
#let body = [#ticks.update(n => n + 1)One body.]
#let painter(name, expected, request) = {
  assert.eq(request.route.document.layer, expected)
  assert.eq(text.size, 18pt)
  [#metadata((name: name, layer: expected, page: request.route.document.page,
    source: request.route.document.source-page, target: request.route.document.target-page))<layer-route>]
  for s in request.shaft {
    place(top + left, curve(stroke: request.stroke, curve.move(s.start),
      if s.kind == "line" { curve.line(s.end) } else { curve.cubic(s.c1, s.c2, s.end) }))
  }
}
#let connector(name, layer) = (route: "curve", layer: layer,
  render: painter.with(name, if layer == auto { "foreground" } else { layer }))
#{
  set text(size: 18pt)
  for (i, body-layer) in ("foreground", "background", "flow").enumerate() {
    for (j, connection-layer) in (auto, "foreground", "background").enumerate() {
      if i + j > 0 { pagebreak() }
      let name = body-layer + "-" + str(j)
      deixis-margin-note(layer: body-layer, side: right, width: 85pt,
        connector: connector("margin-" + name, connection-layer))[#body]
      v(45pt)
      deixis-inset-note(layer: body-layer, width: 90pt, dx: 90pt, dy: 60pt,
        connector: connector("inset-" + name, connection-layer))[Source][#body]
    }
  }
  pagebreak()
  for layer in ("foreground", "background") {
    deixis-inline-mark(id: "forward-" + layer)[Forward source.]
    deixis-inset-note-body(of: "backward-" + layer, width: 85pt, layer: "foreground",
      placement: it => place(top + right, it), connector: connector("backward-" + layer, layer))[#body]
  }
  pagebreak()
  for layer in ("foreground", "background") {
    deixis-inline-mark(id: "backward-" + layer)[Backward source.]
    deixis-inset-note-body(of: "forward-" + layer, width: 85pt, layer: "flow", dx: 90pt, dy: 60pt,
      connector: connector("forward-" + layer, layer))[#body]
  }
  pagebreak()
  for i in range(4) {
    deixis-margin-note(layer: "foreground", width: 85pt, side: right,
      connector: connector("spill-" + str(i), "background"))[#block(height: 90pt)[#body]]
  }
  pagebreak()
  [Room for the last margin body.]
}
#context {
  assert.eq(ticks.final(), 26)
  assert.eq(query(<deixis-rendered-start>).len(), 26)
}
