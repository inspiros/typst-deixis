#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#import "../../src/core/query.typ": _deixis-pin-index, _deixis-pins-for
#import "../../src/layout/geometry.typ": _deixis-region-bounds
#set page(width: 530pt, height: 390pt, margin: 45pt)
#show: deixis-setup-notes
#let names = ()
#let audit-shape(name, size, ..args) = {
  assert.eq(text.size, size)
  let width = args.named().width
  let height = args.named().height
  box(width: width, height: height, {
    place(top + left, [#metadata((name: name, width: width, height: height))<region-box>])
    rect(width: 100%, height: 100%, stroke: blue)
  })
}
#let marker(size, it) = {
  assert.eq(text.size, size)
  super(it)
}
#for (i, layer) in ("foreground", "background", "flow").enumerate() {
  if i > 0 { pagebreak() }
  let outer = "outer-" + layer
  let inner = "inner-" + layer
  let cell = "cell-" + layer
  names += (outer, inner, cell, "pins-" + layer)
  rect(inset: 15pt, grid(columns: (1fr, 1fr), gutter: 25pt, {
    set text(size: 17pt)
    deixis-region-mark(id: outer, region-shape: audit-shape.with(outer, 17pt),
      marker-style: marker.with(17pt), layer: layer)[
      Outer body.
      #{
        set text(size: 9pt)
        deixis-region-mark(id: inner, inline: true,
          region-shape: audit-shape.with(inner, 9pt), marker-style: marker.with(9pt), layer: layer)[Inner text]
      }
    ]
  }, {
    set text(size: 23pt)
    table(columns: 1, inset: 8pt,
      [#deixis-region-mark(id: cell, inline: true, padding: 0.2em,
        region-shape: audit-shape.with(cell, 23pt), marker-style: marker.with(23pt), layer: layer)[$x^2$ `x`]],
    )
  }))
  {
    set text(size: 20pt)
    let name = "pins-" + layer
    [#deixis-pin(name + "-l", padding: 4pt)Pinned region#deixis-pin(name + "-r", padding: 4pt)]
    deixis-region-mark(id: name, pins: (name + "-l", name + "-r"), layer: layer,
      padding: (x: 0.25em, y: -0.1em), marker-style: marker.with(20pt),
      region-shape: audit-shape.with(name, 20pt))
  }
}
#context {
  let sys = deixis-system.final()
  let pins = _deixis-pin-index()
  let boxes = query(<region-box>)
  let regions = query(<deixis-region-mark>)
  assert.eq(boxes.len(), 12)
  assert.eq(regions.len(), 12)
  for name in names {
    let uid = sys.registry.value.id-index.at(name)
    let reg = regions.find(r => str(r.value.internal-id) == uid).value
    if name.starts-with("pins-") {
      assert.eq(reg.styles.padding, (left: 5pt, right: 5pt, top: -2pt, bottom: -2pt))
    }
    let active = _deixis-pins-for(pins, reg.pins)
    let box = boxes.find(b => b.value.name == name)
    let bounds = _deixis-region-bounds(active, box.location().page(), padding: reg.styles.padding)
    let pos = box.location().position()
    for delta in (pos.x - bounds.left, pos.y - bounds.top,
      box.value.width - (bounds.right - bounds.left), box.value.height - (bounds.bottom - bounds.top)) {
      assert(calc.abs(delta) < 0.001pt)
    }
  }
}
