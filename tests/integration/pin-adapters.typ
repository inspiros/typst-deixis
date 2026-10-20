#import "../../src/lib.typ": *
#import "../../src/core/query.typ": _deixis-pin-index, _deixis-select-pins
#import "../../src/routing/frames.typ": _deixis-body-nodes
#set page(width: 520pt, height: 360pt, margin: (x: 110pt, y: 35pt))
#show: deixis-setup-notes
#deixis-set(margin-layout: "exact")
#let ticks = state("pin-adapter-bodies", 0)
#let cases = ()
#for (i, layer) in ("foreground", "background", "flow").enumerate() {
  if i > 0 { pagebreak() }
  let scope = "component-" + layer
  let target = (name: <anchor>, scope: label(scope), select: "last")
  let margin-id = "margin-" + layer
  let inset-id = "inset-" + layer
  let page = 2 * i + 1
  cases.push((scope: scope, layer: layer, margin: margin-id, inset: inset-id, page: page))
  // Remote occurrences must be filtered before selecting last in native flow.
  deixis-margin-note-body(id: margin-id, layer: layer, anchor-pin: target,
    side: right, mark-align: "top", width: 80pt)[
    #ticks.update(n => n + 1)Margin.
  ]
  deixis-inset-note-body(id: inset-id, layer: layer, anchor-pin: target,
    anchor: top + left, width: 60pt)[#ticks.update(n => n + 1)Inset.]
  [Visible native content.]
  place(top + left, dx: 20pt, dy: 50pt, deixis-pin("anchor", scope: scope, padding: none))
  place(top + left, dx: 90pt, dy: 110pt, deixis-pin("anchor", scope: scope, padding: none))
  pagebreak()
  [Later matching pins.]
  place(top + left, dx: 140pt, dy: 160pt, deixis-pin("anchor", scope: scope, padding: none))
  // Another scope's same name must not change either the page or geometry.
  place(top + left, dx: 220pt, dy: 220pt, deixis-pin("anchor", scope: scope + "-other", padding: none))
}
#pagebreak()
// Region painting, implicit routing, and independent routing share selectors.
#let route(name, request) = [#metadata((name: name, bounds: request.route.document.nodes.mark.bounds))<pin-route>]
#deixis-mark(id: <region>, pins: ((name: "corner", scope: "routing", select: "all"),),
  layer: "background", padding: 0pt)
#deixis-inset-note-body(of: <region>, layer: "foreground", width: 60pt,
  dx: 150pt, dy: 40pt, connector: (route: "straight-line", render: route.with("implicit")))[Region body.]
#deixis-connect(from: <region>, to: <region>,
  connector: (route: "curve", render: route.with("explicit")))
#place(top + left, dx: 30pt, dy: 50pt, deixis-pin("corner", scope: "routing", padding: none))
#place(top + left, dx: 110pt, dy: 80pt, deixis-pin("corner", scope: "routing", padding: none))
#place(top + left, dx: 230pt, dy: 210pt, deixis-pin("corner", scope: "unrelated", padding: none))
Routing from scoped region bounds.
#pagebreak()
// Bounds share selection with geometry, including forward pin declarations.
#deixis-endnote(id: <before>)[Before interval.]
#deixis-pin("boundary", scope: "collection", padding: none)
#deixis-endnote(id: <selected>)[Selected interval.]
#deixis-print-endnotes(
  after: (name: "boundary", scope: "collection", select: "first"),
  before: (name: <boundary>, scope: <collection>, select: "last"))
#deixis-note-outline(include-types: ("endnote",),
  after: (name: <boundary>, scope: <collection>, select: "first"),
  before: (name: "boundary", scope: "collection", select: "last"),
  summary: note => [#metadata(note.id)<selected-outline>#note.summary])
#deixis-pin("boundary", scope: "collection", padding: none)
#deixis-endnote(id: <after>)[After interval.]
#context {
  let index = _deixis-pin-index()
  let nodes = _deixis-body-nodes()
  assert.eq(ticks.final(), 6)
  for case in cases {
    let page = if case.layer == "flow" { case.page } else { case.page + 1 }
    let target = _deixis-select-pins(index, (name: "anchor", scope: case.scope, select: "last"), page: page).first()
    let pos = target.location().position()
    let margin = nodes.at("id-" + case.margin).first()
    let inset = nodes.at("id-" + case.inset).first()
    assert.eq((margin.page, inset.page), (page, page))
    assert(calc.abs(margin.bounds.top - pos.y) < 0.1pt)
    assert(calc.abs(inset.bounds.top - pos.y) < 0.1pt)
    assert(calc.abs(inset.bounds.left - pos.x) < 0.1pt)
    let local = _deixis-select-pins(index, (name: "anchor", scope: case.scope, select: "first", page: case.page))
    assert.eq(local.first().location().page(), case.page)
  }
  assert.eq(query(<selected-outline>).map(p => p.value), (<selected>,))
  assert.eq(query(<deixis-rendered-start>).filter(p => p.value.body-type == "endnote").map(p => p.value.id), (<selected>,))
  let routes = query(<pin-route>)
  assert.eq(routes.map(r => r.value.name).sorted(), ("explicit", "implicit"))
  for r in routes {
    assert.eq(r.value.bounds.right - r.value.bounds.left, 80pt)
    assert.eq(r.value.bounds.bottom - r.value.bounds.top, 30pt)
  }
}
