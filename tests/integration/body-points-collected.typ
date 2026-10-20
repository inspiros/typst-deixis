#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#import "../../src/core/references.typ": _deixis-reference-sites
#import "../../src/routing/frames.typ": _deixis-body-spans
#set page(width: 450pt, height: 290pt, margin: 35pt)
#set text(size: 10pt)
#show: deixis-setup-notes
#let enabled = sys.inputs.at("edges", default: "on") == "on"
#let ticks = state("collected-body-points", 0)
#let cases = ()
#let edge-cases = ()
#let painter(name, request) = {
  let doc = request.route.document
  // Page-local incoming projection can coincide with a start/end point right
  // on the content boundary. Empty geometry has no tangent or endpoint head.
  let drawable = request.route.segments.len() > 0
  if not drawable {
    assert.eq(request.route.length, 0pt)
    assert.eq(doc.endpoints.mark.point, doc.endpoints.body.point)
  }
  assert.eq(request.heads.mark != none, drawable and not doc.is-incoming)
  assert.eq(request.heads.body != none, drawable and not doc.is-outgoing)
  [#metadata((name: name, document: doc))<collected-point-route>]
}
#let connect(from, to, name, layer: "foreground", gap: 0pt) = if enabled {
  deixis-connect(from: from, to: to, connector: (
    route: "curve", layer: layer, render: painter.with(name),
    heads: (mark: "circle", body: "triangle"),
    ports: (body: (side: left, gap: gap))))
}
#let column-group(notes, ..args) = columns(2, gutter: 16pt,
  deixis-native-render-group(notes, ..args.named()))
#for (name, renderer) in (("native", deixis-native-render-group),
  ("aligned", deixis-aligned-render-group), ("grid", deixis-grid-render-group),
  ("columns", column-group)) {
  if cases.len() > 0 { pagebreak() }
  let long-id = name + "-long"
  let short-id = name + "-standalone"
  cases += (long-id, short-id)
  let start-edge = name + "-start"
  let end-edge = name + "-end"
  let short-edge = name + "-standalone"
  edge-cases += ((name: start-edge, target: long-id, point: "start", layer: "foreground", gap: 0),
    (name: end-edge, target: long-id, point: "end", layer: "background", gap: 0),
    (name: short-edge, target: short-id, point: "end", layer: "foreground", gap: 2))
  // Connections and named reuse precede the original and the printer.
  connect(long-id, (body: label(long-id), point: "start"), start-edge)
  connect((mark: label(long-id), occurrence: <again>), (body: long-id, point: "end"),
    end-edge, layer: "background")
  connect(label(long-id), (body: short-id, point: "end"), short-edge, gap: 2pt)
  deixis-block(inset: 3pt)[#deixis-mark(of: long-id, occurrence: <again>)[Earlier use.]]
  [Collected#deixis-endnote(id: long-id, series: name, backlink: true)[
    #ticks.update(n => n + 1)
    #for i in range(14) { [Paragraph #i. #lorem(20)] + parbreak() }
  ]]
  deixis-endnote-body(id: label(short-id), series: name)[#ticks.update(n => n + 1)Standalone body.]
  [Reference #deixis-ref(label(long-id)).]
  pagebreak()
  deixis-print-endnotes(series: name, render-group: renderer)
  deixis-print-endnotes(series: name, render-group: renderer)
  [Native #link(label(long-id))[long link] and #link(label(short-id))[standalone link].]
}
// Disabled edges do not require printing or resolving their targets.
#deixis-connect(from: <missing>, to: (body: <missing>, point: "start"), connector: none)
#context {
  let spans = _deixis-body-spans()
  assert.eq(ticks.final(), 8)
  assert.eq(spans.len(), 8)
  assert.eq(query(<deixis-body-destination>).len(), 8)
  for name in ("native", "aligned", "grid", "columns") {
    let uid = "id-" + name + "-long"
    assert(spans.at(uid).end.page() > spans.at(uid).start.page())
    assert.eq(_deixis-reference-sites().at(uid).len(), 2)
    assert.eq(deixis-system.final().registry.value.counters.at("page").at(name), 1)
  }
  [#metadata((cases: edge-cases, spans: cases.map(id => {
    let span = spans.at("id-" + id)
    (id: id, start: span.start.position(), end: span.end.position(),
      destination: span.destination.position())
  }), destinations: cases.map(id => {
    let pos = query(label(id)).first().location().position()
    (page: pos.page, x: pos.x.pt(), y: pos.y.pt())
  })))<test-result>]
}
