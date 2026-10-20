#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#import "../../src/core/references.typ": _deixis-reference-sites
#set page(width: 560pt, height: 420pt, margin: (x: 100pt, y: 40pt))
#show: deixis-setup-notes
#let ticks = state("reuse-api-body", 0)
#let painter(name, request) = [#metadata((name: name, source: request.route.document.source-page))<reuse-route>]
// Explicit reuse may precede the counter owner, even through a later body label.
#deixis-inline-mark(of: <shared>, occurrence: <early>, inline-mode: "underline")[Earlier reuse]
#v(25pt)
#deixis-inline-mark(id: <shared>)[Original owner]
#deixis-inset-note(of: <shared>, layer: "foreground", width: 110pt,
  dx: 140pt, dy: 50pt, backlink: true,
  connector: (route: "curve", render: painter.with("implicit")))[#ticks.update(n => n + 1)Single body.]
#v(35pt)
#deixis-mark(of: <shared>, occurrence: <named>)[Named reuse]
#deixis-mark(of: <shared>)[Positional compatibility]
#deixis-inline-mark(of: <shared>, marker: "X")[Local marker]
#deixis-inline-mark(of: <shared>, marker: none)
#deixis-connect(from: (mark: <shared>, occurrence: <early>), to: <shared>,
  connector: (route: "curve", render: painter.with("explicit")))
#context {
  let sys = deixis-system.final()
  assert.eq(sys.registry.value.notes.len(), 1)
  let uid = sys.registry.value.id-index.at("shared")
  assert.eq(query(<shared>).len(), 1)
  assert.eq(sys.registry.value.notes.at(uid).count, 1)
  assert.eq(ticks.final(), 1)
  assert.eq(query(<deixis-rendered-start>).len(), 1)
  assert.eq(query(<deixis-inline-mark>).len(), 1)
  assert.eq(query(<deixis-mark-occurrence>).len(), 5)
  assert.eq(_deixis-reference-sites().at(uid).len(), 5)
}
