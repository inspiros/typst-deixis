#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#set page(width: 540pt, height: 380pt, margin: (x: 110pt, y: 50pt))
#show: deixis-setup-notes
#let kind = sys.inputs.at("kind", default: "margin")
#let layer = sys.inputs.at("layer", default: "foreground")
#let inline = sys.inputs.at("inline", default: "true") == "true"
#let ticks = state("flow-region-registered-live", 0)
#let shape(..options) = {
  let o = options.named()
  box(width: o.width, height: o.height, {
    place(top + left, [#metadata((width: o.width, height: o.height))<registered-flow-shape>])
    deixis-rect-region(..o)
  })
}
#let body = [
  Before.
  #deixis-region-mark(id: <nested>, layer: "flow", inline: inline, padding: 2pt,
    region-shape: shape)[#ticks.update(n => n + 1)#box(width: 28pt, height: 14pt)]
  After.
]
Standalone body:
#if kind == "margin" {
  deixis-margin-note-body(id: <owner>, layer: layer, width: 95pt, side: right, backlink: true)[#body]
} else if kind == "inset" {
  deixis-inset-note-body(id: <owner>, layer: layer, width: 105pt, dx: 145pt, dy: 110pt, backlink: true)[#body]
} else {
  deixis-footnote-body(id: <owner>, layer: layer, backlink: true)[#body]
}.
#context {
  assert.eq(ticks.final(), 1)
  assert.eq(deixis-system.final().registry.value.notes.len(), 2)
  assert.eq(query(<deixis-rendered-start>).len(), 1)
}
