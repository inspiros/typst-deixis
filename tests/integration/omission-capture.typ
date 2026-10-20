#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#set page(width: 450pt, height: 450pt, margin: 40pt)
#show: deixis-setup-notes
#deixis-endnote(series: "first")[
  #deixis-mark(id: <kept-inner>, series: "todo")[Kept Live Inner]
]
#deixis-set(omit: (series: ("todo",)))
// Changing policy before painting cannot undo an original already registered
// at this body's declaration point.
#deixis-print-endnotes(series: "first")
#deixis-endnote(series: "second")[
  #deixis-mark(id: <dropped-inner>, series: "todo", mark-type: "region", inline: true,
    region-shape: (..args) => panic("Omitted shape executed"))[Kept Plain Inner]
]
#deixis-set(omit: none)
// Nor can printing later bring back an original omitted at declaration time.
#deixis-print-endnotes(series: "second")
#context {
  let r = deixis-system.final().registry.value
  assert.eq(r.notes.len(), 3)
  let uid = r.id-index.at("kept-inner")
  assert.eq(query(<deixis-inline-mark>).filter(it => str(it.value.internal-id) == uid).len(), 1)
  assert("dropped-inner" not in r.id-index)
}
