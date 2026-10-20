#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#import "../../src/routing/attached.typ": _deixis-attached-nodes
#set page(width: 420pt, height: 290pt, margin: 25pt)
#show: deixis-setup-notes
#let policy = sys.inputs.at("policy", default: "separate")
#let layer = sys.inputs.at("layer", default: "foreground")
#let wrapped = sys.inputs.at("wrapped", default: "node")
#let live = state("coexisting-bodies", 0)
#let paint(name, r) = {
  [#metadata((name: name, route: r.route))<coexisting-route>]
  deixis-render-connector(r)
}
#let options(name) = (layer: layer, render: paint.with(name))
#show: deixis-routing.with(policy: policy)
// All three forward selectors use the same public spelling, with distinct
// geometry and independent namespaces. Bare strings/labels still select notes.
#deixis-connect(from: "shared", to: <shared>, connector: options("note"))
#deixis-connect(from: (node: <shared>), to: (node: <target>), connector: options("node"))
#deixis-connect(from: (pin: <shared>), to: (pin: <end>), connector: options("pin"))
#place(top + left, dx: 10pt, dy: 15pt)[#deixis-mark(id: <shared>)[Original]]
#deixis-inset-note-body(of: "shared", width: 70pt, connector: none,
  placement: x => place(top + left, dx: 270pt, dy: 15pt, x))[
  #live.update(n => n + 1)Explanation
]
#place(top + left, dx: 10pt, dy: 90pt)[#deixis-attach(id: "shared")[#rect(width: 45pt, height: 30pt)[Card]]]
#place(top + left, dx: 270pt, dy: 90pt)[#deixis-attach(id: "target")[#rect(width: 45pt, height: 30pt)[Target]]]
#place(top + left, dx: 10pt, dy: 180pt, deixis-pin("shared", padding: 0pt))
#place(top + left, dx: 310pt, dy: 180pt, deixis-pin("end", padding: 0pt))
See @shared.
#pagebreak()
// A scope namespaces attachment IDs independently of annotation identities;
// repeated attachment IDs on another physical page remain locally selectable.
#deixis-connect(from: (node: "shared"), to: (node: <shared>, scope: "local"),
  connector: options("scoped"))
#place(top + left, dx: 10pt, dy: 20pt)[#deixis-attach(id: <shared>)[#rect(width: 45pt, height: 30pt)[Page Two]]]
#place(top + left, dx: 270pt, dy: 20pt)[#deixis-attach(id: "shared", scope: <local>)[#rect(width: 45pt, height: 30pt)[Scoped]]]
// Wrapping a live framed body does not merge its identity with the wrapper.
// A body endpoint uses an ignored wrapper; a node endpoint owns its avoid frame.
#deixis-connect(from: (pin: <start>),
  to: if wrapped == "node" { (node: <wrapped>) } else { (body: "wrapped") },
  connector: options("wrapped"))
#place(top + left, dx: 10pt, dy: 140pt, deixis-pin(<start>, padding: 0pt))
#place(top + left, dx: 250pt, dy: 120pt)[
  #deixis-attach(id: "wrapped", behavior: if wrapped == "node" { "avoid" } else { "ignore" })[
    #deixis-inline-note-body(id: <wrapped>, breakable: false)[#live.update(n => n + 1)Wrapped Body]
  ]
]
See @shared and @wrapped.
#pagebreak()
// An overlay declaration has no native body footprint. Its ignored attachment
// names that empty declaration frame, not the separately painted note body.
// Ignored zero-area frames are valid in searched scenes too, but they supply
// neither an avoidance rectangle nor the later painted body's geometry.
#deixis-routing(policy: policy)[
  #deixis-connect(from: (pin: <overlay-start>), to: "overlay", connector: options("overlay"))
  #place(top + left, dx: 10pt, dy: 20pt)[
    #deixis-attach(id: <overlay>, behavior: "ignore", inline: true)[
      #deixis-inset-note-body(id: "overlay", layer: "background", width: 70pt, connector: none,
        placement: x => place(top + left, dx: 250pt, dy: 120pt, x))[
        #live.update(n => n + 1)Overlay Body
      ]
    ]
  ]
  #place(top + left, dx: 10pt, dy: 130pt, deixis-pin("overlay-start", padding: 0pt))
  See @overlay.
]
#let verify() = {
  assert.eq(live.final(), 3)
  let sys = deixis-system.final()
  assert.eq(sys.registry.value.notes.len(), 3)
  assert.eq(sys.registry.value.id-index.keys().sorted(), ("overlay", "shared", "wrapped"))
  let records = query(<coexisting-route>).map(m => m.value)
  assert.eq(records.len(), 6)
  let edge(name) = records.find(r => r.name == name).route.document.fragment.logical
  let attached = _deixis-attached-nodes()
  assert.eq(attached.len(), 6)
  let card = attached.find(n => n.id == "shared" and n.page == 1)
  assert.eq(edge("node").source.identity, card.identity)
  assert.eq(edge("node").source.bounds, card.bounds)
  assert.ne(edge("note").source.identity, card.identity)
  assert(edge("note").source.bounds.bottom < card.bounds.top)
  assert.eq(edge("pin").source.identity.pin, "shared")
  assert.eq(edge("pin").source.bounds.left, 35pt)
  assert.eq(edge("pin").source.bounds.top, 205pt)
  assert.eq(edge("scoped").source.page, 2)
  assert.eq(edge("scoped").target.identity,
    attached.find(n => n.id == "shared" and n.scope == "local").identity)
  let wrapper = attached.find(n => n.id == "wrapped")
  if wrapped == "node" { assert.eq(edge("wrapped").target.identity, wrapper.identity) }
  else { assert.ne(edge("wrapped").target.identity, wrapper.identity) }
  let declaration = attached.find(n => n.id == "overlay")
  assert.eq(declaration.bounds.top, declaration.bounds.bottom)
  assert(edge("overlay").target.bounds.top > declaration.bounds.bottom)
  assert.ne(edge("overlay").target.identity, declaration.identity)
  let destination = query(<deixis-body-destination>).map(m => m.location().position())
  (destinations: destination.map(p => (page: p.page, x: p.x.pt(), y: p.y.pt())))
}
