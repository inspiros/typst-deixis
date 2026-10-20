#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#set page(width: 530pt, height: 420pt, margin: (left: 40pt, right: 140pt, y: 30pt))
#show: deixis-setup-notes
#deixis-set(palette: (blue, orange))
#deixis-mark(id: <explicit>, stroke: red, fill: none, marker-style: it => sub(it))[Explicit]
#deixis-margin-note-body(of: <explicit>, width: 100pt, connector: none)[Body]
#deixis-set(stroke: (inline-mark: green, margin-note: (body: purple)),
  fill: (inline-mark: none), marker-style: (inline-mark: it => it))
#deixis-mark(id: <scoped>)[Scoped Style]
#deixis-margin-note-body(of: <scoped>, width: 100pt)[Scoped Body]
#let paint(expected, r) = {
 assert.eq(if r.stroke == none { none } else { r.stroke.paint }, expected)
 [#metadata(expected)<palette-edge-style>]
 deixis-render-connector(r)
}
#deixis-connect(from: <explicit>, to: <scoped>, connector: (render: paint.with(orange)))
#deixis-connect(from: <scoped>, to: <explicit>, connector: (stroke: aqua, render: paint.with(aqua)))
#deixis-set(stroke: (connection: gray))
#deixis-connect(from: <explicit>, to: <scoped>, connector: (render: paint.with(gray)))
#deixis-connect(from: <explicit>, to: <scoped>, connector: (stroke: none, render: paint.with(none)))
#let verify() = {
 let registry = deixis-system.final()
 assert.eq(registry.palette-counts.values().sum(), 2)
 let original = registry.registry.value.notes.at("id-explicit")
 assert.eq(original.accent, blue)
 assert.eq(original.mark-styles.stroke.paint, red)
 assert.eq(original.mark-styles.fill, none)
 assert.eq((original.marker-style)([1]), sub([1]))
 let scoped = registry.registry.value.notes.at("id-scoped")
 assert.eq(scoped.accent, orange)
 assert.eq(scoped.mark-styles.stroke.paint, green)
 assert.eq(scoped.mark-styles.fill, none)
 assert.eq((scoped.marker-style)([1]), [1])
 let bodies = query(<deixis-margin-note>).map(n => n.value)
 assert.eq(bodies.map(n => n.styles.stroke.paint), (red, purple))
 assert.eq(query(<palette-edge-style>).map(n=>n.value), (orange, aqua, gray, none))
 true
}
