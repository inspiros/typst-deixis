#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#set page(width: 450pt, height: 330pt, margin: 40pt)
#show: deixis-setup-notes
#let ticks = state("heading-region-live", 0)
#let shape(..args) = {
  let a = args.named()
  [#metadata((width: a.width, height: a.height))<heading-region-shape>]
  rect(width: a.width, height: a.height, fill: a.fill, stroke: a.stroke, radius: a.radius)
}

// A background live heading registers a foreground region after its reset.
// Numeric scheduling hints must remain discoverable across that barrier.
#deixis-inset-note(id: <outer>, layer: "background", width: 210pt, dy: 30pt)[Outer][
  #show heading.where(level: 1): it => {
    deixis-update-note-counter(0, target: "page", series: "titles")
    it
  }
  #ticks.update(n => n + 1)
  = #deixis-mark(id: <inner>, series: "titles", mark-type: "region",
    inline: true, layer: "foreground", z-index: 3, region-shape: shape)[Title]
  #deixis-mark(id: <following>, series: "titles")[Following]
]

#context {
  let sys = deixis-system.final()
  assert.eq(sys.registry.value.notes.at("id-inner").count, 1)
  assert.eq(sys.registry.value.notes.at("id-following").count, 2)
  assert.eq(ticks.final(), 1)
  let drawings = query(<heading-region-shape>)
  assert.eq(drawings.len(), 1)
  assert(drawings.first().value.width > 0pt and drawings.first().value.height > 0pt)
  assert.eq(query(<deixis-rendered-start>).len(), 1)
}
