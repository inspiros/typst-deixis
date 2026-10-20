#import "../../src/lib.typ": *
#set page(width: 510pt, height: 390pt, margin: 60pt)
#show: deixis-setup-notes
#let ticks = state("regions-in-notes", 0)
#let panel(body, ..args) = rect(inset: 6pt, radius: 3pt, stroke: gray, body)
#let shape(name, ..args) = {
  let a = args.named()
  box(width: a.width, height: a.height, {
    place(top + left, [#metadata((name: name, width: a.width, height: a.height))<nested-note-region>])
    rect(width: 100%, height: 100%, stroke: blue)
  })
}
#let body(name) = [
  An annotated body:
  #deixis-region-mark(inline: true, layer: "foreground", padding: 3pt, region-shape: shape.with(name))[
    #box(width: 90pt, height: 22pt, {
      ticks.update(n => n + 1)
      place(top + left, [#metadata((name: name, edge: "top"))<annotated-atom>])
      place(bottom + right, [#metadata((name: name, edge: "bottom"))<annotated-atom>])
      align(center + horizon, $x^2 + y^2$)
    })
  ].
]
#for (i, layer) in ("foreground", "background", "flow").enumerate() {
  if i > 0 { pagebreak() }
  [Footnote#deixis-footnote(layer: layer, container-func: panel, id: label(layer + "-footnote"), body(layer + "-footnote")).]
  [Inset#deixis-inset-note(layer: layer, container-func: panel, width: 130pt, dx: 170pt, dy: 70pt,
    id: label(layer + "-inset"), body(layer + "-inset")).]
  [Endnote#deixis-endnote(container-func: panel, id: label(layer + "-endnote"), body(layer + "-endnote")).]
  deixis-print-endnotes(render-group: deixis-grid-render-group)
}
#context {
  assert.eq(ticks.final(), 9)
  let regions = query(<deixis-region-mark>)
  let shapes = query(<nested-note-region>)
  assert.eq(regions.len(), 9)
  assert.eq(shapes.len(), 9)
  assert.eq(shapes.map(s => s.value.name).dedup().len(), 9)
}
