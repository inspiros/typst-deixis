#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#import "../../src/routing/frames.typ": _deixis-body-spans
#set page(width: 530pt, height: 350pt, margin: (x: 110pt, y: 35pt))
#set text(size: 10pt)
#show: deixis-setup-notes
#let ticks = state("adapter-body-points", 0)
#let ids = ()
#let painter(name, request) = [#metadata((name: name, document: request.route.document))<adapter-point-route>]
#let connect(id, point) = deixis-connect(from: id, to: (body: id, point: point),
  connector: (route: "curve", layer: if point == "start" { "foreground" } else { "background" },
    heads: (body: "circle"), render: painter.with(id + "-" + point)))
#for kind in ("margin", "inset", "footnote") {
  for layer in ("flow", "foreground", "background") {
    if ids.len() > 0 { pagebreak() }
    let id = kind + "-" + layer
    ids.push(id)
    let body = [
      #ticks.update(n => n + 1)One live body.
      #if kind == "footnote" and layer == "flow" { lorem(280) }
    ]
    connect(id, "start")
    connect(id, "end")
    if kind == "margin" { deixis-margin-note(id: id, layer: layer, width: 85pt, side: right, body) }
    else if kind == "inset" { deixis-inset-note(id: id, layer: layer, width: 95pt, dx: 70pt, dy: 50pt, body) }
    else { deixis-footnote(id: id, layer: layer, body) }
    [Visible native footer anchor; #link(label(id))[body link].]
  }
}
#pagebreak()
// An unframed inline body remains fully breakable and supplies explicit points.
#ids.push("inline")
#deixis-inline-note-body(of: <inline>, inline: true)[#ticks.update(n => n + 1)A future source.]
#connect("inline", "start")
#connect("inline", "end")
#pagebreak()
#deixis-mark(id: <inline>, mark-type: "phantom")Future original.
Native #link(<inline>)[body link].
#pagebreak()
// Scope footnotes are collected in native flow at the block's end.
#ids.push("block-footnote")
#deixis-block(id: <block>)[
  #deixis-footnote(id: <block-footnote>)[#ticks.update(n => n + 1)Block footer. #lorem(220)]
  Native block content.
]
#connect("block-footnote", "start")
#connect("block-footnote", "end")
Native #link(<block-footnote>)[block footer link].
#context {
  let spans = _deixis-body-spans()
  assert.eq(ticks.final(), 11)
  assert.eq(spans.len(), 11)
  assert(spans.at("id-footnote-flow").end.page() > spans.at("id-footnote-flow").start.page())
  assert.eq(deixis-system.final().registry.value.notes.len(), 11)
  [#metadata((spans: ids.map(id => {
    let span = spans.at("id-" + id)
    (id: id, start: span.start.position(), end: span.end.position(),
      destination: span.destination.position())
  }), destinations: ids.map(id => {
    let pos = query(label(id)).first().location().position()
    (page: pos.page, x: pos.x.pt(), y: pos.y.pt())
  })))<test-result>]
}
