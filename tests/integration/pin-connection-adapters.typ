#import "../../src/lib.typ": *
#import "../../src/routing/frames.typ": _deixis-body-nodes
#set page(width: 580pt, height: 410pt, margin: (x: 110pt, y: 40pt))
#show: deixis-setup-notes
#let enabled = sys.inputs.at("edges", default: "on") == "on"
#let ticks = state("pin-connection-bodies", 0)
#let painter(name, request) = [#metadata((name: name, document: request.route.document))<pin-adapter-route>]
#let ids = ()
#for layer in ("flow", "background", "foreground") {
  for kind in ("margin", "inset") {
    if ids.len() > 0 { pagebreak() }
    let id = kind + "-" + layer
    ids.push(id)
    let target(name) = (name: name, scope: id)
    let connector = if enabled { (route: "curve", heads: (body: "triangle"), render: painter.with(id),
      ports: (mark: (pin: target("source"), side: right, gap: 1pt),
        body: (pin: target("socket"), side: left, gap: 2pt)), via: ((pin: target("via")),)) } else { none }
    let body = [
      #ticks.update(n => n + 1)
      #deixis-attach(scope: id, prefix: none, pins: (socket: (anchor: horizon + left),))[
        Custom socket inside the body.
      ]
    ]
    let passage = [#deixis-pin("source", scope: id)Original]
    place(top + left, dx: 180pt, dy: 60pt, deixis-pin("via", scope: id))
    if kind == "margin" {
      deixis-margin-note(id: id, layer: layer, width: 85pt, connector: connector, passage, body)
    } else {
      deixis-inset-note(id: id, layer: layer, width: 85pt, dx: 100pt, dy: 90pt,
        connector: connector, passage, body)
    }
    // Explicit custom ports share the same resolver and retain full node bounds.
    if enabled {
      deixis-connect(from: (pin: target("via")), to: id, connector: (
        route: "orthogonal", render: painter.with("explicit-" + id),
        ports: (body: (pin: target("socket"), side: left, gap: -1pt))))
      deixis-connect(from: id, to: (pin: target("via")), connector: (
        render: painter.with("to-pin-" + id)))
    }
  }
}
#context {
  assert.eq(ticks.final(), 6)
  [#metadata((frames: _deixis-body-nodes(),
    pins: query(<deixis-pin>).map(p => (name: p.value.name, scope: p.value.scope,
      position: p.location().position())),
    spans: query(<deixis-rendered-start>).map(b => b.location().position())))<test-result>]
}
