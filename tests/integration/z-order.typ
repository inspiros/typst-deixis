#import "../../src/lib.typ": *
#let enabled = sys.inputs.at("priority", default: "on") == "on"
#let z(n) = if enabled { n } else { 0 }
#let live = state("z-order-live", ())
#let swatch(name, color) = [
  #metadata(name)<z-paint>
  #deixis-absolute-place(dx: 230pt, dy: 170pt,
    rect(width: 44pt, height: 44pt, fill: color, stroke: none))
]
#let render(name, color, data, ..args) = {
  if not data.at("disable-links", default: false) { swatch(name, color) }
  deixis-native-render-single(data, ..args.named())
}
#let edge(name, color, request) = {
  [#metadata((name: name, priority: request.route.document.z-index,
    page: request.route.document.page))<z-edge>]
  swatch(name, color)
}
#set page(width: 560pt, height: 440pt, margin: (x: 110pt, y: 40pt),
  background: context swatch("native-bg", rgb("101010")),
  foreground: context swatch("native-fg", rgb("919191")),
)
#show: deixis-setup-notes.with(
  background: context swatch("user-bg", rgb("202020")),
  foreground: context swatch("user-fg", rgb("818181")),
)
#deixis-set(margin-layout: "exact")
#for (i, layer) in ("background", "foreground").enumerate() {
  if i > 0 { pagebreak() }
  let inset = "inset-" + layer
  let margin = "margin-" + layer
  // Different priorities override adapter order. Equal-priority insets keep
  // source order. Margin body inherits the default 0, while its edge is raised.
  deixis-inset-note(id: inset, layer: layer, width: 80pt, dx: 70pt, dy: 65pt,
    z-index: z(2), marker: none,
    render-single: render.with("inset", rgb("626262")),
    connector: (route: "straight-line", layer: layer, z-index: z(-3),
      render: edge.with("inset-edge", rgb("313131"))),
  )[Passage][#live.update(v => v + (inset,))Inset.]
  deixis-inset-note(layer: layer, width: 65pt, dx: 145pt, dy: 85pt,
    z-index: (body: z(2), connector: z(6)), marker: none,
    render-single: render.with("tie", rgb("636363")), connector: none,
  )[Another][#live.update(v => v + ("tie-" + layer,))Equal priority.]
  deixis-margin-note(id: margin, layer: layer, side: right, width: 80pt,
    marker: none, z-index: (body: z(0), connector: z(3)),
    render-single: render.with("margin", rgb("515151")),
    connector: (route: "straight-line", layer: layer,
      render: edge.with("margin-edge", rgb("717171"))),
  )[Margin][#live.update(v => v + (margin,))Margin.]
  // Footnote column is a whole unit at priority -1.
  [Footnote#deixis-footnote(id: "foot-" + layer, layer: layer, z-index: z(-1),
    render-single: render.with("foot", rgb("414141")),
  )[#live.update(v => v + ("foot-" + layer,))Footnote.].]
  deixis-region-mark(id: "region-" + layer, layer: layer, inline: true,
    z-index: z(1), marker: none,
    region-shape: (..args) => swatch("region", rgb("616161")),
  )[Region]
  deixis-connect(from: margin, to: inset,
    connector: (route: "straight-line", layer: layer, z-index: z(4),
      render: edge.with("explicit", rgb("727272"))))
  swatch("flow", rgb("a1a1a1"))
  [Native flow.]
}
#context {
  assert.eq(live.final().len(), 8)
  assert.eq(query(<deixis-rendered-start>).len(), 8)
}
