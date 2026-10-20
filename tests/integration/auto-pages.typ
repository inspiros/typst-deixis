#import "../../src/lib.typ": *
#set page(width: 400pt, height: 300pt, margin: auto,
  background: layout(size => [#metadata(size)<native-page-size>]))
#show: deixis-setup-notes
#deixis-set(min-margin-width: 20pt)
#let origin() = block(width: 100%, height: 10pt, above: 0pt, below: 0pt,
  place(top + left, [#metadata(none)<native-page-origin>]))
#let notes(layer) = {
  [Margin#deixis-margin-note(layer: layer, id: label("margin-" + layer), side: right)[Margin.].]
  [Footnote#deixis-footnote(layer: layer, id: label("foot-" + layer))[Footer.].]
  [Inset#deixis-inset-note(layer: layer, width: 70pt, dy: 30pt, dx: 30pt, id: label("inset-" + layer))[Inset.].]
  block(height: 100pt)[Space.]
}
#origin()
Fixed landscape with automatic margins.
#pagebreak()
#set page(width: 440pt, height: auto, margin: (x: 85pt, y: 25pt))
#origin()
#notes("foreground")
#pagebreak()
#set page(margin: (x: 20%, y: 10% + 12pt))
#origin()
#notes("background")
#pagebreak()
#set page(width: auto, height: 300pt, margin: 15pt)
#origin()
#deixis-region-mark(layer: "foreground", padding: 3pt)[#block(width: 130pt, height: 50pt)[Auto width.]]
#pagebreak()
#set page(width: 440pt, height: auto, margin: auto)
#origin()
#notes("flow")
#context {
  let frames = query(<deixis-page-frame>).map(f => f.value)
  let natives = query(<native-page-size>).map(n => n.value)
  let origins = query(<native-page-origin>)
  assert.eq(frames.len(), 5)
  assert.eq(natives.len(), 5)
  for (i, frame) in frames.enumerate() {
    let native = natives.at(i)
    assert.eq((frame.width, frame.height), (native.width, native.height))
    assert.eq(frame.page, i + 1)
    let origin = origins.at(i).location().position()
    assert(calc.abs(frame.margins.left - origin.x) < 0.001pt)
    assert(calc.abs(frame.margins.top - origin.y) < 0.001pt)
  }
  assert.eq(frames.at(2).margins.top, 12pt)
  assert.eq(frames.at(3).width, 160pt)
  assert(frames.at(1).height < 300pt and frames.at(2).height < 300pt)
  for slot in query(<deixis-reserver-left>) {
    let frame = frames.at(slot.location().page() - 1)
    let end = query(<deixis-rendered-end>).find(n => n.value.internal-id == slot.value.internal-id)
    assert(end.location().position().y <= frame.height - frame.margins.bottom + 0.1pt)
    assert(end.location().position().y <= slot.location().position().y + slot.value.reserved-height + 0.1pt)
  }
  assert.eq(query(<deixis-rendered-start>).len(), 9)
  [#metadata(frames.map(f => (width: f.width.pt(), height: f.height.pt())))<test-result>]
}
