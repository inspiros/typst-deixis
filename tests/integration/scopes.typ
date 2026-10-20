#import "../../src/lib.typ": *
#set page(width: 500pt, height: 500pt, margin: 80pt)
#show: deixis-setup-notes
Page#deixis-footnote[Page note.]
#deixis-block(id: <one>, inset: 5pt)[
  Local#deixis-footnote[Local note.]
  #deixis-block(inset: 5pt)[
    Nested#deixis-footnote[Nested note.]
    #context assert.eq(deixis-note-counter(), 1)
  ]
  #context assert.eq(deixis-note-counter(), 1)
]
#deixis-block(sync-counters-with: <one>, inset: 5pt)[
  Shared#deixis-footnote[Shared note.]
  #context assert.eq(deixis-note-counter(), 2)
]
#deixis-block(thread: "chain", inset: 5pt)[
  Thread#deixis-footnote[Thread one.]
]
#deixis-block(thread: "chain", inset: 5pt)[
  Thread#deixis-footnote[Thread two.]
  #context assert.eq(deixis-note-counter(), 2)
]
#deixis-block(id: <page-thread>, thread: "page")[
  #deixis-phantom-mark(id: <page-thread-first>)
  #context assert.eq(deixis-note-counter(), 1)
]
#deixis-block(thread: <page>)[
  #deixis-phantom-mark(id: <page-thread-second>)
  #context assert.eq(deixis-note-counter(), 2)
]
#context {
  assert.eq(deixis-note-counter(), 1)
  assert.eq(deixis-note-counter(target: <page-thread>), 2)
  let threaded = deixis-query-notes(thread: <page>, include-unpaired: true)
  assert.eq(threaded.map(n => n.id), (<page-thread-first>, <page-thread-second>))
  assert.eq(deixis-query-notes(target: "page", thread: "page", include-unpaired: true), ())
  let bodies = query(<deixis-rendered-start>).filter(n => n.value.body-type == "footnote")
  assert.eq(bodies.map(n => n.value.internal-id).sorted(), (1, 2, 3, 4, 5, 6))
}
