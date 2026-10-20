#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#set text(size: 10pt)
#set page(width: 460pt, height: 340pt, margin: 40pt,
  header: context [#metadata((page: here().page(),
    all: deixis-query-notes(page: here().page()).map(n => n.id),
    source: deixis-query-notes(page: here().page(), order: "source").map(n => n.id),
    endnotes: deixis-query-notes(page: here().page(), include-types: "endnote").map(n => n.id),
    duplicates: deixis-query-notes(page: here().page(), include-types: ("endnote", "endnote")).map(n => n.id),
    empty: deixis-query-notes(page: here().page(), include-types: ()).map(n => n.id),
    unknown: deixis-query-notes(page: here().page(), include-types: "unknown").map(n => n.id),
  ))<query-page>],
)
#show: deixis-setup-notes
#let ticks = state("page-note-order-bodies", 0)
#let body(text) = [#ticks.update(n => n + 1)#text]
#deixis-update-note-counter(7, series: "z")
First#deixis-endnote(id: <high>, series: "z", body([High count.]))
#deixis-update-note-counter(0, series: "z")
Reset#deixis-endnote(id: <reset>, series: "z", body([After reset.]))
#deixis-endnote-body(id: <standalone>, series: "z", body([Standalone.]))
Other#deixis-endnote(id: <alpha>, series: "a", body([Another series.]))
Empty#deixis-endnote(id: <empty>, series: "", body([Empty series.]))
#deixis-block(id: <owner>)[#deixis-mark(id: <retargeted>, series: "z")[Scoped original]]
#deixis-endnote-body(of: <retargeted>, target: "page", body([Body retargeted to document.]))
#deixis-print-endnotes()
#link(<standalone>)[Standalone body link.]
// Unprinted bodies, extra occurrences, and references are not page-query entries.
#deixis-endnote(id: <unprinted>)[Must stay unprinted.]
#deixis-mark(of: <high>)[Another occurrence]
Reference @high.
#pagebreak()
#deixis-update-note-counter(20, series: "long")
Long#deixis-endnote(id: <long>, series: "long", body([Long start. #lorem(620) Long end.]))
#deixis-update-note-counter(0, series: "long")
Tail#deixis-endnote(id: <tail>, series: "long", body([Tail after reset.]))
#deixis-print-endnotes(series: "long", render-group: deixis-native-render-group)
#context {
  assert.eq(ticks.final(), 8)
  let sys = deixis-system.final()
  assert.eq((sys.registry.value.notes.at("id-retargeted").count-id, sys.registry.value.notes.at("id-retargeted").count), (repr(("block", "owner")), 1))
  let first = query(<query-page>).first().value
  assert.eq(first.all, (<high>, <reset>, <standalone>, <retargeted>, <alpha>, <empty>))
  assert.eq(first.source, (<high>, <reset>, <standalone>, <alpha>, <empty>, <retargeted>))
  assert.eq(deixis-query-notes(order: "body", include-unpaired: true).last().id, <unprinted>)
  assert.eq(deixis-query-notes().first().id, <high>)
  let start = query(<deixis-rendered-start>).find(n => n.value.id == <long>).location().page()
  let end = query(<deixis-rendered-end>).find(n => n.value.id == <long>).location().page()
  assert(end >= start + 2)
  for page in query(<query-page>).map(n => n.value) {
    assert.eq(page.endnotes, page.all)
    assert.eq(page.duplicates, page.all)
    assert.eq(page.empty, ())
    assert.eq(page.unknown, ())
    if page.page >= start and page.page <= end { assert.eq(page.all.first(), <long>) }
  }
  assert.eq(query(<query-page>).last().value.all, (<long>, <tail>))
  [#metadata((destinations: query(<deixis-body-destination>).map(body => {
    let pos = body.location().position()
    (page: pos.page, x: pos.x.pt(), y: pos.y.pt())
  })))<test-result>]
}
