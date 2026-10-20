#import "../../src/lib.typ": *
#import "../../src/lib.typ" as api
#import "../../src/core/state.typ": deixis-system
#import "../../src/core/references.typ": _deixis-reference-sites
#set page(width: 560pt, height: 420pt, margin: (x: 105pt, y: 40pt))
#show: deixis-setup-notes
#let bodies = state("compact-api-bodies", 0)
#let paint(request) = [#metadata(request.route.document)<compact-route>]
// The convenience name covers creation and reuse, with all identity arguments named.
#deixis-mark(of: <idea>)[Forward occurrence]
#deixis-mark(id: <idea>, stroke: (mark: blue, body: red))[First passage]
#deixis-inset-note(of: <idea>, layer: "foreground", width: 115pt, dx: 150pt, dy: 65pt,
  backlink: true, connector: (route: "curve", render: paint))[
  #bodies.update(n => n + 1)One body for both passages.
]
#deixis-mark(of: <idea>, occurrence: <again>, inline-mode: "underline")[Another passage]

#deixis-mark(id: <region>, mark-type: "region", inline: true, layer: "background")[$x^2$]
#deixis-margin-note-body(of: <region>, side: right, width: 90pt)[#bodies.update(n => n + 1)Region body.]
#deixis-mark(id: <quiet>, mark-type: "phantom", marker: sym.ast)
#deixis-endnote(of: <quiet>)[#bodies.update(n => n + 1)Phantom body.]

#deixis-pin("point", padding: 0pt)
#deixis-mark(id: <pinned>, pins: ("point",), marker: none, layer: "background")
#deixis-mark(of: <pinned>, pins: ("point",), marker: none, layer: "background")

// Anonymous marks decorate without creating another counter owner.
#deixis-mark(inline-mode: "underline")[Anonymous inline]
#deixis-mark(mark-type: "region", inline: true, layer: "background")[Anonymous region]
#deixis-mark(mark-type: "phantom")

#deixis-endnote(id: <wrapped>)[#bodies.update(n => n + 1)A named wrapper.]
#deixis-inline-note-body(id: "standalone", inline: true)[#bodies.update(n => n + 1)Standalone body.]

Native: #link(<idea>)[attached], #link(<region>)[region], #link(<quiet>)[phantom], #link(<wrapped>)[wrapped], #link(<standalone>)[standalone].
References: @idea, @wrapped, @standalone.
#deixis-print-endnotes()
#context {
  let registry = deixis-system.final()
  assert.eq(registry.registry.value.notes.len(), 6)
  assert.eq(registry.registry.value.counters.at("page").at("default"), 4)
  assert.eq(registry.registry.value.counters.at("page").at("endnote"), 1)
  assert.eq(bodies.final(), 5)
  assert.eq(query(<deixis-rendered-start>).len(), 5)
  assert.eq(query(<deixis-mark-occurrence>).len(), 3)
  assert.eq(query(<compact-route>).len(), 1) // Reuse never acquires an implicit edge.
  assert.eq(registry.registry.value.notes.at(registry.registry.value.id-index.at("standalone")).count, none)
  assert.eq(registry.registry.value.pending-bodies.len(), 0)
  assert("label-index" not in registry)
  assert("deixis-mark" in dictionary(api))
  assert("deixis-repeat-mark" not in dictionary(api))
  let destinations = ()
  for id in (<idea>, <region>, <quiet>, <wrapped>, <standalone>) {
    let published = query(id)
    assert.eq(published.len(), 1)
    assert.eq(str(published.first().value.id), str(id))
    assert("label" not in published.first().value)
    let pos = published.first().location().position()
    destinations.push((page: pos.page, x: pos.x.pt(), y: pos.y.pt()))
  }
  let sites = _deixis-reference-sites()
  assert.eq(sites.at(registry.registry.value.id-index.at("idea")).len(), 3)
  [#metadata((destinations: destinations))<test-result>]
}
