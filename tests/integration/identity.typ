#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#set page(width: 500pt, height: 600pt, margin: 90pt)
#show: deixis-setup-notes

// Every body type must associate in either declaration order.
#deixis-footnote-body(of: <forward-foot>)[Forward footnote.]
#deixis-endnote-body(of: <forward-end>)[Forward endnote.]
#deixis-margin-note-body(of: <forward-margin>)[Forward margin.]
#deixis-inset-note-body(of: <forward-inset>)[Forward inset.]
#deixis-inline-note-body(of: <forward-inline>)[Forward inline.]

Marks:
#deixis-inline-mark(id: <forward-foot>)[foot]
#deixis-phantom-mark(id: <forward-end>)
#deixis-inline-mark(id: <forward-margin>)[margin]
#deixis-inline-mark(id: <forward-inset>)[inset]
#deixis-inline-mark(id: <forward-inline>)[inline].

Nested#deixis-footnote[
  Outer note#deixis-endnote[Nested endnote.].
]
After#deixis-footnote[After nested note.].

Refs: @forward-foot, @forward-end, @forward-margin, @forward-inset, @forward-inline.
#deixis-print-endnotes()

#context [#metadata((
  notes: deixis-system.final().registry.value.notes.values().map(n => (
    id: n.internal-id,
    type: n.at("body-type", default: none),
    count: n.count,
    series: n.series,
  )),
  labels: deixis-system.final().registry.value.id-index.keys().sorted(),
))<test-result>]
