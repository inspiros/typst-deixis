#import "../../src/lib.typ": *
#let live = state("z-groups-live", 0)
#let swatch(name, color) = [#metadata(name)<z-group-paint>
  #deixis-absolute-place(dx: 220pt, dy: 160pt, rect(width: 40pt, height: 40pt, fill: color, stroke: none))]
#let render(name, color, data, ..args) = {
  if not data.at("disable-links", default: false) { swatch(name, color) }
  deixis-native-render-single(data, ..args.named())
}
#let group(notes, ..args) = {
  [#metadata(notes.map(n => str(n.id)))<z-group-members>]
  if notes.len() == 2 { swatch("foot-decoration", rgb("222222")) }
  deixis-native-render-group(notes, ..args.named())
}
#set page(width: 560pt, height: 420pt, margin: (x: 105pt, y: 40pt))
// Footnote columns are overlay groups; make overlays the default footnote layer.
#show: deixis-setup-notes.with(override-page-footnotes: true)
#deixis-set(render-group: (footnote: group), margin-layout: "exact")
First#deixis-footnote(id: "foot-a", z-index: 3,
  render-single: render.with("foot-a", rgb("232323")),
)[#live.update(n => n + 1)First footnote.].
Second#deixis-footnote(id: "foot-b", z-index: 3,
  render-single: render.with("foot-b", rgb("242424")),
)[#live.update(n => n + 1)Second footnote.].
#deixis-margin-note(id: "margin", z-index: 0,
  render-single: render.with("margin", rgb("111111")), width: 80pt,
)[#live.update(n => n + 1)Margin below the whole footnote group.]
#pagebreak()
#let custom(notes, ..args) = {
  [#metadata(notes.map(n => str(n.note-data.id)))<z-custom-members>]
  swatch("before", rgb("313131"))
  deixis-margin-note-exact-layout(notes, ..args)
  swatch("after", rgb("343434"))
}
#deixis-set(margin-layout: custom)
#deixis-margin-note(id: "custom-a", z-index: -2, width: 80pt,
  render-single: render.with("custom-a", rgb("323232")),
)[#live.update(n => n + 1)Custom A.]
Following text.
#v(35pt)
#deixis-margin-note(id: "custom-b", z-index: -2, width: 80pt,
  render-single: render.with("custom-b", rgb("333333")),
)[#live.update(n => n + 1)Custom B.]
Following text.
#deixis-inset-note(id: "above-custom", layer: "foreground", width: 80pt,
  dx: 60pt, dy: 60pt, z-index: 0,
  render-single: render.with("inset", rgb("353535")),
)[#live.update(n => n + 1)Above the entire custom batch.]
#pagebreak()
#deixis-set(margin-layout: "exact")
// Native page footnotes from these source columns share one footer column.
// Foreground members agree; background is a separate atomic layer group.
#columns(2, gutter: 20pt)[
  Left#deixis-footnote(id: "left", z-index: 2,
    render-single: render.with("left", rgb("424242")),
  )[#live.update(n => n + 1)Left column.].
  Background#deixis-footnote(id: "background", layer: "background", z-index: 999,
    render-single: render.with("background", rgb("414141")),
  )[#live.update(n => n + 1)Background in the same column.].
  #colbreak()
  Right#deixis-footnote(id: "right", z-index: 2,
    render-single: render.with("right", rgb("444444")),
  )[#live.update(n => n + 1)Right column.].
]
#deixis-inset-note(id: "column-inset", layer: "foreground", width: 65pt,
  dx: 55pt, dy: 50pt, z-index: 0,
  render-single: render.with("column-inset", rgb("434343")),
)[#live.update(n => n + 1)Below the foreground footer group.]
#context {
  assert.eq(live.final(), 10)
  assert.eq(query(<deixis-rendered-start>).len(), 10)
  assert.eq(query(<z-custom-members>).map(m => m.value), (("custom-a", "custom-b"),))
  assert(query(<z-group-members>).map(m => m.value).contains(("foot-a", "foot-b")))
}
