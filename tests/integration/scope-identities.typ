#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system, _deixis-layout-scopes
#set page(width: 520pt, height: 620pt, margin: 40pt)
#show: deixis-setup-notes
#let live = state("scope-identities-live", ())
#let ids = ()
#let note(id) = {
  deixis-footnote(id: id)[#live.update(xs => xs + (str(id),))Body #str(id).]
}
// Serial 1 and public name "1" must have different geometry/counter owners.
#deixis-block[Automatic#note(<automatic>)]
#deixis-block(id: "1")[Named#note(<named-number>)]
#deixis-block(id: "thread-reading")[Named prefix#note(<named-prefix>)]
#deixis-block(id: <member-a>, thread: <reading>)[First member#note(<member-first>)]
#deixis-block(id: "member-b", thread: "reading")[Second member#note(<member-second>)]
// Even a literal spelling of a private key is only a public name.
#for (i, name) in (repr(("auto", 1)), repr(("block", "1")), repr(("thread", "reading"))).enumerate() {
  deixis-block(id: name)[Hostile-looking name#note(label("literal-" + str(i)))]
}
#pagebreak()
#deixis-mark(id: <forward>, target: <future>)[Forward original]
#deixis-footnote-body(of: <forward>)[#live.update(xs => xs + ("forward",))Forward body.]
#deixis-block(id: <future>, sync-counters-with: "member-a")[Future#note(<future-local>)]
#pagebreak()
// Parent synchronization uses the selected instance, not a public alias.
#deixis-block(id: <parent-scope>)[
  Parent#note(<parent>)
  #deixis-minipage(id: <deep>, sync-counters-with: 0)[Child#note(<child>)]
]
#let ids = (<automatic>, <named-number>, <named-prefix>, <member-first>, <member-second>,
  <literal-0>, <literal-1>, <literal-2>, <forward>, <future-local>, <parent>, <child>)
#for id in ids { [#link(id)[Body ] ] }
#context {
  let sys = deixis-system.final()
  let scopes = query(<deixis-scope>).map(m => m.value)
  assert.eq(scopes.len(), 11)
  assert.eq(scopes.map(s => s.id).dedup().len(), scopes.len())
  assert.eq(live.final().sorted(), ids.map(str).sorted())
  assert.eq(query(<deixis-body-destination>).len(), ids.len())
  assert.eq(sys.stack, ())
  assert.eq(_deixis-layout-scopes.final().stack, ())
  let get(id) = sys.registry.value.notes.at(sys.registry.value.id-index.at(str(id)))
  assert.ne(get(<automatic>).inst-id, get(<named-number>).inst-id)
  assert.ne(get(<named-prefix>).target-id, get(<member-first>).target-id)
  assert.eq(get(<member-first>).target-id, get(<member-second>).target-id)
  assert.ne(get(<member-first>).inst-id, get(<member-second>).inst-id)
  for id in (<automatic>, <named-number>, <named-prefix>, <member-first>, <literal-0>, <literal-1>, <literal-2>, <parent>) {
    assert.eq(get(id).count, 1)
  }
  assert.eq(get(<member-second>).count, 2)
  assert.eq(get(<forward>).count, 3)
  assert.eq(get(<future-local>).count, 4)
  assert.eq(get(<child>).count, 2)
  assert.eq(get(<parent>).count-id, get(<child>).count-id)
  assert.eq(get(<forward>).count-id, get(<member-first>).count-id)
  assert.eq(get(<forward>).inst-id, sys.blocks.at("future").inst-id)
  let all = deixis-query-notes()
  let names = values => values.map(n => n.id)
  assert.eq(names(deixis-query-notes(thread: <reading>)), (<member-first>, <member-second>))
  assert.eq(names(deixis-query-notes(thread: "reading")), names(deixis-query-notes(target: <member-a>)))
  assert.eq(names(deixis-query-notes(target: "thread-reading")), (<named-prefix>,))
  assert.eq(deixis-query-notes(target: "absent"), ())
  assert.eq(deixis-note-counter(target: "absent"), 0)
  for (key, level) in _deixis-layout-scopes.final().blocks {
    for field in level.keys() { assert.eq(level.at(field), sys.blocks.at(key).at(field)) }
  }
  [#metadata((destinations: all.map(n => {
    let p = n.body.dest.position()
    (page: p.page, x: p.x.pt(), y: p.y.pt())
  })))<test-result>]
}
