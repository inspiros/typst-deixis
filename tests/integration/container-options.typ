#import "../../src/lib.typ": *
#set page(width: 560pt, height: 470pt, margin: (x: 110pt, y: 40pt))
#show: deixis-setup-notes
#let ticks = state("container-option-bodies", 0)
#let container(body, token: none, mark: none, inset: 0pt, ..style) = {
  assert.eq(mark, "opaque-option")
  rect(inset: inset, ..style.named(), {
    place(top + left, [#metadata(token)<custom-container>])
    place(bottom + right, dy: inset, [#metadata(token)<custom-container-end>])
    body
  })
}
#let body(name) = [#ticks.update(n => n + 1)#name body.]
#let options(name) = (token: name, mark: "opaque-option", inset: 5pt)
#for (i, layer) in ("foreground", "background", "flow").enumerate() {
  if i > 0 { pagebreak() }
  [Footnote#deixis-footnote(layer: layer, container-func: container,
    container-args: options("foot-" + layer), body("foot-" + layer)).]
  [Margin#deixis-margin-note(layer: layer, side: right, container-func: container,
    container-args: options("margin-" + layer), body("margin-" + layer)).]
  [Inset#deixis-inset-note(layer: layer, width: 100pt, dx: 70pt, dy: 60pt, container-func: container,
    container-args: options("inset-" + layer), body("inset-" + layer)).]
  v(60pt)
}
#pagebreak()
#deixis-inline-note-body(container-func: container, container-args: options("inline"), body("inline"))
Decoupled#deixis-inline-mark(id: <decoupled>).
#deixis-inset-note(of: <decoupled>, width: 90pt, layer: "foreground", dx: 30pt, dy: 130pt,
  container-func: container, container-args: options("decoupled"), body("decoupled"))
Collected#deixis-endnote(series: "kept", container-func: container, container-args: options("end-kept"), body("end-kept"))
Override#deixis-endnote(series: "override", container-func: container, container-args: options("discarded"), body("end-override"))
#deixis-print-endnotes(series: "kept", render-group: deixis-native-render-group)
#deixis-print-endnotes(series: "override", render-group: deixis-default-render-group, container-args: options("printer"))
#deixis-print-endnotes()
#context {
  assert.eq(ticks.final(), 13)
  assert.eq(query(<deixis-rendered-start>).len(), 13)
  let containers = query(<custom-container>).map(c => c.value)
  assert.eq(containers.len(), 13)
  assert.eq(containers.dedup().len(), 13)
  assert("end-kept" in containers and "printer" in containers and "discarded" not in containers)
  for slot in query(<deixis-reserver-left>) {
    let end = query(<deixis-rendered-end>).find(e => e.value.internal-id == slot.value.internal-id)
    assert(end.location().position().y <= slot.location().position().y + slot.value.reserved-height + 0.1pt)
    let outer = query(<custom-container-end>).find(e => e.value == slot.value.container-args.token)
    assert(outer.location().position().y <= slot.location().position().y + slot.value.reserved-height + 0.1pt)
  }
}
