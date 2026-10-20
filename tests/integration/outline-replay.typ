#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#set page(width: 420pt, height: 360pt, margin: (left: 35pt, right: 130pt, y: 35pt))
#show: deixis-setup-notes
// Native outlines replay heading and caption bodies. Replayed annotations show
// only their passages: no second registration, number, body or label.
#let runs = state("outline-replay-runs", 0)
#outline()
#outline(target: figure)

= Named#deixis-footnote(id: <head-note>, layer: "flow")[Heading body.#runs.update(n => n + 1)]
= Anonymous#deixis-footnote[Anonymous heading body.#runs.update(n => n + 1)]
= Our #deixis-margin-note(id: <head-margin>)[method][Margin body.#runs.update(n => n + 1)] works
= Outer #deixis-mark[nested #deixis-mark(id: <inner>)[inner] passage] end
#figure(rect[x], caption: [A #deixis-mark(id: <cap>)[captioned] figure#deixis-footnote(id: <cap-note>)[Caption body.#runs.update(n => n + 1)]])
#deixis-inline-note-body(of: <cap>)[Inline caption body.#runs.update(n => n + 1)]
Text#deixis-footnote(id: <after>)[After.] and #deixis-mark(of: <head-margin>)[a reuse]. See @head-note, @inner and @cap.

#context {
  let sys = deixis-system.final()
  // Five originals plus the anonymous decorations; numbering continues once.
  assert.eq(sys.registry.value.notes.at(sys.registry.value.id-index.at("head-note")).count, 1)
  assert.eq(sys.registry.value.notes.at(sys.registry.value.id-index.at("head-margin")).count, 3)
  assert.eq(sys.registry.value.notes.at(sys.registry.value.id-index.at("inner")).count, 4)
  assert.eq(sys.registry.value.notes.at(sys.registry.value.id-index.at("cap")).count, 5)
  assert.eq(sys.registry.value.notes.at(sys.registry.value.id-index.at("cap-note")).count, 6)
  assert.eq(sys.registry.value.notes.at(sys.registry.value.id-index.at("after")).count, 7)
  assert.eq(runs.final(), 5)
  assert.eq(query(<deixis-footnote-entry>).len(), 4)
  assert.eq(query(<deixis-mark-destination>).filter(d => d.value.internal-id == sys.registry.value.id-index.at("head-margin")).len(), 1)
  // Outline entries show the passages without markers.
  let entries = query(outline.entry).map(e => e.body())
  assert(entries.len() == 5)
}
