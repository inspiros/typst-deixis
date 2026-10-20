#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#import "../../src/core/references.typ": _deixis-reference-sites
#import "../../src/routing/occurrences.typ": _deixis-occurrence-nodes
#set page(width: 550pt, height: 420pt, margin: (x: 100pt, y: 40pt))
#show: deixis-setup-notes
#let ticks = state("repeat-kinds-bodies", 0)
#let painter(name, request) = [#metadata((name: name, document: request.route.document))<repeat-kind-route>]

// Both geometry and phantom reuse may precede the original through its alias.
#deixis-region-mark(of: <idea>, occurrence: <formula>, inline: true)[$x^2 + y^2$]
#deixis-phantom-mark(of: <idea>, occurrence: <point>)An invisible point.

#deixis-inline-mark(id: <idea>)[Original owner].
#deixis-margin-note-body(of: <idea>, side: right, width: 85pt, backlink: true,
  connector: (route: "curve", render: painter.with("implicit")))[#ticks.update(n => n + 1)One explanation.]

#deixis-mark(of: <idea>, mark-type: "region", inline: true, occurrence: <code>)[`x * x`]
#deixis-mark(of: <idea>, mark-type: "phantom", occurrence: <point-two>)Another point.
#deixis-inline-mark(of: <idea>)[Inline reuse].
#deixis-pin("reuse-pins", padding: 0pt)Pin region.#deixis-pin("reuse-pins", padding: 0pt)
// Supplied pins select region mode, like the note wrappers.
#deixis-mark(of: <idea>, pins: ("reuse-pins",), occurrence: <pins>)
#deixis-connect(from: (mark: <idea>, occurrence: <formula>), to: <idea>,
  connector: (render: painter.with("region")))
#deixis-connect(from: (mark: <idea>, occurrence: <point>), to: <idea>,
  connector: (render: painter.with("phantom")))

// Bare repeats remain inline, independently of the original's mark type.
#deixis-region-mark(id: <region>, inline: true)[$f(x)$]
#deixis-endnote-body(of: <region>)[#ticks.update(n => n + 1)Region original.]
Bare#deixis-mark(of: <region>).
#deixis-phantom-mark(id: <phantom>)Phantom original.
#deixis-endnote-body(of: <phantom>)[#ticks.update(n => n + 1)Phantom original.]
Bare#deixis-mark(of: <phantom>).
#deixis-print-endnotes()
#context {
  let sys = deixis-system.final()
  let uid = sys.registry.value.id-index.at("idea")
  assert.eq(sys.registry.value.notes.len(), 3)
  assert.eq(sys.registry.value.notes.values().map(n => n.count), (1, 2, 3))
  assert.eq(ticks.final(), 3)
  assert.eq(query(<deixis-region-mark>).len(), 1)
  assert.eq(query(<deixis-region-occurrence>).len(), 3)
  assert.eq(_deixis-reference-sites().at(uid).len(), 6)
  let point = _deixis-occurrence-nodes().at(uid).at("point")
  let site = query(<deixis-mark-occurrence>).find(s => s.value.name == "point").location()
  assert.eq(point.page, site.page())
  assert.eq(point.bounds.left, site.position().x)
  assert.eq(point.bounds.right, site.position().x)
  assert.eq(point.bounds.top, point.bounds.bottom)
}
