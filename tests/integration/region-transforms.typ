#import "../../src/lib.typ": *
#set page(width: 530pt, height: 480pt, margin: 50pt)
#show: deixis-setup-notes
#let ticks = state("transform-body-count", 0)
#let atom(name) = box(width: 90pt, height: 30pt, fill: luma(230), {
  for (corner, align) in (("tl", top + left), ("tr", top + right), ("bl", bottom + left), ("br", bottom + right)) {
    place(align, [#metadata((name: name, corner: corner))<native-transform-corner>])
  }
  ticks.update(n => n + 1)
  [#name]
})
#let shape(name, ..args) = {
  let a = args.named()
  box(width: a.width, height: a.height, {
    place(top + left, [#metadata((name: name, width: a.width, height: a.height))<transformed-region>])
    rect(width: 100%, height: 100%, stroke: blue)
  })
}
#let region(name, layer) = deixis-region-mark(id: name, inline: true, layer: layer, padding: 0pt,
  region-shape: shape.with(name), atom(name))
#let transforms = (
  ("move", body => move(dx: 15pt, dy: 7pt, body)),
  ("scale", body => scale(x: 145%, y: 75%, reflow: true, body)),
  ("rotate", body => rotate(22deg, reflow: true, body)),
  ("reverse", body => rotate(-32deg, reflow: true, body)),
  ("quarter", body => rotate(90deg, reflow: true, body)),
)
#let connector(name, request) = {
  [#metadata((name: name, bounds: request.route.document.nodes.mark.bounds))<transformed-route>]
  for segment in request.shaft {
    place(top + left, line(start: segment.start, end: segment.end, stroke: request.stroke))
  }
}
#for (i, layer) in ("foreground", "background").enumerate() {
  if i > 0 { pagebreak() }
  grid(columns: (1fr, 1fr), gutter: 45pt, ..transforms.map(((name, transform)) => {
    transform(region(name + layer, layer))
  }))
  deixis-inset-note-body(of: "rotate" + layer, layer: layer, width: 70pt,
    dx: 70pt, dy: 15pt, connector: (route: "straight-line", ports: (right, left),
      render: connector.with("rotate" + layer)))[Rotated source.]
}
#pagebreak()
// Flow regions enclose a transformed native box when the transform is inside.
#grid(columns: (1fr, 1fr), gutter: 40pt, ..transforms.slice(1).map(((name, transform)) => {
  deixis-region-mark(inline: true, layer: "flow", padding: 0pt,
    region-shape: shape.with(name + "flow"), transform(atom(name + "flow")))
}))
#context {
  assert.eq(ticks.final(), 14)
  assert.eq(query(<deixis-pin>).len(), 56)
  let shapes = query(<transformed-region>)
  assert.eq(shapes.len(), 14)
  let routes = query(<transformed-route>)
  assert.eq(routes.len(), 2)
  // Overlay corners are independently transformed by native Typst. The painted
  // envelope must contain all four, including 90-degree axis reversals.
  for shape in shapes {
    let corners = query(<native-transform-corner>).filter(c => c.value.name == shape.value.name)
    let points = corners.map(c => c.location().position())
    let left = calc.min(..points.map(p => p.x))
    let top = calc.min(..points.map(p => p.y))
    let right = calc.max(..points.map(p => p.x))
    let bottom = calc.max(..points.map(p => p.y))
    let pos = shape.location().position()
    for delta in (pos.x - left, pos.y - top, shape.value.width - (right - left), shape.value.height - (bottom - top)) {
      assert(calc.abs(delta) < 0.001pt, message: shape.value.name)
    }
    let route = routes.find(r => r.value.name == shape.value.name)
    if route != none {
      let bounds = route.value.bounds
      for delta in (bounds.left - left, bounds.top - top, bounds.right - right, bounds.bottom - bottom) {
        assert(calc.abs(delta) < 0.001pt)
      }
    }
  }
}
