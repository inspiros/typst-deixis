#import "../../src/lib.typ": *
#import "../../src/routing/frames.typ": _deixis-body-nodes, _deixis-body-spans
#set page(width: 550pt, height: 360pt, margin: 25pt)
#set text(size: 10pt)
#show: deixis-setup-notes
#let enabled = sys.inputs.at("edges", default: "on") == "on"
#let ticks = state("column-body-frames", 0)
#let ids = ()
#let cases = ()
#let painter(name, request) = [#metadata((name: name, document: request.route.document))<column-point-route>]
#for (i, direction) in (ltr, rtl).enumerate() {
  if i > 0 { pagebreak() }
  let id = "column-" + str(i)
  ids.push(id)
  set text(dir: direction)
  // An early edge and body-first attachment must retain their normal ownership.
  for point in ("start", "end") {
    let name = id + "-" + point
    let layer = if point == "start" { "foreground" } else { "background" }
    cases.push((name: name, target: id, point: point, layer: layer, gap: 0))
    if enabled {
      deixis-connect(from: id, to: (body: id, point: point), connector: (
        route: "curve", layer: layer, ports: (body: left), render: painter.with(name)))
    }
  }
  columns(2, gutter: 20pt)[
    #deixis-inset-note-body(of: id, layer: "flow", connector: none,
      container-func: deixis-plain-container)[
      #ticks.update(n => n + 1)
      #for j in range(12) { [Paragraph #j. #lorem(10)] + parbreak() }
    ]
  ]
  pagebreak()
  deixis-mark(id: id)[The original follows its body.]
  [Native #link(label(id))[body destination].]
}
#pagebreak()
// A short inset in columns is still a selectable complete frame.
#columns(2, gutter: 20pt)[
  #deixis-inset-note(id: <short>, layer: "flow", connector: none,
    container-func: deixis-plain-container)[Short][One unbroken body.]
]
#if enabled { deixis-connect(from: <short>, to: <short>) }
#pagebreak()
// Legitimate transformed inset frames still enclose their native boundaries.
#for (id, transform, y) in (("rotated", rotate.with(20deg), 70pt),
  ("scaled", scale.with(x: 120%, y: 80%), 200pt)) {
  deixis-mark(id: id, mark-type: "phantom")
  deixis-inset-note-body(of: id, width: 100pt, connector: none,
    placement: it => place(top + left, dx: 150pt, dy: y, transform(it)))[A transformed body.]
  if enabled { deixis-connect(from: id, to: id) }
}
#context {
  assert.eq(ticks.final(), 2)
  let spans = _deixis-body-spans()
  [#metadata((frames: _deixis-body-nodes(), cases: cases,
    spans: ids.map(id => {
      let span = spans.at("id-" + id)
      (id: id, start: span.start.position(), end: span.end.position(),
        destination: span.destination.position())
    }), destinations: ids.map(id => {
      let pos = query(label(id)).first().location().position()
      (page: pos.page, x: pos.x.pt(), y: pos.y.pt())
    })))<test-result>]
}
