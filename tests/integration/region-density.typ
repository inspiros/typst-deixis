#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#import "../../src/core/query.typ": _deixis-pin-index
#set page(width: 520pt, height: 540pt, margin: 40pt)
#show: deixis-setup-notes
#let ticks = state("dense-region-evaluations", 0)
#let shape(name, ..args) = {
  let a = args.named()
  box(width: a.width, height: a.height, {
    place(top + left, [#metadata(name)<dense-region-shape>])
    rect(width: 100%, height: 100%, stroke: gray)
  })
}
#for (index, layer) in ("foreground", "background", "flow").enumerate() {
  if index > 0 { pagebreak() }
  grid(columns: (1fr, 1fr, 1fr), gutter: 22pt, ..range(24).map(i => {
    let name = layer + str(i)
    deixis-region-mark(id: name, inline: true, layer: layer, region-shape: shape.with(name))[
      Outer
      #deixis-region-mark(inline: true, layer: layer, region-shape: shape.with(name + "inner"))[
        #ticks.update(n => n + 1)
        $x_i$
      ]
    ]
  }))
}
#context {
  assert.eq(ticks.final(), 72)
  assert.eq(deixis-system.final().registry.value.notes.len(), 72)
  let pins = _deixis-pin-index()
  let all-pins = query(<deixis-pin>)
  assert.eq(all-pins.len(), 576)
  assert.eq(all-pins.map(p => p.value.name).dedup().len(), 576)
  assert.eq(pins.named.len(), 288)
  let shapes = query(<dense-region-shape>).map(m => m.value)
  assert.eq(shapes.len(), 144)
  assert.eq(shapes.dedup().len(), 144)
}
