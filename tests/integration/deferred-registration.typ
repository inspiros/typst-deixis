#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#import "../../src/core/query.typ": _deixis-pin-index, _deixis-pins-for
#import "../../src/layout/geometry.typ": _deixis-region-bounds
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
    for form in ("original",) {
      for inline in (true, false) {
        if cases.len() > 0 { pagebreak() }
        let name = kind + "-" + layer + "-" + form + "-" + repr(inline)
        cases.push(name)
        let renderer = (deixis-native-render-single, deixis-default-render-single, custom).at(calc.rem(cases.len(), 3))
        let region = deixis-region-mark.with(layer: "flow", inline: inline, padding: 2pt,
          region-shape: shape.with(name), marker: if sys.inputs.at("inner-marker", default: "none") == "auto" { auto } else { none })
        let atom = [#ticks.update(n => n + 1)#box(width: 28pt, height: 14pt)]
        let marked = if form == "original" { region(id: "region-" + name)[#atom] }
          else if form == "repeat" { region(of: name, occurrence: <inside>)[#atom] }
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

// New originals share the same counter: rendering must not renumber an earlier
// body's identity, replay its effects, or lose a native destination.
#context {
  let registry = deixis-system.final()
  assert.eq(cases.len(), 18)
  assert.eq(ticks.final(), 18)
  assert.eq(registry.registry.value.notes.len(), 36)
  assert.eq(registry.registry.value.note-uid, 36)
  assert.eq(registry.registry.value.counters.at("page").at("default"), 36)
  assert.eq(query(<deixis-rendered-start>).len(), 18)
  assert.eq(query(<deixis-region-mark>).len(), 18)
  assert.eq(query(<flow-measure-shape>).len(), 18)
  let starts = query(<deixis-rendered-start>)
  let containers = query(<flow-measure-container>)
  let destinations = ()
  for (i, name) in cases.enumerate() {
    let uid = registry.registry.value.id-index.at(name)
    let nested = registry.registry.value.id-index.at("region-" + name)
    assert.eq(registry.registry.value.notes.at(uid).count, 2 * i + 1)
    assert.eq(registry.registry.value.notes.at(nested).count, 2 * i + 2)
    assert.eq(starts.find(s => str(s.value.internal-id) == uid).value.count, 2 * i + 1)
    for prefix in ("deixis-mark-", "deixis-body-") {
      let elements = query(std.label(prefix + uid))
      assert.eq(elements.len(), 1)
      let pos = elements.first().location().position()
      assert.eq(pos.page, i + 1)
      destinations.push((page: pos.page, x: pos.x.pt(), y: pos.y.pt()))
    }
    let top = containers.find(c => c.value.case == name and c.value.corner == "top").location()
    let bottom = containers.find(c => c.value.case == name and c.value.corner == "bottom").location()
    assert.eq(top.page(), bottom.page())
    let height = bottom.position().y - top.position().y
    assert(height > 0pt)
    if name.starts-with("margin-") {
      let frame = query(<deixis-body-frame>).find(f => f.value.identity == uid).value.node
      assert(calc.abs(frame.bounds.bottom - frame.bounds.top - height) < 0.001pt)
    }
    if name.starts-with("footnote-") and not name.starts-with("footnote-flow") {
      let reservation = query(<deixis-reserver-left>).find(p => str(p.value.internal-id) == uid)
      assert(calc.abs(reservation.value.reserved-height - height) < 0.001pt)
    }
  }
  [#metadata((destinations: destinations))<test-result>]
}
