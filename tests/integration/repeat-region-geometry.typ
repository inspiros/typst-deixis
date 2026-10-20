#import "../../src/lib.typ": *
#import "../../src/core/query.typ": _deixis-pin-index, _deixis-pins-for
#import "../../src/layout/geometry.typ": _deixis-region-bounds
#set page(width: 520pt, height: 440pt, margin: 45pt)
#show: deixis-setup-notes
#let ticks = state("region-reuse-atoms", 0)
#let atom = [#ticks.update(n => n + 1)#box(width: 40pt, height: 20pt)]
#let shape(name, ..args) = {
  let a = args.named()
  box(width: a.width, height: a.height, {
    place(top + left, [#metadata((name: name, width: a.width, height: a.height))<repeat-region-envelope>])
    deixis-rect-region(..a)
  })
}
Original#deixis-inline-mark(id: <owner>).
#deixis-region-mark(of: <owner>, inline: true, occurrence: <plain>, padding: 2pt,
  region-shape: shape.with("plain"))[#atom]
#v(15pt)
#rotate(45deg, origin: top + left, reflow: true,
  deixis-region-mark(of: <owner>, inline: true, occurrence: <rotated>, padding: 2pt,
    region-shape: shape.with("rotated"))[#atom])
#v(15pt)
#scale(x: 150%, y: 80%, origin: top + left, reflow: true,
  deixis-region-mark(of: <owner>, inline: true, occurrence: <scaled>, padding: 0pt,
    region-shape: shape.with("scaled"))[#atom])
#v(15pt)
#deixis-region-mark(of: <owner>, inline: true, occurrence: <immediate>, layer: "flow", padding: 1pt,
  region-shape: shape.with("immediate"))[#atom]
#context {
  assert.eq(ticks.final(), 4)
  let index = _deixis-pin-index()
  let regions = query(<deixis-region-occurrence>)
  assert.eq(regions.len(), 4)
  let owners = regions.map(r => r.value.occurrence-owner)
  assert.eq(owners.dedup().len(), 4)
  for region in regions {
    let data = region.value
    let pins = _deixis-pins-for(index, data.pins)
    assert.eq(pins.len(), 4)
    let envelope = query(<repeat-region-envelope>).find(s => s.value.name == data.occurrence-name)
    let bounds = _deixis-region-bounds(pins, envelope.location().page(), padding: data.styles.padding)
    assert(calc.abs(envelope.location().position().x - bounds.left) < 0.001pt)
    assert(calc.abs(envelope.location().position().y - bounds.top) < 0.001pt)
    assert(calc.abs(envelope.value.width - (bounds.right - bounds.left)) < 0.001pt)
    assert(calc.abs(envelope.value.height - (bounds.bottom - bounds.top)) < 0.001pt)
    if data.occurrence-name == "rotated" {
      let side = 60pt / calc.sqrt(2) + 4pt
      assert(calc.abs(envelope.value.width - side) < 0.001pt)
      assert(calc.abs(envelope.value.height - side) < 0.001pt)
    }
    if data.occurrence-name == "scaled" {
      assert(calc.abs(envelope.value.width - 60pt) < 0.001pt)
      assert(calc.abs(envelope.value.height - 16pt) < 0.001pt)
    }
  }
}
