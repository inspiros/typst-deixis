#import "../../src/lib.typ": *
#set page(width: 450pt, height: 300pt, margin: (x: 100pt, y: 30pt))
#show: deixis-setup-notes
#let layer = sys.inputs.at("layer", default: "foreground")
#let live = state("overflow-live", ())
#deixis-set(overflow: (margin-note: (body: "error")))
#let body(name) = [#live.update(xs => xs + (name,))Small body.]
#deixis-margin-note(id: <wrapper>, layer: layer, side: right, width: 80pt)[Wrapper][#body("wrapper")]
#deixis-mark(id: <attached>)[Original]
#deixis-margin-note-body(of: <attached>, layer: layer, side: left, width: 80pt)[#body("attached")]
#pagebreak()
#deixis-margin-note-body(id: <standalone>, layer: layer, side: right, width: 80pt)[#body("standalone")]
After.
#hide[#deixis-margin-note(id: <covered>, layer: layer, overflow: "error", side: left)[#block(height: 350pt)[Covered.]]]
#pagebreak()
// An explicit allow overrides strict settings and retains terminal placement.
#deixis-sidenote(id: <permitted>, layer: layer, overflow: "allow", side: right,
  width: 80pt)[#live.update(xs => xs + ("permitted",))#block(height: 350pt)[Permitted.]]
After.
#pagebreak()
#for id in (<wrapper>, <attached>, <standalone>, <permitted>) { [#link(id)[Body] ] }
#let verify() = {
  assert.eq(live.final().sorted(), ("attached", "permitted", "standalone", "wrapper"))
  let evidence = query(<deixis-margin-overflow>).filter(m => not m.value.at("hidden", default: false))
  assert.eq(evidence.len(), 3)
  assert(evidence.all(m => m.value.vertical <= 0.1pt and m.value.horizontal <= 0.1pt))
  assert.eq(query(<deixis-body-destination>).filter(m => m.value.id != <covered>).len(), 4)
  (destinations: (<wrapper>, <attached>, <standalone>, <permitted>).map(id => {
    let pos = query(id).first().location().position()
    (page: pos.page, x: pos.x.pt(), y: pos.y.pt())
  }))
}
