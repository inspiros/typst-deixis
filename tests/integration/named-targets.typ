#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#set page(width: 500pt, height: 600pt, margin: 60pt)
#show: deixis-setup-notes

// A named threaded block owns its actual thread rendering/counter scope.
Before#deixis-footnote(target: <threaded>)[Forward thread body.]
#deixis-block(id: <threaded>, thread: "chain", inset: 5pt)[
  Inside#deixis-footnote[Inside thread body.]
  #context assert.eq(deixis-note-counter(), 2)
]
After#deixis-footnote(target: <threaded>)[Backward thread body.]
#context assert.eq(deixis-note-counter(target: <threaded>), 3)

// Forward counter updates and both other mark types must use the same scope.
#deixis-update-note-counter(7, target: <synced>)
#deixis-phantom-mark(id: <phantom>, target: <synced>)
#deixis-inline-note-body(of: <phantom>)[Forward phantom.]
#deixis-region-mark(id: <region>, target: <synced>)[Forward region.]
#deixis-inline-note-body(of: <region>)[Forward region body.]
#deixis-block(id: <synced>, sync-counters-with: <threaded>, inset: 5pt)[
  Inside#deixis-footnote[Synced block body.]
  #context assert.eq(deixis-note-counter(), 10)
]

#context {
  let notes = deixis-system.final().registry.value.notes.values()
  assert.eq(notes.map(n => n.count), (1, 2, 3, 8, 9, 10))
  assert.eq(notes.slice(0, 3).map(n => n.target-id), (repr(("thread", "chain")),) * 3)
  assert.eq(notes.slice(0, 3).map(n => n.inst-id), (repr(("block", "threaded")),) * 3)
  let rendered = query(<deixis-rendered-start>).map(n => n.value.internal-id)
  assert(notes.all(n => n.internal-id in rendered), message: "Named target bodies must actually render.")
}
