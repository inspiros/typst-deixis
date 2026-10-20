#import "../../src/lib.typ": *
#import "../../src/core/query.typ": _deixis-pin-index, _deixis-pins-for
#import "../../src/layout/geometry.typ": _deixis-region-bounds
#set page(width: 460pt, height: 280pt, margin: 40pt)
#show: deixis-setup-notes
#let ticks = state("region-body-evaluations", 0)
#let shape(name, ..args) = {
  let a = args.named()
  box(width: a.width, height: a.height, {
    place(top + left, [#metadata((name: name, width: a.width, height: a.height, stroke: a.stroke, radius: a.radius))<region-segment>])
    rect(width: 100%, height: 100%, stroke: a.stroke, radius: a.radius)
  })
}
#deixis-region-mark(id: <outer>, layer: "background", padding: 3pt, radius: 7pt, stroke: blue, region-shape: shape.with("outer"))[
  #metadata(none)<body-start>
  #for i in range(12) {
    ticks.update(n => n + 1)
    [Paragraph #i.]
    if i == 4 {
      deixis-region-mark(inline: true, layer: "foreground")[Nested region.]
    }
    v(32pt)
  }
  #metadata(none)<body-end>
]
#pagebreak()
#deixis-region-mark(layer: "foreground", padding: 2pt, radius: 5pt, stroke: green,
  region-shape: shape.with("anonymous"))[
  #metadata(none)<anonymous-start>
  #for i in range(10) {
    ticks.update(n => n + 1)
    [Another paragraph #i.]
    v(32pt)
  }
  #metadata(none)<anonymous-end>
]
#context {
  let regions = query(<deixis-region-mark>)
  let outer = regions.find(r => r.value.internal-id != none).value
  let anonymous = regions.last().value
  assert.eq(anonymous.internal-id, none)
  assert.eq(ticks.final(), 22)
  for (name, reg, start-label, end-label) in (
    ("outer", outer, <body-start>, <body-end>),
    ("anonymous", anonymous, <anonymous-start>, <anonymous-end>),
  ) {
    let pins = _deixis-pins-for(_deixis-pin-index(), reg.pins)
    let segments = query(<region-segment>).filter(s => s.value.name == name)
    let first = query(start-label).first().location().page()
    let last = query(end-label).first().location().page()
    assert(last - first >= 2)
    assert.eq(pins.first().location().page(), first)
    assert.eq(pins.last().location().page(), last)
    assert.eq(segments.map(s => s.location().page()), range(first, last + 1))
    for segment in segments {
      let page = segment.location().page()
      let bounds = _deixis-region-bounds(pins, page, padding: reg.styles.padding)
      let pos = segment.location().position()
      assert(calc.abs(pos.x - bounds.left) < 0.001pt)
      assert(calc.abs(pos.y - bounds.top) < 0.001pt)
      assert(calc.abs(segment.value.height - (bounds.bottom - bounds.top)) < 0.001pt)
      if page != first { assert.eq(segment.value.stroke.top, none); assert.eq(segment.value.radius.top-left, 0pt) }
      if page != last { assert.eq(segment.value.stroke.bottom, none); assert.eq(segment.value.radius.bottom-right, 0pt) }
    }
  }
}
