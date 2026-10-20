#import "../../src/lib.typ": *
#set page(width: 450pt, height: 220pt, margin: (x: 100pt, y: 30pt))
#show: deixis-setup-notes
#let layer = sys.inputs.at("layer", default: "foreground")
#let layout-mode = sys.inputs.at("layout", default: "adaptive")
#let policy = sys.inputs.at("policy", default: "error")
#let live = state("overflow-spill-live", ())
#deixis-set(margin-layout: layout-mode, overflow: policy)
#deixis-margin-note(id: <one>, layer: layer, side: right, width: 85pt)[#live.update(xs=>xs+("one",))#block(height: 95pt)[One.]]
#deixis-margin-note(id: <two>, layer: layer, side: right, width: 85pt)[#live.update(xs=>xs+("two",))#block(height: 95pt)[Two.]]
Text.
#pagebreak()
Continuation.
#link(<one>)[One] #link(<two>)[Two]
#let verify() = {
  assert.eq(live.final().sorted(), ("one", "two"))
  assert.eq(query(<one>).first().location().page(), 1)
  assert.eq(query(<two>).first().location().page(), 2)
  if policy == "error" {
    assert.eq(query(<deixis-margin-overflow>).map(m=>m.value.page), (1, 2))
  }
  (destinations: (<one>, <two>).map(id => {
    let pos = query(id).first().location().position()
    (page: pos.page, x: pos.x.pt(), y: pos.y.pt())
  }))
}
