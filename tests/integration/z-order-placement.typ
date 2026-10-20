#import "../../src/lib.typ": *
#let enabled = sys.inputs.at("priority", default: "on") == "on"
#let z(n) = if enabled { n } else { 0 }
#set page(width: 500pt, height: 260pt, margin: (x: 110pt, y: 30pt))
#show: deixis-setup-notes
#let live = state("z-placement-live", 0)
#let painter(name, request) = [#metadata((name: name, document: request.route.document,
  heads: (request.heads.mark != none, request.heads.body != none)))<z-placement-route>]
#for i in range(5) {
  let name = "spill-" + str(i)
  let target(pin) = (name: pin, scope: name)
  deixis-margin-note(id: name, width: 85pt, z-index: (body: z(5 - i), connector: z(i - 4)),
    connector: (route: "curve", heads: (mark: "circle", body: "triangle"), render: painter.with(name),
      ports: (mark: (pin: target("source"), side: bottom), body: (pin: target("socket"), side: left))),
    [#deixis-pin("source", scope: name)Source], [
      #live.update(n => n + 1)
      #deixis-attach(scope: name, prefix: none, pins: (socket: (anchor: left),))[
        #block(height: 85pt)[Body #i.]
      ]
    ])
}
// Flow output retains its native position even with a large integer priority.
#deixis-inset-note-body(id: "flow-control", layer: "flow", z-index: z(50), width: 60pt)[
  #live.update(n => n + 1)Native flow.
]
#pagebreak()
Available continuation page.
#pagebreak()
Available final page.
#context {
  assert.eq(live.final(), 6)
  assert.eq(query(<deixis-rendered-start>).len(), 6)
}
