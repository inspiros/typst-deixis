#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system, _deixis-layout-scopes
#set page(width: 520pt, height: 620pt, margin: 40pt)
#show: deixis-setup-notes
#let live = state("scope-convergence-live", ())
#let mode = sys.inputs.at("mode", default: "named")
#let children-count = if mode == "siblings" { 3 } else { 1 }
#let note(id) = deixis-footnote(id: id)[#live.update(xs => xs + (str(id),))Body #str(id).]
// Earlier local collectors, a shared thread, and a forward body all contribute
// native layout dependencies before the anonymous synchronized parent.
#deixis-block[Automatic#note(<automatic>)]
#deixis-block(id: "number")[Named#note(<named-number>)]
#deixis-block(id: "other")[Other#note(<named-other>)]
#deixis-block(id: <member-a>, thread: <reading>)[First member#note(<member-first>)]
#deixis-block(id: "member-b", thread: "reading")[Second member#note(<member-second>)]
#for i in range(3) {
  deixis-block(id: "earlier-" + str(i))[Earlier#note(label("earlier-note-" + str(i)))]
}
#pagebreak()
#deixis-mark(id: <forward>, target: <future>)[Forward original]
#deixis-footnote-body(of: <forward>)[#live.update(xs => xs + ("forward",))Forward body.]
#deixis-block(id: <future>, sync-counters-with: "member-a")[Future#note(<future-local>)]
#pagebreak()
#let children(n) = if n <= children-count {
  let id = label("child-" + str(n))
  let scope = if mode == "anonymous" { auto } else { "child-scope-" + str(n) }
  deixis-block(id: scope, sync-counters-with: 0)[Child#note(id)]
  children(n + 1)
}
#let parent() = deixis-block[Parent#note(<parent>)#children(1)]
#if mode == "contextual" { context parent() } else { parent() }
#let ids = (<automatic>, <named-number>, <named-other>, <member-first>, <member-second>,
  <earlier-note-0>, <earlier-note-1>, <earlier-note-2>, <forward>, <future-local>, <parent>)
#let ids = ids + range(1, children-count + 1).map(n => label("child-" + str(n)))
#for id in ids { [#link(id)[Body ] ] }
#let verify() = {
  let sys = deixis-system.final()
  let scopes = query(<deixis-scope>).map(m => m.value)
  let get(id) = sys.registry.value.notes.at(sys.registry.value.id-index.at(str(id)))
  assert.eq(live.final().sorted(), ids.map(str).sorted())
  assert.eq(query(<deixis-body-destination>).len(), ids.len())
  assert.eq(query(<deixis-rendered-start>).len(), ids.len())
  assert.eq(scopes.len(), 10 + children-count)
  assert.eq(scopes.map(s => s.id).dedup().len(), scopes.len())
  assert.eq(get(<parent>).inst-id, repr(("auto", 10)))
  assert.eq(get(<parent>).count, 1)
  for n in range(1, children-count + 1) {
    let child = get(label("child-" + str(n)))
    assert.eq(child.count, n + 1)
    assert.eq(child.count-id, get(<parent>).count-id)
    assert.ne(child.inst-id, get(<parent>).inst-id)
    if mode == "anonymous" { assert.eq(child.inst-id, repr(("auto", 10 + n))) }
  }
  assert.eq(get(<member-first>).count, 1)
  assert.eq(get(<member-second>).count, 2)
  assert.eq(get(<forward>).count, 3)
  assert.eq(get(<future-local>).count, 4)
  assert.eq(sys.stack, ())
  assert.eq(_deixis-layout-scopes.final().stack, ())
  for (name, level) in _deixis-layout-scopes.final().blocks {
    for field in level.keys() { assert.eq(level.at(field), sys.blocks.at(name).at(field)) }
  }
  (destinations: ids.map(id => {
    let p = query(id).first().location().position()
    (page: p.page, x: p.x.pt(), y: p.y.pt())
  }))
}
