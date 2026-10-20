#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#show: deixis-setup-notes
// This public alias resembles the next automatic parent's private key.
#deixis-block(id: repr(("auto", 2)))[#deixis-phantom-mark(id: <decoy>)]
#deixis-block[
  #deixis-phantom-mark(id: <parent>)
  #deixis-block(id: <child>, sync-counters-with: 0)[
    #deixis-phantom-mark(id: <child-note>)
    #context assert.eq(deixis-note-counter(), 2)
  ]
]
#for id in (<decoy>, <parent>, <child-note>) {
  deixis-inline-note-body(of: id)[One body.]
  [#link(id)[Native link] ]
}
#context {
  let sys = deixis-system.final()
  let get(id) = sys.registry.value.notes.at(sys.registry.value.id-index.at(str(id)))
  assert.eq(get(<decoy>).count, 1)
  assert.eq(get(<parent>).count, 1)
  assert.eq(get(<child-note>).count, 2)
  assert.ne(get(<decoy>).count-id, get(<parent>).count-id)
  assert.eq(get(<parent>).count-id, get(<child-note>).count-id)
  assert.eq(deixis-note-counter(target: -99), 0)
  assert.eq(sys.stack, ())
  assert.eq(query(<deixis-body-destination>).len(), 3)
}
