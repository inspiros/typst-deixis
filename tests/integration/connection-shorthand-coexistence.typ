#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#import "../../src/core/references.typ": _deixis-reference-sites
#import "../../src/routing/connector-scene.typ": _deixis-scene-entity
#set page(width: 420pt, height: 290pt, margin: 25pt)
#show: deixis-setup-notes
#let policy = sys.inputs.at("policy", default: "separate")
#let layer = sys.inputs.at("layer", default: "foreground")
#show: deixis-routing.with(policy: policy, nodes: ((body: <shared>),))
#let live = state("coexisting-shorthand", 0)
#let paint(name, r) = [#metadata((name: name, route: r.route))<shorthand-route>]
#let options(name) = (route: "orthogonal", radius: 0pt, layer: layer, render: paint.with(name))
// Explicit connections remain additive, including a deliberately duplicate
// original-to-body edge. A reused mark never inherits the body's shorthand.
#deixis-connect(from: <shared>, to: <shared>, connector: options("explicit-original"))
#deixis-connect(from: (mark: "shared", occurrence: "again"), to: (body: <shared>),
  connector: options("explicit-repeat"))
#deixis-mark(of: <shared>, occurrence: <again>)[Earlier Reuse]
#v(35pt)
#deixis-mark(id: "shared")[Original]
#deixis-inset-note-body(of: <shared>, width: 75pt, connector: options("shorthand"),
  placement: x => place(top + left, dx: 250pt, dy: 90pt, x))[
  #live.update(n => n + 1)One Body
]
#let verify() = {
  assert.eq(live.final(), 1)
  let sys = deixis-system.final()
  assert.eq(sys.registry.value.notes.len(), 1)
  let uid = sys.registry.value.id-index.at("shared")
  assert.eq(_deixis-reference-sites().at(uid).len(), 1)
  let records = query(<shorthand-route>).map(m => m.value)
  assert.eq(records.len(), 3)
  let edge(name) = records.find(r => r.name == name).route.document.fragment.logical
  let owner(name) = _deixis-scene-entity("mark", edge(name).source.identity)
  assert.eq(owner("shorthand"), owner("explicit-original"))
  assert.eq(edge("shorthand").source.bounds, edge("explicit-original").source.bounds)
  assert.ne(edge("explicit-repeat").source.identity, edge("shorthand").source.identity)
  assert(records.all(r => r.route.document.fragment.logical.target.identity == uid))
}
