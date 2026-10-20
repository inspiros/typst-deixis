#import "../../src/lib.typ": *
#set page(width: 550pt, height: 1200pt, margin: 40pt)
#show: deixis-setup-notes
#let ticks = state("collection-scopes-live", 0)
#let body = [#ticks.update(n => n + 1)Live body.]
#deixis-block(id: <first>, thread: "first")[
  #deixis-mark(id: <moved>, series: "notes")[Retargeted original]
  #deixis-endnote-body(of: <moved>, target: <second>)[#body]
  #deixis-endnote(id: <stays>, series: "notes")[#body]
  #deixis-endnote-body(id: <standalone>, series: "notes")[#body]
  #deixis-mark(id: <mark-only>, series: "notes")[Mark without body]
]
#deixis-block(id: <second>, thread: "second")[
  #deixis-endnote(id: <second-note>, series: "notes")[#body]
]
#deixis-block(id: <synced>, sync-counters-with: <first>)[
  #deixis-endnote(id: <synced-note>, series: "notes")[#body]
]
#let outline(name, ..options) = deixis-note-outline(title: none,
  include-unpaired: true, summary: note => [#metadata((name: name, id: note.id))<scope-outline>Summary.],
  ..options.named())
#outline("all")
#outline("first", target: <first>, thread: "first")
#outline("second", target: "second", thread: "second")
#outline("disjoint", target: <first>, thread: "second")
#outline("synced", target: <synced>)
#outline("sync-disjoint", target: <synced>, thread: "first")
#outline("string-types", include-types: "endnote", exclude-types: "inline-mark", series: "notes")
#outline("array-types", include-types: ("endnote", "endnote"), exclude-types: ("inline-mark",), series: ("notes", "notes"))
#outline("empty-include", include-types: ())
#outline("empty-series", series: ())
#outline("unknown-series", series: "unknown")
#outline("near-type", include-types: "endnotes")
#outline("exclude-near-type", exclude-types: "inline-marks")
#deixis-block(id: <first-again>, thread: "first")[#outline("relative", target: 0)]
#deixis-print-endnotes(target: <first>)
#deixis-print-endnotes(target: <second>)
#deixis-print-endnotes(target: <synced>)
#for id in (<moved>, <stays>, <standalone>, <second-note>, <synced-note>) { [#link(id)[Body] ] }
#context {
  let rows = query(<scope-outline>).map(n => n.value)
  let selected(name) = rows.filter(n => n.name == name).map(n => n.id)
  assert.eq(selected("all"), (<moved>, <stays>, <standalone>, <mark-only>, <second-note>, <synced-note>))
  assert.eq(selected("first"), (<stays>, <standalone>, <mark-only>))
  assert.eq(selected("relative"), selected("first"))
  assert.eq(selected("second"), (<moved>, <second-note>))
  assert.eq(selected("synced"), (<synced-note>,))
  for name in ("disjoint", "sync-disjoint", "empty-include", "empty-series", "unknown-series", "near-type") { assert.eq(selected(name), ()) }
  assert.eq(selected("exclude-near-type"), selected("all"))
  assert.eq(selected("string-types"), (<moved>, <stays>, <standalone>, <second-note>, <synced-note>))
  assert.eq(selected("string-types"), selected("array-types"))
  assert.eq(ticks.final(), 5)
  assert.eq(query(<deixis-rendered-start>).map(n => n.value.id), (<stays>, <standalone>, <moved>, <second-note>, <synced-note>))
  [#metadata((destinations: query(<deixis-body-destination>).map(body => {
    let pos = body.location().position()
    (page: pos.page, x: pos.x.pt(), y: pos.y.pt())
  })))<test-result>]
}
