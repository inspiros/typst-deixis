#import "../../src/lib.typ": *
#set page(width: 440pt, height: 300pt, margin: 35pt,
  header: context [#metadata((page: here().page(),
    all: deixis-query-notes(page: here().page()).map(n => n.id),
  ))<span-page>])
#show: deixis-setup-notes

// Partial/ambiguous custom spans stay inspectable as semantic declarations, but
// never acquire guessed page coverage. Use the normal content helper in real code.
#let partial(mode, data, ..args) = {
  if data.at("disable-links", default: false) { return data.body }
  deixis-generate-body-meta(data)
  if mode == "end-before-start" { [#metadata(data)<deixis-rendered-end>] }
  [#metadata(data)<deixis-rendered-start>]
  if mode == "duplicate-start" { [#metadata(data)<deixis-rendered-start>] }
  data.body
  if mode not in ("missing-end", "end-before-start") { [#metadata(data)<deixis-rendered-end>] }
  if mode == "duplicate-end" { [#metadata(data)<deixis-rendered-end>] }
}
#let long-renderer(data, ..args) = {
  if data.at("disable-links", default: false) { return data.body }
  deixis-generate-body-meta(data)
  [#metadata(data)<deixis-rendered-start>]
  data.body
  pagebreak()
  deixis-inline-note-body(id: <short>)[A complete second-page body.]
  for mode in ("missing-end", "duplicate-start", "duplicate-end", "end-before-start") {
    deixis-inline-note-body(id: label(mode), render-single: partial.with(mode))[A partial body.]
  }
  // Detached low-level metadata is not a registered annotation.
  let ghost = (internal-id: "ghost", body-type: "inline-note")
  [#metadata(ghost)<deixis-rendered-start>#metadata(ghost)<deixis-rendered-end>]
  pagebreak()
  [Third page.]
  [#metadata(data)<deixis-rendered-end>]
}
#deixis-inline-note-body(id: <long>, render-single: long-renderer)[First page.]
#context {
  assert.eq(query(<span-page>).map(m => m.value), (
    (page: 1, all: (<long>,)),
    (page: 2, all: (<long>, <short>)),
    (page: 3, all: (<long>,)),
  ))
  let catalogue = deixis-query-notes(include-unpaired: true)
  assert.eq(catalogue.len(), 6)
  for id in (<missing-end>, <duplicate-start>, <duplicate-end>, <end-before-start>) {
    let n = catalogue.find(n => n.id == id)
    assert(n.body.dest != none)
    assert.eq((n.body.start, n.body.end), (none, none))
  }
  assert.eq(catalogue.find(n => n.id == <duplicate-start>).body.render-order, none)
  assert(catalogue.find(n => n.id == <missing-end>).body.render-order != none)
}
