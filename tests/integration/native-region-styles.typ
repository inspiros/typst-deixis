#import "../../src/lib.typ": *
#set page(width: 460pt, height: 340pt, margin: 40pt)
#show: deixis-setup-notes
#let edges = (x: blue, y: red, bottom: purple + 2pt)
#let radius = (rest: 2pt, top: 4pt, bottom: 7pt, bottom-left: 9pt)
#let shape(name, ..args) = {
  [#metadata((name: name, stroke: args.named().stroke, radius: args.named().radius))<region-native-style>]
  deixis-rect-region(..args.named())
}
#deixis-pin("range")Region begins.
#deixis-region-mark(id: <region>, pins: ("range",), stroke: edges, radius: radius, region-shape: shape.with("original"))
#deixis-mark(of: <region>, pins: ("range",), stroke: edges, radius: radius, layer: "background", region-shape: shape.with("reuse"))
#pagebreak()
Middle page.
#pagebreak()
Region ends.#deixis-pin("range")
#context {
  let actual = query(<region-native-style>)
  assert.eq(actual.len(), 6)
  for name in ("original", "reuse") {
    let fragments = actual.filter(m => m.value.name == name).sorted(key: m => m.location().page())
    assert.eq(fragments.map(m => m.location().page()), (1, 2, 3))
    let first = fragments.first().value
    let middle = fragments.at(1).value
    let last = fragments.last().value
    assert.eq(first.radius, (top-left: 4pt, top-right: 4pt, bottom-left: 0pt, bottom-right: 0pt))
    assert.eq(middle.radius, (top-left: 0pt, top-right: 0pt, bottom-left: 0pt, bottom-right: 0pt))
    assert.eq(last.radius, (top-left: 0pt, top-right: 0pt, bottom-left: 9pt, bottom-right: 7pt))
    assert.eq(first.stroke.top.paint, red)
    assert.eq(first.stroke.bottom, none)
    assert.eq(middle.stroke.top, none)
    assert.eq(middle.stroke.bottom, none)
    assert.eq(last.stroke.top, none)
    assert.eq(last.stroke.bottom.paint, purple)
    assert.eq(last.stroke.bottom.thickness, 2pt)
    for m in fragments {
      assert.eq(m.value.stroke.left.paint, blue)
      assert.eq(m.value.stroke.right.paint, blue)
    }
  }
}
