#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#import "../../src/core/references.typ": _deixis-reference-sites
#set page(width: 560pt, height: 400pt, margin: (x: 110pt, y: 40pt))
#show: deixis-setup-notes
#let ticks = state("identity-order-page-bodies", 0)
#let cases = ()
#let body = [#ticks.update(n => n + 1)One live explanation.]
#let pairs = ("footnote", "endnote", "margin", "inset", "sidenote")
// Reuse and references can precede a wrapper that creates both components.
#for kind in pairs {
  for mark-type in ("inline", "region", "phantom") {
    if cases.len() > 0 { pagebreak() }
    let id = "wrapper-" + kind + "-" + mark-type
    let start = 2 * cases.len() + 1
    cases.push((id: id, original-page: start + 1, body-page: start + 1))
    [Earlier #deixis-mark(of: id, occurrence: <before>)[reused passage].]
    [Native #link(label(id))[forward body link]; package #deixis-ref(label(id)).]
    pagebreak()
    let content = if mark-type == "phantom" { (body,) } else { ([Original passage], body) }
    if kind == "footnote" { deixis-footnote(id: id, mark-type: mark-type, series: "pages", inline: true, ..content) }
    else if kind == "endnote" { deixis-endnote(id: id, mark-type: mark-type, series: "pages", inline: true, ..content) }
    else if kind == "margin" { deixis-margin-note(id: id, mark-type: mark-type, series: "pages", side: right, width: 90pt, inline: true, ..content) }
    else if kind == "inset" { deixis-inset-note(id: id, mark-type: mark-type, series: "pages", width: 130pt, inline: true, ..content) }
    else { deixis-sidenote(id: id, mark-type: mark-type, series: "pages", side: right, width: 90pt, inline: true, ..content) }
    [Visible footer anchor.]
    deixis-print-endnotes(series: "pages")
    [Later #deixis-mark(of: label(id), occurrence: <after>)[reused passage].]
  }
}
// A body attached to a future mark retains its adapter's placement policy.
#for layer in ("foreground", "background", "flow") {
  pagebreak()
  let start = 2 * pairs.len() * 3 + 2 * ("foreground", "background", "flow").position(l => l == layer) + 1
  let id = "margin-before-" + layer
  cases.push((id: id, original-page: start + 1,
    body-page: if layer == "flow" { start } else { start + 1 }))
  deixis-margin-note-body(of: label(id), layer: layer, width: 90pt, side: right, body)
  [Body declared before its original.]
  pagebreak()
  deixis-mark(id: id, series: "pages")[Future original]
  [Native #link(label(id))[body link].]
}
#context {
  let registry = deixis-system.final()
  let sites = _deixis-reference-sites()
  assert.eq(cases.len(), 18)
  assert.eq(registry.registry.value.notes.len(), 18)
  assert.eq(registry.registry.value.pending-bodies.len(), 0)
  assert.eq(registry.registry.value.counters.at("page").at("pages"), 18)
  assert.eq(ticks.final(), 18)
  assert.eq(query(<deixis-rendered-start>).len(), 18)
  let destinations = ()
  for (i, case) in cases.enumerate() {
    let uid = registry.registry.value.id-index.at(case.id)
    assert.eq(registry.registry.value.notes.at(uid).count, i + 1)
    let original = query(label("deixis-mark-" + uid)).first().location()
    let painted = query(label(case.id))
    assert.eq(original.page(), case.original-page)
    assert.eq(painted.len(), 1)
    assert.eq(painted.first().location().page(), case.body-page)
    if i < 15 { assert.eq(sites.at(uid).len(), 3) }
    let pos = painted.first().location().position()
    destinations.push((page: pos.page, x: pos.x.pt(), y: pos.y.pt()))
  }
  [#metadata((destinations: destinations))<test-result>]
}
