// Notes declared inside endnote bodies first execute at the printer. Their
// registration, overlay placement and mark links must still converge within
// Typst's five-pass budget in paged output. HTML is checked by html-endnotes.
#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system, _deixis-registry

#set page(width: 12cm, height: 12cm, margin: (right: 4cm, rest: 1cm))
#show: deixis-setup-notes

Anonymous#deixis-endnote[Outer Anonymous with a #deixis-margin-note[margin][Inner Margin Body.]]
Named#deixis-endnote[Outer Named with a #deixis-margin-note(id: "inner")[margin][Named Margin Body.]]
Footnote#deixis-endnote[Outer Footnote with a #deixis-footnote[foot][Inner Footnote Body.]]
Plain#deixis-endnote[Outer Plain.]

#deixis-print-endnotes()

#let verify() = {
  let registry = _deixis-registry(deixis-system.final())
  // Four endnotes, two margin notes and one footnote, each with mark and body.
  assert.eq(registry.notes.len(), 7)
  let margins = query(<deixis-margin-note>).map(m => m.value)
  assert.eq(margins.len(), 2)
  assert(margins.all(m => m.body-lbl != none), message: "Nested margin bodies must resolve their marks.")
  let frames = query(<deixis-body-frame>).map(m => m.value)
  assert.eq(frames.map(f => f.identity).sorted(), margins.map(m => str(m.internal-id)).sorted())
  // Bodies sit in the right margin, beside the text column.
  assert(frames.all(f => f.node.bounds.left >= 8cm - 1pt), message: "Margin bodies left the right margin.")
  let marks = query(<deixis-mark-destination>).map(m => m.location())
  let bodies = query(<deixis-body-destination>).map(m => m.location())
  assert.eq(marks.len(), 7)
  assert.eq(bodies.len(), 7)
  let point(l) = (page: l.page(), x: l.position().x.pt(), y: l.position().y.pt())
  (destinations: (marks + bodies).map(point))
}

#context { let _ = verify() }
