#import "../../src/lib.typ": *
#set page(width: 420pt, height: 280pt, margin: (x: 80pt, y: 30pt))
#show: deixis-setup-notes.with(page-overlays: false)
#let events(name) = [#metadata(name)<host-decoration>]
#let fg(name) = [#deixis-page-overlay()#events(name + "-fg")]
#let bg(name) = [#events(name + "-bg")#deixis-page-overlay(layer: "background")]
#set page(foreground: fg("outer"), background: bg("outer"))
#let live = state("host-layer-bodies", ())
#let sample(name) = {
  deixis-margin-note(id: name, side: right, width: 60pt)[Source][#live.update(xs => xs + (name,))#name]
}
= Outer Page
#sample("first")
#pagebreak()
#[
  #set page(foreground: fg("inner"), background: bg("inner"))
  = Inner Page
  #sample("second")
  #pagebreak()
]
= Restored Page
#sample("third")
#let verify() = {
  assert.eq(live.final().sorted(), ("first", "second", "third"))
  assert.eq(query(<deixis-page-frame>).map(m => m.value.page), (1, 2, 3))
  let layers = query(<host-decoration>).map(m => (m.location().page(), m.value)).sorted()
  assert.eq(layers, ((1, "outer-bg"), (1, "outer-fg"), (2, "inner-bg"), (2, "inner-fg"), (3, "outer-bg"), (3, "outer-fg")))
  layers
}
#context { let _ = verify() }
