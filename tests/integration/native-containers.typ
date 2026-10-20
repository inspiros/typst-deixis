#import "../../src/lib.typ": *
#set page(width: 540pt, height: 430pt, margin: (x: 100pt, y: 40pt))
#show: deixis-setup-notes
#deixis-set(margin-layout: "exact")
#let ticks = state("native-container-bodies", 0)
#let body(name) = [#ticks.update(n => n + 1)#name body.]
#let sample(name, layer, deferred-footer: false) = {
  deixis-pin(name, padding: 0pt)
  [Inset#deixis-inset-note(layer: layer, width: 65pt, anchor-pin: name,
    anchor: (mark: top + left, body: top + left), dx: 40pt, dy: 28pt,
    id: label(name + "-inset"), body(name + " inset")).]
  [Margin#deixis-margin-note(layer: layer, width: 60pt,
    side: right, id: label(name + "-margin"), body(name + " margin")).]
  if deferred-footer {
    [Footer#deixis-inline-mark(id: label(name + "-footer-id")).]
  } else {
    [Footer#deixis-footnote(layer: layer, id: label(name + "-footer"), body(name + " footer")).]
  }
}
#lorem(35)
#figure(placement: top, scope: "parent", caption: [Floating annotation source.],
  rect(width: 100%, inset: 14pt, sample("figure", "foreground", deferred-footer: true)))
// Native page allocation excludes parent-scope floats. Keep the mark in this
// figure and place its body declaration in the surrounding native flow.
#deixis-footnote-body(of: <figure-footer-id>, layer: "foreground",
  body("figure footer"))
#lorem(35)
#pagebreak()
#grid(columns: (1fr, 1fr), gutter: 20pt,
  [#lorem(12)],
  align(right, rect(inset: 12pt, table(columns: 1, inset: 7pt,
    sample("table", "background"),
  ))),
)
#pagebreak()
#stack(dir: ltr, spacing: 20pt,
  box(width: 100pt)[#lorem(12)],
  box(width: 190pt, quote(block: true, attribution: [Source],
    pad(left: 12pt, sample("quote", "flow")))),
)
#context {
  assert.eq(ticks.final(), 9)
  assert.eq(query(<deixis-rendered-start>).len(), 9)
  assert.eq(query(<deixis-inset-note>).len(), 3)
  for note in query(<deixis-inset-note>) {
    let data = note.value
    let pin = query(<deixis-pin>).find(p => p.value.name == data.anchor-pin)
    let top = query(data.dest-top-lbl).first()
    let left = query(data.dest-left-lbl).first()
    assert.eq(top.location().page(), pin.location().page())
    assert(calc.abs(left.location().position().x - pin.location().position().x - 40pt) < 0.001pt)
    assert(calc.abs(top.location().position().y - pin.location().position().y - 28pt) < 0.001pt)
  }
  for slot in query(<deixis-reserver-left>) {
    let end = query(<deixis-rendered-end>).find(n => n.value.internal-id == slot.value.internal-id)
    assert(end.location().position().y <= slot.location().position().y + slot.value.reserved-height + 0.1pt)
  }
}
