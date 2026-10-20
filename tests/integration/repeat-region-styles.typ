#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#set page(width: 530pt, height: 420pt, margin: 55pt)
#show: deixis-setup-notes
#let ticks = state("repeat-region-style-ticks", 0)
#let shape(name, ..args) = {
  let a = args.named()
  box(width: a.width, height: a.height, {
    place(top + left, [#metadata((name: name, width: a.width, height: a.height, stroke: a.stroke, radius: a.radius))<reuse-shape>])
    deixis-rect-region(..a)
  })
}
#let marker(it) = [M#it]
#deixis-region-mark(id: <owner>, inline: true, stroke: blue, fill: yellow, padding: 4pt,
  radius: 5pt, region-shape: shape.with("inherited"), layer: "background", marker-style: marker)[$x$]
#deixis-endnote-body(of: <owner>)[#ticks.update(n => n + 1)One shared body.]
#deixis-set(stroke: purple, fill: purple.lighten(80%), layer: (region-mark: "foreground"), region-shape: shape.with("new-default"))

#deixis-region-mark(of: <owner>, inline: true)[$y$]
#deixis-mark(of: <owner>, mark-type: "region", inline: true,
  stroke: (body: red), marker-style: (body: it => panic("body style on region reuse")))[$z$]
#deixis-region-mark(of: <owner>, inline: true, occurrence: <override>, layer: "foreground",
  stroke: (mark: teal, body: red), fill: none, padding: 8pt, region-shape: shape.with("local"),
  marker-style: (mark: it => [R#it], body: it => panic("body marker on region reuse")))[$w$]
#deixis-print-endnotes()
#context {
  let repeats = query(<deixis-region-occurrence>).map(r => r.value)
  assert.eq(repeats.len(), 3)
  for r in repeats.slice(0, 2) {
    assert.eq(r.layer, "background")
    assert.eq(r.styles.stroke.paint, blue)
    assert.eq(r.styles.fill, yellow)
    assert.eq(r.styles.radius, 5pt)
    assert.eq((r.marker-style)("1"), marker("1"))
  }
  assert.eq(repeats.last().styles.stroke.paint, teal)
  assert.eq((repeats.last().marker-style)("1"), [R#str("1")])
  assert.eq(query(<reuse-shape>).map(s => s.value.name).sorted(), ("inherited", "inherited", "inherited", "local"))
  assert.eq(ticks.final(), 1)
  assert.eq(deixis-system.final().registry.value.notes.len(), 1)
}
