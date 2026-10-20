#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#set page(width: 560pt, height: 400pt, margin: 80pt)
#show: deixis-setup-notes
#let ticks = state("repeat-geometry-bodies", 0)
Earlier#deixis-mark(of: <shared-body>, occurrence: <early>)[forward use].
#v(25pt)
Original#deixis-margin-note(id: <shared-body>, backlink: true)[
  #ticks.update(n => n + 1)One explanation with
  #deixis-mark(of: <shared-body>, occurrence: <inside>)[a self occurrence].
]
#v(25pt)
Passage#deixis-mark(of: <shared-body>, occurrence: <phrase>, marker: none)[Two words].
Marker#deixis-mark(of: <shared-body>, occurrence: <marker>).
#deixis-mark(of: <shared-body>, occurrence: <hidden>, marker: none)
#v(30pt)
#rotate(25deg, origin: top + left, reflow: true,
  deixis-mark(of: <shared-body>, occurrence: <rotated>)[Rotated words])
#v(25pt)
Other#deixis-endnote(id: <other>)[#ticks.update(n => n + 1)Another explanation.]
// The same occurrence name is valid on another annotation.
#deixis-mark(of: <other>, occurrence: <early>)[Other occurrence]
#deixis-print-endnotes()
#context {
  assert.eq(ticks.final(), 2)
  assert.eq(deixis-system.final().registry.value.notes.len(), 2)
  assert.eq(query(<deixis-rendered-start>).len(), 2)
}
