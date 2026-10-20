#import "../../src/lib.typ": *
#set page(width: 560pt, height: 430pt, margin: (x: 110pt, y: 40pt))
#show: deixis-setup-notes
#let ticks = state("explicit-adapter-bodies", 0)
#let body = [#ticks.update(n => n + 1)One body.]
#let painter(name, request) = {
  [#metadata((name: name, document: request.route.document))<explicit-adapter-route>]
}
#for (i, layer) in ("foreground", "background", "flow").enumerate() {
  if i > 0 { pagebreak() }
  for kind in ("margin", "inset") {
    let id = kind + "-" + layer
    deixis-inline-mark(id: id)[Primary source]
    if kind == "margin" {
      deixis-margin-note-body(of: id, layer: layer, width: 90pt, side: right, connector: none)[#body]
    } else {
      deixis-inset-note-body(of: id, layer: layer, width: 90pt, dx: 90pt, dy: 80pt, connector: none)[#body]
    }
    deixis-mark(of: id, occurrence: "again")[Repeat]
    deixis-connect(from: (mark: id, occurrence: "again"), to: id,
      connector: (route: "orthogonal", render: painter.with(id), heads: (body: "triangle")))
    v(60pt)
  }
}
#pagebreak()
// Implicit edges remain additive; an explicit edge never silently replaces one.
#deixis-margin-note(id: <additive>, width: 90pt, connector: (route: "curve", render: painter.with("implicit")))[#body]
#deixis-connect(from: <additive>, to: <additive>, connector: (route: "straight-line", render: painter.with("explicit")))
// Standalone inset destinations publish actual probes even without an original.
#deixis-inset-note-body(id: <solo>, layer: "flow", width: 90pt, dx: 100pt, dy: 80pt)[#body]
#deixis-connect(from: <additive>, to: <solo>, connector: (route: "curve", render: painter.with("standalone")))
#for layer in ("background", "foreground") {
  let name = "standalone-" + layer
  deixis-inset-note-body(id: label(name), layer: layer, width: 90pt,
    placement: it => place(top + right, it))[#body]
  deixis-connect(from: <additive>, to: label(name),
    connector: (route: "curve", render: painter.with(name)))
}
#context {
  assert.eq(ticks.final(), 10)
  assert.eq(query(<deixis-rendered-start>).len(), 10)
}
