#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#set page(width: 500pt, height: 400pt, margin: 35pt)
#show: deixis-setup-notes
#deixis-set(palette: (blue, orange, teal))
#deixis-mark(id: <one>)[One]
#deixis-mark(of: <future>)[Forward Reuse]
// This forward body captures a different palette than the later original.
#deixis-inline-note-body(of: <future>)[Forward Body]
#deixis-block(id: <inner>, inset: 10pt)[
  #deixis-mark(id: <inherited>)[Inherited]
  #deixis-set(palette: (purple, green))
  #deixis-mark(id: <inner-one>)[Inner One]
  #deixis-block(inset: 5pt)[#deixis-mark(id: <inner-two>)[Inner Two]]
  #deixis-mark(id: <inner-three>)[Inner Three]
  #deixis-set(palette: none)
  #deixis-mark(id: <off>)[No Accent]
]
#deixis-update-note-counter(0)
#deixis-mark(id: <outer-resume>)[Outer Resumes]
#deixis-set(palette: (maroon, aqua))
#deixis-mark(id: <future>)[Future Original]
#deixis-mark(id: <new-second>)[Second New]
#deixis-set(palette: auto)
#deixis-mark(id: <auto-unchanged>)[Auto Keeps Cycle]
#deixis-set(palette: none)
#deixis-mark(id: <no-palette>)[Off]
#deixis-mark(of: <one>)[Original Still Blue]
#deixis-set(palette: (blue,) * 128)
#deixis-mark(id: <large-palette>)[A Long Palette]
#deixis-set(palette: (teal,))
#deixis-mark(id: <single-one>)[One Color]
#deixis-mark(id: <single-two>)[One Color Again]
#let verify() = {
 let expected = (one: blue, inherited: orange, inner-one: purple, inner-two: green,
   inner-three: purple, off: none, outer-resume: teal, future: maroon,
   new-second: aqua, auto-unchanged: maroon, no-palette: none, large-palette: blue, single-one: teal, single-two: teal)
 let registry = deixis-system.final()
 assert.eq(registry.registry.value.notes.len(), expected.len())
 for (id, color) in expected { assert.eq(registry.registry.value.notes.at("id-" + id).accent, color) }
 assert.eq(query(<deixis-inline-note>).first().value.accent, maroon)
 assert.eq(query(<deixis-inline-note>).first().value.styles.stroke.paint, maroon)
 true
}
