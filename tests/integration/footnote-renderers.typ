#import "../../src/lib.typ": *
#set page(width: 420pt, height: 340pt, margin: 35pt)
// Overlay columns: the setup option makes unspecified footnote layers foreground.
#show: deixis-setup-notes.with(override-page-footnotes: true)

#let custom(data, ..args) = {
  let disabled = data.at("disable-links", default: false)
  box(width: 100%, height: 30pt, {
    if not disabled {
      place(top + left, [#metadata((id: data.id, size: text.size, fill: text.fill))<footnote-paint>])
      place(bottom + right, [#metadata(data.id)<footnote-paint-end>])
    }
    deixis-native-render-single(data, ..args.named())
  })
}
#let group(notes, ..args) = {
  [#metadata(notes.map(n => n.id))<footnote-custom-group>]
  deixis-native-render-group(notes, ..args.named())
}
#deixis-set(render-single: custom, render-group: group, gap: 5pt)
Uniform#deixis-footnote(id: <uniform-a>)[Uniform A.]
Uniform#deixis-footnote(id: <uniform-b>)[Uniform B.]

#pagebreak()
// Native layout owns page-footnote gaps. Configured body gaps neither split a
// compatible group nor move painted bodies away from their reserved slots.
#deixis-set(gap: 20pt)
Wide gap#deixis-footnote(id: <gap-a>)[Wide gap.]
#deixis-set(gap: 1pt)
Small gap#deixis-footnote(id: <gap-b>)[Small gap.]

#pagebreak()
// Group renderers are column-wide. Incompatible ones must preserve their
// respective single-note renderers rather than silently adopting the first.
#deixis-set(gap: 5pt)
Custom group#deixis-footnote(id: <policy-a>)[Custom group policy.]
#deixis-set(render-group: deixis-native-render-group)
Native group#deixis-footnote(id: <policy-b>)[Native group policy.]

#pagebreak()
// Native entries and both overlay layers share the column without duplication.
#deixis-set(gap: 5pt)
#let runs = state("footnote-renderer-runs", 0)
Foreground#deixis-footnote(id: <foreground>)[Foreground. #runs.update(n => n + 1)]
Ordinary#footnote[Ordinary note.]
Background#deixis-footnote(layer: "background", id: <background>)[Background. #runs.update(n => n + 1)]
Native#deixis-footnote(layer: "flow", id: <native>)[Native custom body. #runs.update(n => n + 1)]

#context {
  let starts = query(<footnote-paint>)
  let ends = query(<footnote-paint-end>)
  let slots = query(<deixis-reserver-left>)
  assert.eq(starts.len(), 9)
  assert.eq(ends.len(), 9)
  assert.eq(slots.len(), 8)
  assert.eq(runs.final(), 3)
  assert.eq(query(<footnote-custom-group>).map(n => n.value), ((<uniform-a>, <uniform-b>), (<gap-a>, <gap-b>)))
  for start in starts {
    let slot = slots.find(n => n.value.id == start.value.id)
    let end = ends.find(n => n.value == start.value.id)
    // Groups paint with the measured native gap; mixed policies place each
    // note directly. Either way every body fills its exact reserved slot.
    if slot != none {
      assert.eq(start.location().page(), slot.location().page())
      assert(calc.abs(start.location().position().y - slot.location().position().y) < 0.01pt)
      assert(calc.abs(end.location().position().y - slot.location().position().y - slot.value.reserved-height) < 0.01pt)
    }
    assert(end.location().position().y <= 305.01pt)
  }
  assert.eq(counter(footnote).get().first(), 1)
}
