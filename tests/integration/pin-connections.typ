#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#set page(width: 500pt, height: 300pt, margin: 30pt)
#show: deixis-setup-notes
#let enabled = sys.inputs.at("edges", default: "on") == "on"
#let painter(name, request) = {
  [#metadata((name: name, document: request.route.document, segments: request.route.segments,
    start: request.route.start, end: request.route.end, shaft: request.shaft,
    origin: request.route.origin, heads: (request.heads.mark != none, request.heads.body != none)))<pin-route>]
  for s in request.shaft {
    place(top + left, curve(stroke: request.stroke, curve.move(s.start),
      if s.kind == "line" { curve.line(s.end) } else { curve.cubic(s.c1, s.c2, s.end) }))
  }
  deixis-render-head(request.heads.mark, request.route.start, request.route.start-tangent.map(v => -v))
  deixis-render-head(request.heads.body, request.route.end, request.route.end-tangent)
}
#let n = 0
#for route in ("straight-line", "right-angle", "chamfer", "curve", "ccr", "ucr") {
  for directed in (false, true) {
    if n > 0 { pagebreak() }
    n += 1
    context {
      let local = here()
      let target(name, select: "unique") = (name: label(name), scope: local, select: select)
      let name = route + "-" + repr(directed)
      if enabled {
        // Forward pin endpoints work without any annotation or body registry.
        deixis-connect(from: (pin: target("a", select: "first")), to: (pin: target("b", select: "last")),
          connector: (route: route, render: painter.with(name), layer: if directed { "background" } else { "foreground" },
            ports: if directed { (mark: (side: right, gap: 2pt), body: (side: left, gap: 3pt)) } else { auto },
            heads: (mark: "circle", body: "triangle"), via: (
              (pin: target("via"), offset: (5pt, -3pt)),
              (relative-to: "previous", offset: (20pt, 10pt)),)))
      }
      place(top + left, dx: 50pt, dy: 100pt, deixis-pin("a", scope: local, padding: 40pt))
      place(top + left, dx: 55pt, dy: 105pt, deixis-pin(<a>, scope: local))
      place(top + left, dx: 200pt, dy: 60pt, deixis-pin(<via>, scope: local))
      place(top + left, dx: 300pt, dy: 110pt, deixis-pin(<b>, scope: local))
      place(top + left, dx: 330pt, dy: 120pt, deixis-pin("b", scope: local, padding: (left: -20pt)))
      [#metadata((name: name, directed: directed, page: local.page()))<pin-case>]
    }
  }
}
// Disabled declarations validate shape but require no pins or note identities.
#deixis-connect(from: (pin: "absent"), to: (pin: <absent>), connector: none)
#context {
  assert.eq(deixis-system.final().registry.value.notes.len(), 0)
  assert.eq(query(<deixis-reference>).len(), 0)
  [#metadata(query(<deixis-pin>).map(p => (name: p.value.name, position: p.location().position())))<test-result>]
}
