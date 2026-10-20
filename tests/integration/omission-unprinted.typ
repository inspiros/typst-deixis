#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#show: deixis-setup-notes
#deixis-set(omit: (series: ("todo",)))
// Nested declarations keep their source semantics even without a printer.
// Reuse/body precede the containing endnote to exercise forward lookup too.
#deixis-mark(of: <inner>)[Kept Unprinted Reuse]
#deixis-inline-note-body(of: <inner>)[REMOVED#context { panic("Omitted body executed") }]
#deixis-endnote(id: <outer>)[
  #deixis-mark(id: <inner>, series: "todo")[Unprinted Passage]
  #context { panic("Unprinted body executed") }
]
#context {
  let r = deixis-system.final().registry.value
  assert.eq(r.notes.len(), 1)
  assert.eq(r.pending-bodies.len(), 0)
  assert.eq(query(<deixis-omitted>).filter(it => it.value.id == <inner>).len(), 1)
  assert.eq(query(<deixis-mark-occurrence>).len(), 0)
}
