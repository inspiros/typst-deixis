#import "../../src/lib.typ": *
#set page(width: 300pt, height: 260pt, margin: (right: 110pt, rest: 20pt))
#show: deixis-setup-notes
// Wrapper-created marks resolve numbering by note family, then mark type, then
// rest. Local options still win; standalone marks have no family.
#deixis-set(numbering: (footnote: "*", endnote: "i", inline-mark: "a", rest: "1"))
F#deixis-footnote(id: <f1>)[One.]
F#deixis-footnote(id: <f2>)[Two.]
M#deixis-margin-note(id: <m>)[Margin.]
S#deixis-sidenote(id: <s>)[Side.]
I#deixis-inline-mark(id: <i>)[standalone]
E#deixis-endnote(id: <e>)[End.]
P#deixis-footnote(id: <p>, mark-type: "phantom")[Phantom.]
R#deixis-footnote(id: <r>, mark-type: "region")[region][Region.]
N#deixis-inline-note(id: <n>)[inline][Inline note.]
L#deixis-footnote(id: <l>, numbering: "A")[Local.]
#deixis-block[
  #deixis-set(numbering: (inline-mark: "I"))
  B#deixis-footnote(id: <b>)[The innermost level matches first.]
]
#deixis-print-endnotes()
#context {
  let markers = (:)
  for note in deixis-query-notes(include-unpaired: true) { markers.insert(str(note.id), note.marker) }
  assert.eq(markers, (f1: "*", f2: "†", m: "c", s: "d", i: "e", e: "i", p: "‖", r: "**",
    n: "h", l: "I", b: "I"))
}
