#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#set page(width: 420pt, height: 420pt, margin: 35pt, header: context {
  let previous = query(selector(heading).before(here()))
  if previous.len() > 0 [Section: #deixis-plain(previous.last().body)]
})
#show: deixis-setup-notes
#let effects = state("omission-effects", 0)
#deixis-set(omit: (series: ("todo",)))
#outline()
= Keep #deixis-footnote(id: <omitted>, series: "todo")[This Passage][
  REMOVED BODY#effects.update(n => n + 1)
  #deixis-mark(id: <nested>)[REMOVED NESTED]
]
#deixis-mark(of: <later>)[Forward Passage]
#deixis-inset-note-body(of: <later>, dx: 3cm)[REMOVED FORWARD#effects.update(n => n + 1)]
#deixis-mark(id: <later>, series: "todo")[Original Passage]
#deixis-footnote(series: "todo")[Anonymous Passage][REMOVED ANONYMOUS]
#deixis-inline-note(series: "todo")[Inline Passage][REMOVED INLINE]
#deixis-endnote(series: "todo")[End Passage][REMOVED END]
#deixis-margin-note(series: "todo")[Margin Passage][REMOVED MARGIN]
#deixis-inset-note(series: "todo")[Inset Passage][REMOVED INSET]
#deixis-region-mark(id: <region>, series: "todo", inline: true)[Region Passage]
#deixis-phantom-mark(id: <phantom>, series: "todo")
#deixis-inline-note-body(id: <standalone>, series: "todo")[REMOVED STANDALONE]
#deixis-block[
  #deixis-set(omit: none)
  Draft#deixis-footnote(id: <draft>, series: "todo")[Visible Draft Body].
]
Final#deixis-footnote(id: <final>)[Visible Final Body].
Private#deixis-footnote[Visible Private Body].
#deixis-mark(of: <draft>)[Kept Live Reuse]
#deixis-footnote(id: <after>, series: "todo")[After Passage][REMOVED AFTER]
#deixis-print-endnotes()
#pagebreak()
Later Page.
A#metadata(none)<omit-setting-start>#deixis-set(omit: auto)#deixis-set(omit: (series: ("todo",)))#metadata(none)<omit-setting-end>B
#context {
  let r = deixis-system.final().registry.value
  assert.eq(r.notes.len(), 3)
  assert.eq(r.notes.at(r.id-index.at("draft")).count, 1)
  assert.eq(r.notes.at(r.id-index.at("final")).count, 1)
  assert.eq(r.pending-bodies.len(), 0)
  assert.eq(effects.final(), 0)
  assert.eq(query(<deixis-footnote-entry>).len(), 2)
  assert.eq(query(<deixis-mark-occurrence>).len(), 1)
  assert.eq(query(<deixis-omitted>).filter(it => it.value.id == <omitted>).len(), 1)
  assert.eq(query(<omit-setting-start>).first().location().position(),
    query(<omit-setting-end>).first().location().position())
}
