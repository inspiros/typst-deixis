#import "../../src/lib.typ": *
#set page(width: 500pt, height: 260pt, margin: (x: 110pt, y: 30pt))
#show: deixis-setup-notes
#let ticks = state("pin-port-spillover", 0)
#let painter(name, request) = [#metadata((name: name, document: request.route.document,
  heads: (request.heads.mark != none, request.heads.body != none)))<pin-spill-route>]
#for i in range(5) {
  let name = "spill-" + str(i)
  let target(pin) = (name: pin, scope: name)
  let route = if sys.inputs.at("route", default: "curve") == "b-spline" {
    (kind: "b-spline", controls: ((pin: target("source"), offset: (15pt, 20pt)),))
  } else { sys.inputs.at("route", default: "curve") }
  deixis-margin-note(id: name, width: 85pt, connector: (
    route: route, heads: (mark: "circle", body: "triangle"), render: painter.with(name),
    ports: (mark: (pin: target("source"), side: bottom), body: (pin: target("socket"), side: left))),
    [#deixis-pin("source", scope: name)Source], [
      #ticks.update(n => n + 1)
      #deixis-attach(scope: name, prefix: none, pins: (socket: (anchor: left),))[
        #block(height: 85pt)[Body #i.]
      ]
    ])
}
#pagebreak()
Available continuation page.
#pagebreak()
Available final page.
#context {
  assert.eq(ticks.final(), 5)
  [#metadata(query(<deixis-pin>).map(p => (name: p.value.name, scope: p.value.scope,
    position: p.location().position())))<test-result>]
}
