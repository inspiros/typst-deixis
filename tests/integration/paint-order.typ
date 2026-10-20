#import "../../src/lib.typ": *
#let live = state("paint-order-live", 0)
#let swatch(name, color) = [
  #metadata(name)<paint-order-event>
  #deixis-absolute-place(dx: 220pt, dy: 170pt,
    rect(width: 45pt, height: 45pt, fill: color, stroke: none, inset: 0pt))
]
#set page(width: 560pt, height: 440pt, margin: (x: 110pt, y: 40pt),
  background: context swatch("native-background", rgb("101010")),
  foreground: context swatch("native-foreground", rgb("91a1b1")),
)
#show: deixis-setup-notes.with(
  background: context swatch("user-background", rgb("202020")),
  foreground: context swatch("user-foreground", rgb("8191a1")),
)
#let body-render(name, color, data, ..args) = {
  if not data.at("disable-links", default: false) { swatch(name, color) }
  deixis-native-render-single(data, ..args.named())
}
#let edge(name, color, request) = swatch(name, color)
#let shape(..args) = swatch("region", rgb("314151"))
#let group(notes, ..args) = {
  [#metadata(notes.map(n => n.id))<paint-order-group>]
  swatch("footnote-group", rgb("506070"))
  deixis-native-render-group(notes, ..args.named())
}
#deixis-set(render-group: (footnote: group))
#for (i, layer) in ("background", "foreground").enumerate() {
  if i > 0 { pagebreak() }
  // Reverse body/type declaration order deliberately. Paint remains phased.
  deixis-margin-note(id: "margin-" + layer, layer: layer, side: right, width: 80pt,
    marker: none, stroke: none, fill: none,
    render-single: body-render.with("margin", rgb("718191")),
    connector: (route: "straight-line", layer: layer,
      render: edge.with("margin-edge", rgb("415161"))),
  )[Margin][#live.update(n => n + 1)Margin body.]
  deixis-inset-note(id: "inset-" + layer, layer: layer, width: 80pt, dx: 80pt, dy: 75pt,
    marker: none, stroke: none, fill: none,
    render-single: body-render.with("inset", rgb("617181")),
    connector: (route: "straight-line", layer: layer,
      render: edge.with("inset-edge", rgb("425262"))),
  )[Inset][#live.update(n => n + 1)Inset body.]
  [Footnote#deixis-footnote(id: "foot-a-" + layer, layer: layer,
    render-single: body-render.with("foot-a", rgb("516171")),
  )[#live.update(n => n + 1)First footnote.].]
  [Footnote#deixis-footnote(id: "foot-b-" + layer, layer: layer,
    render-single: body-render.with("foot-b", rgb("526272")),
  )[#live.update(n => n + 1)Second footnote.].]
  deixis-region-mark(id: "region-" + layer, layer: layer, inline: true,
    region-shape: shape, marker-style: it => text(fill: rgb("a2b2c2"), it),
  )[Region passage]
  deixis-connect(from: "margin-" + layer, to: "inset-" + layer,
    connector: (route: "straight-line", layer: layer,
      render: edge.with("explicit-edge", rgb("435363"))))
  swatch("native-flow", rgb("a1b1c1"))
  [Native flow.]
}
#pagebreak()
#let custom-margin(notes, ..args) = {
  [#metadata(notes.map(n => n.note-data.id))<paint-order-custom-group>]
  swatch("custom-before", rgb("b1c1d1"))
  deixis-margin-note-exact-layout(notes, ..args)
  swatch("custom-after", rgb("b2c2d2"))
}
#deixis-set(margin-layout: custom-margin)
#swatch("native-flow", rgb("a1b1c1"))
#deixis-margin-note(id: "custom-a", layer: "foreground", side: right, width: 80pt,
  render-single: body-render.with("custom-a", rgb("b3c3d3")),
)[#live.update(n => n + 1)Custom A.]
Following text.
#v(45pt)
#deixis-margin-note(id: "custom-b", layer: "foreground", side: right, width: 80pt,
  render-single: body-render.with("custom-b", rgb("b4c4d4")),
)[#live.update(n => n + 1)Custom B.]
Following text.
#context {
  assert.eq(live.final(), 10)
  assert.eq(query(<deixis-rendered-start>).len(), 10)
  let groups = query(<paint-order-group>).map(m => m.value)
  assert.eq(groups, (("foot-a-background", "foot-b-background"), ("foot-a-foreground", "foot-b-foreground")))
  assert.eq(query(<paint-order-custom-group>).map(m => m.value), (("custom-a", "custom-b"),))
  for p in (1, 2) {
    let names = query(<paint-order-event>).filter(m => m.location().page() == p).map(m => m.value)
    for name in ("native-background", "user-background", "region", "margin-edge", "inset-edge",
      "explicit-edge", "footnote-group", "foot-a", "foot-b", "inset", "margin",
      "native-flow", "user-foreground", "native-foreground") {
      assert.eq(names.filter(n => n == name).len(), 1)
    }
  }
}
