#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#set page(width: 530pt, height: 330pt, margin: (left: 55pt, right: 130pt, y: 35pt))
#set text(size: 10pt)
#show: deixis-setup-notes
#let kind = sys.inputs.at("kind", default: "margin")
#let mark = sys.inputs.at("mark", default: "inline")
#let layer = sys.inputs.at("layer", default: "foreground")
#let live = state("palette-live", 0)
#let orders = (("original", "body", "reuse"), ("original", "reuse", "body"),
  ("body", "original", "reuse"), ("body", "reuse", "original"),
  ("reuse", "original", "body"), ("reuse", "body", "original"))
#let renderer(data, ..args) = {
  assert.eq(data.accent, blue)
  assert.eq(data.styles.stroke.paint, blue)
  assert.eq(data.styles.fill, none)
  assert.eq((data.body-marker-style)([1]), text(fill: blue, if kind == "endnote" { [1] } else { super([1]) }))
  deixis-native-render-single(data, ..args.named())
}
#let body(id) = {
  let content = [#live.update(n => n + 1)#context assert.eq(text.fill, black)Body]
  if kind == "margin" { deixis-margin-note-body(of: id, width: 90pt, side: right, layer: layer, render-single: renderer, content) }
  else if kind == "inset" { deixis-inset-note-body(of: id, width: 90pt, layer: layer, dx: 170pt, dy: 70pt, render-single: renderer, content) }
  else if kind == "inline" { deixis-inline-note-body(of: id, render-single: renderer, content) }
  else if kind == "footnote" { deixis-footnote-body(of: id, layer: layer, render-single: renderer, content) }
  else { deixis-endnote-body(of: id, render-single: renderer, content) }
}
#for (i, order) in orders.enumerate() {
  if i > 0 { pagebreak() }
  deixis-set(palette: (blue, orange))
  let id = "case" + str(i)
  for op in order {
    if op == "original" {
      if mark == "region" { deixis-mark(id: id, mark-type: "region", inline: true)[Original] }
      else if mark == "phantom" { deixis-mark(id: id, mark-type: "phantom") }
      else { deixis-mark(id: id)[Original] }
    } else if op == "body" { body(id); [Native Footer Anchor.] }
    else {
      deixis-mark(of: id)[Reuse]
      deixis-mark(of: id, mark-type: "region", inline: true)[Region Reuse]
      [Reference #deixis-ref(label(id)).]
    }
  }
  deixis-mark(id: "next" + str(i))[Next]
  if kind == "endnote" { deixis-print-endnotes() }
}
#context [#metadata(deixis-query-notes(include-unpaired: true).filter(n => n.body != none).map(n => n.accent))<palette-query>]
#let verify() = {
  assert.eq(live.final(), 6)
  let registry = deixis-system.final()
  assert.eq(registry.registry.value.notes.len(), 12)
  assert.eq(registry.at("annotation-accent", default: none), none)
  for i in range(6) {
    let original = registry.registry.value.notes.at("id-case" + str(i))
    assert.eq(original.accent, blue)
    assert.eq(registry.registry.value.notes.at("id-next" + str(i)).accent, orange)
    if mark != "phantom" { assert.eq(original.mark-styles.stroke.paint, blue) }
  }
  assert.eq(query(<palette-query>).first().value, (blue,) * 6)
  true
}
