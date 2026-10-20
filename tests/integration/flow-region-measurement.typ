#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#import "../../src/core/query.typ": _deixis-pin-index, _deixis-pins-for
#set page(width: 540pt, height: 380pt, margin: (x: 110pt, y: 50pt))
#show: deixis-setup-notes
#let ticks = state("flow-region-live-bodies", 0)
#let cases = ()
#let container(body, case: none, ..args) = block(width: 100%, above: 0pt, below: 0pt, {
  place(top + left, [#metadata((case: case, corner: "top"))<flow-measure-container>])
  place(bottom + right, [#metadata((case: case, corner: "bottom"))<flow-measure-container>])
  body
})
#let custom(data, ..options) = deixis-native-render-single(data, ..options.named())
#let shape(name, ..options) = {
  let o = options.named()
  box(width: o.width, height: o.height, {
    place(top + left, [#metadata((case: name, width: o.width, height: o.height))<flow-measure-shape>])
    deixis-rect-region(..o)
  })
}
#for kind in ("margin", "inset", "footnote") {
  for layer in ("flow", "foreground", "background") {
    for form in ("anonymous", "repeat") {
      for inline in (true, false) {
        if cases.len() > 0 { pagebreak() }
        let name = kind + "-" + layer + "-" + form + "-" + repr(inline)
        cases.push(name)
        let renderer = (deixis-native-render-single, deixis-default-render-single, custom).at(calc.rem(cases.len(), 3))
        let region = deixis-region-mark.with(layer: "flow", inline: inline, padding: 2pt,
          region-shape: shape.with(name), marker: none)
        let atom = [#ticks.update(n => n + 1)#box(width: 28pt, height: 14pt)]
        let marked = if form == "repeat" { region(of: name, occurrence: <inside>)[#atom] }
          else { region[#atom] }
        let body = [
          Before the region.
          #marked
          After the region.
        ]
        deixis-inline-mark(id: name)[Original]
        if kind == "margin" {
          deixis-margin-note-body(of: name, layer: layer, width: 95pt, side: right,
            container-func: container, container-args: (case: name), render-single: renderer, backlink: true)[#body]
        } else if kind == "inset" {
          deixis-inset-note-body(of: name, layer: layer, width: 105pt, dx: 145pt, dy: 110pt,
            container-func: container, container-args: (case: name), render-single: renderer, backlink: true)[#body]
        } else {
          deixis-footnote-body(of: name, layer: layer,
            container-func: container, container-args: (case: name), render-single: renderer, backlink: true)[#body]
        }
        [.]
      }
    }
  }
}
// Counts must converge during compilation: anonymous regions once oscillated
// when their native identity depended on per-pass registry payloads.
#context {
  assert.eq(query(<flow-measure-shape>).len(), cases.len())
  assert.eq(query(<flow-measure-container>).len(), 2 * cases.len())
  assert.eq(query(<deixis-rendered-start>).len(), cases.len())
}
// Verify after layout. Inline flow regions inside flow margin bodies settle one
// pass after their pins, so a compile-time position query needs a sixth pass.
#let verify() = {
  assert.eq(cases.len(), 36)
  assert.eq(ticks.final(), cases.len())
  assert.eq(query(<deixis-rendered-start>).len(), cases.len())
  assert.eq(query(<deixis-region-mark>).len(), 18)
  assert.eq(query(<deixis-region-occurrence>).len(), 18)
  let shapes = query(<flow-measure-shape>)
  assert.eq(shapes.len(), cases.len())
  let containers = query(<flow-measure-container>)
  assert.eq(containers.len(), 2 * cases.len())
  let index = _deixis-pin-index()
  for region in query(selector(<deixis-region-mark>).or(<deixis-region-occurrence>)) {
    let data = region.value
    let pins = _deixis-pins-for(index, data.pins)
    assert.eq(pins.len(), 4)
    let page = pins.first().location().page()
    let shape = shapes.find(s => s.location().page() == page)
    // Single-page bounds from absolute pin paddings; eval has no measure context.
    assert.eq(data.styles.padding, 0pt)
    let edges = pins.map(p => (pos: p.location().position(), pad: p.value.padding))
    let bounds = (left: calc.min(..edges.map(e => e.pos.x - e.pad.left)),
      top: calc.min(..edges.map(e => e.pos.y - e.pad.top)),
      right: calc.max(..edges.map(e => e.pos.x + e.pad.right)),
      bottom: calc.max(..edges.map(e => e.pos.y + e.pad.bottom)))
    assert(calc.abs(shape.location().position().x - bounds.left) < 0.001pt)
    assert(calc.abs(shape.location().position().y - bounds.top) < 0.001pt)
    assert(calc.abs(shape.value.width - (bounds.right - bounds.left)) < 0.001pt)
    assert(calc.abs(shape.value.height - (bounds.bottom - bounds.top)) < 0.001pt)
  }
  let sys = deixis-system.final()
  for name in cases {
    let top = containers.find(c => c.value.case == name and c.value.corner == "top").location()
    let bottom = containers.find(c => c.value.case == name and c.value.corner == "bottom").location()
    assert.eq(top.page(), bottom.page())
    let height = bottom.position().y - top.position().y
    assert(height > 0pt)
    let uid = sys.registry.value.id-index.at(name)
    if name.starts-with("margin-") {
      let frame = query(<deixis-body-frame>).find(f => f.value.identity == uid).value.node
      assert(calc.abs(frame.bounds.bottom - frame.bounds.top - height) < 0.001pt,
        message: "Measured margin height differs from live body: " + name)
    }
    if name.starts-with("footnote-") and not name.starts-with("footnote-flow") {
      let reservation = query(<deixis-reserver-left>).find(p => str(p.value.internal-id) == uid)
      assert(calc.abs(reservation.value.reserved-height - height) < 0.001pt,
        message: "Reserved footer height differs from live body: " + name)
    }
  }
}
