#import "../../src/lib.typ": *
#set page(width: 500pt, height: 350pt, margin: (x: 100pt, y: 40pt))
#show: deixis-setup-notes
#deixis-set(margin-layout: "exact")

#let probe(data, ..args) = box(width: 100%, height: 25pt, {
  if not data.at("disable-links", default: false) {
    place(top + left, [#metadata((id: data.id, marker-width: data.at("marker-width", default: 0pt),
      mark-lbl: data.mark-lbl, pins: data.at("r-pins", default: ()).len()))<margin-anchor-body>])
  }
  deixis-native-render-single(data, ..args.named())
})

#deixis-inline-mark(id: <inline>)[A wide marked phrase]
#deixis-margin-note-body(of: <inline>, render-single: probe)[Inline anchor.]
#v(25pt)
#deixis-phantom-mark(id: <phantom>)Phantom anchor.
#deixis-margin-note-body(of: <phantom>, render-single: probe)[Phantom anchor.]
#v(25pt)
#deixis-pin("shared-anchor")First named anchor.
#v(25pt)
#deixis-pin("region-pins")Region begins.
#v(25pt)
#deixis-pin("region-pins")Another region pin.
#deixis-margin-note(mark-type: "region", pins: ("region-pins",),
  mark-align: (mark: bottom, body: top), id: <region-body>, render-single: probe)[Region bottom.]
#pagebreak()
Region ends.#deixis-pin("region-pins")
#v(25pt)
#deixis-pin("shared-anchor")Second occurrence of the named anchor.
// The declared body is on page two; its explicit anchor is the first occurrence
// on page one. A repeated region pin name, however, retains every occurrence.
#deixis-margin-note-body(anchor-pin: "shared-anchor", id: <pin-body>, render-single: probe)[First pin.]

#context {
  let bodies = query(<margin-anchor-body>)
  assert.eq(bodies.len(), 4)
  let at-anchor(body, loc) = {
    assert.eq(body.location().page(), loc.page())
    assert(calc.abs(body.location().position().y - loc.position().y) < 0.01pt)
  }
  for body-label in (<inline>, <phantom>) {
    let body = bodies.find(n => n.value.id == body-label)
    let mark = query(body.value.mark-lbl).first()
    at-anchor(body, mark.location())
    let marks = query(selector(<deixis-inline-mark>).or(<deixis-phantom-mark>))
    let source = marks.find(n => n.value.mark-lbl == body.value.mark-lbl)
    assert.eq(body.value.marker-width, source.value.marker-width)
  }
  let region = bodies.find(n => n.value.id == <region-body>)
  assert.eq(region.value.pins, 3)
  let region-pins = query(<deixis-pin>).filter(n => n.value.name == "region-pins")
  at-anchor(region, region-pins.last().location())
  let pinned = bodies.find(n => n.value.id == <pin-body>)
  at-anchor(pinned, query(<deixis-pin>).find(n => n.value.name == "shared-anchor").location())
}
