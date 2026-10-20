// A shared geometry plan must be keyed by the evaluation context as well as
// notes/frames. Relative gaps and custom renderers can change the same plan.
#import "../../src/layout/margin.typ": _deixis-predict-cascade
#set page(width: 350pt, height: 240pt, margin: 20pt)
#let frames = ((page: 1, top: 10pt, bottom: 130pt, l-space: 80pt, r-space: 80pt),)
#let renderer(n, ..args) = box(height: 2em, width: 30pt)
#let notes = range(3).map(i => (
  mark-page: 1, mark-x: 100pt, mark-y: 15pt,
  note-data: (side: right, render-single: renderer, width: 80%, gap: 1em,
    target-id: "page", spillover: false),
))
#for size in (10pt, 20pt) {
  set text(size: size)
  context {
    let plan = _deixis-predict-cascade(notes, frames, ltr, "adaptive", min-margin-width: 40pt)
    [#metadata((size: size / 1pt, placements: plan.map(n => (
      y: n._margin-placement.final-y / 1pt,
      h: n._margin-placement.h / 1pt,
      gap: n._margin-placement.gap / 1pt,
    ))))<context-plan>]
  }
}
#context {
  let plans = query(<context-plan>).map(m => m.value)
  assert.eq(plans.first().placements.map(p => p.h), (20.0, 20.0, 20.0))
  assert.eq(plans.last().placements.map(p => p.h), (40.0, 40.0, 40.0))
  assert.ne(plans.first().placements, plans.last().placements)
}
