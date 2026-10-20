#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#set page(width: 500pt, height: 500pt, margin: (left: 40pt, right: 140pt, y: 40pt))
#show: deixis-setup-notes
#deixis-set(omit: (series: ("todo",)), palette: (red, blue))
#let removed = [REMOVED#context { panic("Omitted body executed") }]
// All body adapters, both declaration orders, and all supported paint layers.
#for (kind, adapter) in (("foot", deixis-footnote-body), ("end", deixis-endnote-body),
  ("inline", deixis-inline-note-body), ("margin", deixis-margin-note-body), ("inset", deixis-inset-note-body)) {
  for forward in (false, true) {
    let id = kind + repr(forward)
    let mark = deixis-mark(id: id, series: "todo")[Kept Separate Passage]
    let body = adapter(of: id, removed)
    if forward { [#body#mark] } else { [#mark#body] }
    deixis-mark(of: id, occurrence: "again")[Kept Repeated Passage]
  }
  adapter(id: kind + "standalone", series: "todo", removed)
}
#for layer in ("flow", "foreground", "background") {
  deixis-footnote(series: "todo", layer: layer)[Kept Foot Passage][#removed]
  deixis-margin-note(series: "todo", layer: layer, connector: "curve")[Kept Margin Passage][#removed]
  deixis-inset-note(series: "todo", layer: layer, connector: "curve")[Kept Inset Passage][#removed]
}
// A live body may contain omitted marks. A kept passage may itself contain
// an independent live annotation; omission removes only the outer annotation.
#deixis-footnote(id: <outer>)[
  Visible Outer Body #deixis-mark(id: <nested-omitted>, series: "todo")[Kept Nested Passage]
]
#deixis-footnote(series: "todo")[Kept Outer #deixis-mark(id: <kept-inner>)[Inner Passage]][#removed]
// Forward omitted attachments suppress their nested declarations and callbacks.
#deixis-endnote-body(of: <forward-parent>)[#deixis-mark(id: <removed-child>)[REMOVED]#removed]
#deixis-mark(id: <forward-parent>, series: "todo")[Kept Parent Passage]
// Explicit edges touching omitted annotations disappear, including named repeats.
#deixis-connect(from: (mark: <footfalse>, occurrence: "again"), to: <outer>)
#deixis-connect(from: <outer>, to: <footfalse>)
#deixis-set(omit: none)
Live#deixis-footnote(id: <live>, series: "todo")[Visible Live Body].
#deixis-print-endnotes()
#context {
  let r = deixis-system.final().registry.value
  assert.eq(r.notes.len(), 3)
  assert.eq(r.notes.at(r.id-index.at("outer")).count, 1)
  assert.eq(r.notes.at(r.id-index.at("kept-inner")).count, 2)
  assert.eq(r.notes.at(r.id-index.at("live")).count, 1)
  assert.eq(r.notes.at(r.id-index.at("outer")).accent, red)
  assert.eq(r.notes.at(r.id-index.at("kept-inner")).accent, blue)
  assert.eq(r.pending-bodies.len(), 0)
}
