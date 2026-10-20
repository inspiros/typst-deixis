#import "../../src/lib.typ": *
#set page(width: 560pt, height: 450pt, margin: (x: 110pt, y: 40pt))
#show: deixis-setup-notes
#let live = state("native-style-bodies", 0)
#let edge = (left: blue + 2pt, top: red, rest: none)
#let expected = ()
#let checked(body, ..args) = {
  let stroke = args.named().stroke
  assert.eq(stroke.left.paint, blue)
  assert.eq(stroke.left.thickness, 2pt)
  assert.eq(stroke.top.paint, red)
  assert.eq(stroke.top.thickness, 1pt)
  assert.eq(stroke.right, none)
  rect(body, ..args.named())
}
#for (i, kind) in ("inline", "footnote", "endnote", "margin", "inset").enumerate() {
  for (j, layer) in ("flow", "background", "foreground").enumerate() {
    if kind in ("inline", "endnote") and j > 0 { continue }
    if i > 0 or j > 0 { pagebreak() }
    let id = kind + "-" + layer
    let body = [#live.update(n => n + 1)Rectangular native edges.]
    let args = (id: id, stroke: (mark: purple, body: edge, connector: black),
      radius: (mark: 0pt, body: (top: 4pt, bottom: 7pt), connector: 0pt), container-func: checked)
    if kind == "inline" {
      deixis-inline-mark(id: id)[Original]
      deixis-inline-note-body(of: id, stroke: edge, radius: (top: 4pt,), container-func: checked, body)
    } else if kind == "footnote" { [Anchor#deixis-footnote(..args, layer: layer, body).] }
    else if kind == "endnote" { [Anchor#deixis-endnote(..args, body).] }
    else if kind == "margin" { deixis-margin-note(..args, layer: layer, side: right, width: 85pt, connector: (route: "straight-line"), body) }
    else { deixis-inset-note(..args, layer: layer, width: 85pt, dx: 65pt, dy: 80pt, connector: (route: "straight-line"), body) }
    [Following native anchor.]
    deixis-print-endnotes(render-group: deixis-native-render-group)
    expected.push(id)
  }
}
#pagebreak()
// Empty edge maps suppress the border, without inheriting the factory accent.
#deixis-inset-note-body(id: <empty>, layer: "flow", stroke: (:), container-func: rect)[#live.update(n => n + 1)No border.]
// The alert preset preserves explicit native edges and still doubles a scalar bar.
#deixis-inline-note-body(id: <alert>, stroke: edge)[#live.update(n => n + 1)Explicit alert edges.]
#deixis-alert-container(stroke: blue)[Direct scalar alert.]
#deixis-note-outline(include-unpaired: true, title: none)
#context {
  assert.eq(live.final(), 13)
  let notes = deixis-query-notes(include-unpaired: true)
  for id in expected { assert(notes.any(n => str(n.id) == id)) }
  assert.eq(notes.find(n => n.id == <empty>).styles.stroke, (:))
  assert.eq(query(<deixis-rendered-start>).len(), 13)
  for slot in query(<deixis-reserver-left>) {
    let end = query(<deixis-rendered-end>).find(m => m.value.internal-id == slot.value.internal-id)
    assert(end.location().position().y <= slot.location().position().y + slot.value.reserved-height + 0.1pt)
  }
}
