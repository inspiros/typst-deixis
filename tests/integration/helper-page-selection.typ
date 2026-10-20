#import "../../src/lib.typ": *
#set page(width: 440pt, height: 280pt, margin: 32pt, numbering: "1",
  header: context {
    let p = here().page()
    [#metadata((page: p,
      rendered: deixis-query-notes(page: here().page()).map(n => n.id),
      source: deixis-query-notes(page: p, order: "source", include-unpaired: true).map(n => n.id),
      reading: deixis-query-notes(page: here().page(), series: "reading").map(n => n.id),
      repeated: deixis-query-notes(page: here().page(), series: ("reading", "reading")).map(n => n.id),
      empty: deixis-query-notes(page: here().page(), series: ()).map(n => n.id),
      unknown: deixis-query-notes(page: here().page(), series: "missing").map(n => n.id),
    ))<helper-page>]
  })
#set text(size: 10pt)
#show: deixis-setup-notes
#let bodies = state("helper-page-live-bodies", ())
#let body(id, content) = [#bodies.update(xs => xs + (id,))#content]
#deixis-mark(of: <shared>, occurrence: <forward>)[Earlier reuse]
#deixis-endnote-body(id: <aside>, series: "reading", body("aside", [Standalone explanation.]))
#deixis-endnote(id: <shared>, series: "reading")[Original][#body("shared", [#lorem(360)])]
#deixis-endnote(id: <waiting>, series: "waiting")[Not yet printed.]
Footnote#deixis-footnote(id: <foot>, layer: "flow", body("foot", [Live footnote.]))
#pagebreak()
// Printed page labels deliberately repeat; selection still uses physical pages.
#counter(page).update(1)
#deixis-mark(of: <shared>, occurrence: <later>)[Another reuse]
#deixis-print-endnotes(series: "reading", render-group: deixis-native-render-group)
#pagebreak()
#let partial(data, ..args) = [#deixis-generate-body-meta(data)#data.body]
#deixis-inline-note-body(id: <partial>, render-single: partial)[No live span.]
#deixis-inline-note-body(id: <inline>, body("inline", [A live inline body.]))
#context {
  let pages = query(<helper-page>).map(m => m.value)
  assert(pages.len() >= 4)
  assert.eq(pages.first().rendered, (<foot>,))
  assert.eq(pages.first().source, (<foot>,))
  for p in pages {
    assert.eq(p.rendered.sorted(key: str), p.source.sorted(key: str))
    assert.eq(p.reading, p.repeated)
    assert.eq(p.reading, deixis-query-notes(page: p.page).filter(n => n.series == "reading").map(n => n.id))
    assert.eq(p.empty, ())
    assert.eq(p.unknown, ())
    assert.eq(deixis-query-notes(page: p.page).map(n => n.id), p.rendered)
    assert.eq(deixis-query-notes(page: p.page, order: "source", include-unpaired: true).map(n => n.id), p.source)
  }
  assert.eq(deixis-query-notes(page: 999), ())
  assert.eq(deixis-query-notes(page: 999, include-unpaired: true), ())
  let notes = deixis-query-notes(include-unpaired: true)
  let shared = notes.find(n => n.id == <shared>)
  assert.eq(shared.marks.len(), 3)
  assert.eq(shared.body.start.page(), 2)
  assert.eq(counter(page).at(shared.body.start).first(), 1)
  assert(<aside> not in deixis-query-notes(page: 2, include-unpaired: false).map(n => n.id))
  assert.eq(shared.marks.map(m => m.dest.page()).dedup(), (1, 2))
  assert(shared.body.end.page() > shared.body.start.page())
  for p in range(shared.body.start.page(), shared.body.end.page() + 1) {
    let selected = deixis-query-notes(page: p, series: "reading", include-unpaired: true)
    assert(<shared> in selected.map(n => n.id))
    assert(selected.all(n => n.type == "endnote"))
    assert.eq(selected.find(n => n.id == <shared>).marks, shared.marks)
  }
  assert.eq(notes.find(n => n.id == <waiting>).body.start, none)
  assert.eq(notes.find(n => n.id == <partial>).body.start, none)
  assert.eq(bodies.final().sorted(), ("aside", "foot", "inline", "shared"))
  // Safe records contain descriptions; querying a page never returns live body content.
  assert(notes.all(n => n.body == none or not ("body" in n.body)))
  [#metadata((pages: pages.len(), bodies: bodies.final().len()))<test-result>]
}
