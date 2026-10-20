#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system, _deixis-layout-scopes
#set page(width: 520pt, height: 420pt, margin: 35pt)
#show: deixis-setup-notes
#let ids = counter("contextual-block-ids")
#let live = state("contextual-block-live", ())
#for i in range(4) {
  ids.step()
  deixis-block(id: "block-" + str(i), inset: (x: 65pt, y: 8pt), stroke: gray,
    sync-counters-with: if i == 3 { "block-1" } else { auto })[
    #deixis-set(fill: (inline-mark: rgb("eef5fc")), inline-mode: "highlight")
    #context {
      let n = ids.get().first()
      let id = label("dynamic-" + str(n))
      // All three identities are generated after scope construction.
      deixis-mark(of: id, occurrence: <before>)[Forward reuse]
      deixis-inset-note-body(of: id, layer: "foreground", width: 90pt, dx: 110pt, dy: 8pt)[
        #live.update(values => values + (n,))One body.
      ]
      deixis-mark(id: id)[Original]
      if i == 1 { deixis-update-note-counter(10) }
    }
    #deixis-block(inset: (x: 4pt, y: 3pt), sync-counters-with: 0)[
      #context {
        let id = label("nested-" + str(ids.get().first()))
        let value = 10 + ids.get().first()
        deixis-footnote(id: id)[#live.update(values => values + (value,))Nested body.]
      }
    ]
  ]
  pagebreak()
}
#context {
  let sys = deixis-system.final()
  let scopes = _deixis-layout-scopes.final()
  assert.eq(sys.stack, ())
  assert.eq(scopes.stack, ())
  assert.eq(sys.registry.value.pending-bodies, (:))
  assert.eq(live.final().sorted(), (1, 2, 3, 4, 11, 12, 13, 14))
  assert.eq(query(<deixis-rendered-start>).len(), 8)
  for i in range(4) {
    let id = label("dynamic-" + str(i + 1))
    let note = sys.registry.value.notes.at(sys.registry.value.id-index.at(str(id)))
    assert.eq(note.inst-id, repr(("block", "block-" + str(i))))
    assert.eq(note.count, if i == 3 { 12 } else { 1 })
    let nested = sys.registry.value.notes.at(sys.registry.value.id-index.at("nested-" + str(i + 1)))
    assert.eq(nested.count, if i == 1 { 11 } else if i == 3 { 13 } else { 2 })
    assert.eq(note.mark-styles.fill, rgb("eef5fc"))
    assert.eq(note.count-id, nested.count-id)
  }
  for key in scopes.blocks.keys() {
    for field in scopes.blocks.at(key).keys() { assert.eq(scopes.blocks.at(key).at(field), sys.blocks.at(key).at(field)) }
  }
}
