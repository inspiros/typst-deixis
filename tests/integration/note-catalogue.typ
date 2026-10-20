#import "../../src/lib.typ": *
#import "../../src/render/summary.typ": _deixis-summary-text
#set page(width: 560pt, height: 620pt, margin: 45pt, numbering: "i")
#set text(size: 10pt)
#show: deixis-setup-notes
#let bodies = state("catalogue-bodies", 0)
#let passages = state("catalogue-passages", 0)
#counter(page).update(4)
#deixis-mark(of: <shared>, occurrence: <early>)[Forward passage]
Reference #deixis-ref(<shared>).
#deixis-mark(id: <lonely>)[Unpaired original]
#deixis-inline-mark[Anonymous decoration]
#deixis-endnote-body(id: <aside>, series: "reading")[#bodies.update(n => n + 1)Standalone explanation.]
#deixis-endnote-body(id: <unprinted>, series: "pending")[Must stay unprinted.]
#deixis-endnote-body(series: "pending")[Anonymous unprinted body.]
#pagebreak()
#set page(numbering: "A")
#counter(page).update(2)
#deixis-mark(id: <shared>, series: "reading")[Original passage]
#deixis-endnote-body(of: <shared>)[
  Shared *explanation*. #bodies.update(n => n + 1)
  #context [Live context must run only in this body.]
  #metadata(none)<catalogue-body-label>
]
#deixis-mark(of: <shared>, occurrence: <named>)[#passages.update(n => n + 1)Named passage]
#deixis-mark(of: <shared>)[Unnamed passage]
#deixis-mark(of: <shared>, mark-type: "phantom", occurrence: <quiet>)
#deixis-mark(id: <pending>, series: "pending")[Unprinted paired note]
#deixis-endnote-body(of: <pending>)[Unprinted paired explanation.]
#pagebreak()
#set page(numbering: none)
#deixis-mark(of: <shared>, mark-type: "region", occurrence: <remote>, pins: ("r1", "r2"))
#deixis-mark(of: <shared>, mark-type: "region", pins: ("r1", "r2"))
Remote region declarations.
#pagebreak()
#set page(numbering: (..nums) => [P#nums.pos().first()])
#counter(page).update(2)
#deixis-pin("r1")Remote marked region.#deixis-pin("r2")
#pagebreak()
#set page(numbering: "1")
#counter(page).update(17)
#deixis-print-endnotes(series: "reading")
#deixis-note-outline(title: none, series: "reading", include-unpaired: "body")
#context {
  let notes = deixis-query-notes(include-unpaired: true)
  let selected(id) = notes.find(n => n.id == id)
  let shared = selected(<shared>)
  assert.eq(shared.count, 1)
  assert.eq(shared.marks.len(), 7)
  assert.eq(shared.marks.map(m => m.type), ("inline-mark", "inline-mark", "inline-mark", "inline-mark", "phantom-mark", "region-mark", "region-mark"))
  assert.eq(shared.marks.map(m => m.original), (false, true, false, false, false, false, false))
  assert.eq(shared.marks.map(m => m.occurrence), ("early", none, "named", none, "quiet", "remote", none))
  assert.eq(shared.marks.map(m => m.loc.page()), (1, 2, 2, 2, 2, 3, 3))
  assert.eq(shared.marks.map(m => m.dest.page()), (1, 2, 2, 2, 2, 4, 4))
  assert.eq(shared.body.loc.page(), 2)
  assert.eq((shared.body.dest.page(), shared.body.start.page(), shared.body.end.page()), (5, 5, 5))
  assert.eq(_deixis-summary-text(shared.summary), "Shared explanation.")
  assert.eq(_deixis-summary-text(shared.marks.at(2).summary), "Named passage")
  assert.eq(shared.dest.page(), 2)
  assert.eq(shared.loc.page(), 2)
  assert.eq(selected(<pending>).body.dest, none)
  assert.eq(selected(<pending>).body.start, none)
  assert.eq(selected(<unprinted>).body.dest, none)
  assert.eq(selected(<aside>).marks, ())
  assert.eq(selected(<aside>).count, none)
  assert.eq(selected(<aside>).body.dest.page(), 5)
  assert.eq(selected(<aside>).dest.page(), 5)
  assert.eq(selected(<lonely>).body, none)
  assert.eq(notes.filter(n => n.id == none).map(n => n.type), ("inline-mark", "endnote"))
  assert.eq(deixis-query-notes().map(n => n.id), (<shared>, <pending>))
  assert.eq(deixis-query-notes(include-unpaired: "body").filter(n => n.marks.len() == 0).len(), 3)
  // Grouped and repeated queries are metadata reads, not body/passage execution.
  assert.eq(bodies.final(), 2)
  assert.eq(passages.final(), 1)
  assert.eq(query(<deixis-mark-occurrence>).len(), 6)
  assert.eq(query(<deixis-ref-marker>).len(), 1)
  assert.eq(query(<catalogue-body-label>).len(), 1)
  // All selected mark destinations get actual PDF page links, independently of
  // the row's original-mark link. Body links are available for custom views.
  for m in shared.marks { [#link(m.dest)[Occurrence link] ] }
  for n in (shared, selected(<aside>)) {
    if n.body.dest != none { [#link(n.body.dest)[Body link] ] }
  }
  [#metadata((destinations: (shared.marks.map(m => m.dest) + (shared.body.dest, selected(<aside>).body.dest)).map(loc => {
    let pos = loc.position()
    (page: pos.page, x: pos.x.pt(), y: pos.y.pt())
  })))<test-result>]
}
