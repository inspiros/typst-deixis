#import "../../src/lib.typ": *
#set page(width: 500pt, height: 350pt, margin: 35pt)
#set text(size: 10pt)
#show: deixis-setup-notes
#let layer = sys.inputs.at("layer", default: "foreground")
#let live = state("allocation-live", ())
#let body(key) = [#live.update(xs => xs + (key,))Entry #key.]

// Ordinary column-scope floats allocate, both with and without native columns.
#for placement in (top, bottom) {
  pagebreak(weak: true)
  let id = "float-" + repr(placement)
  figure(placement: placement)[Float#deixis-footnote(id: id, layer: layer, body(id)).]
  [Main flow.]
}
#pagebreak()
#columns(2, gutter: 20pt)[
  #figure(placement: top)[Column float#deixis-footnote(id: <column>, layer: layer, body("column")).]
  First column.
  #colbreak()
  Second column#deixis-footnote(id: <second>, layer: layer, body("second")).
]

// Keep only the mark inside a parent-scope float. Its external body declaration
// allocates on that declaration's page; counter and native destinations survive.
#pagebreak()
#figure(placement: top, scope: "parent")[Parent float#deixis-mark(id: <parent>).]
#deixis-footnote-body(of: <parent>, layer: layer, body("parent"))
Main-flow allocation anchor.

#pagebreak()
#deixis-footnote-body(of: <forward>, layer: layer, body("forward"))
Forward#deixis-mark(id: <forward>)[original].

#pagebreak()
Trailing wrapper#deixis-footnote(id: <trailing>, layer: layer, body("trailing"))

#pagebreak()
// Standalone flow may create a paragraph. Overlays require visible following
// text, so keep this allocation anchor for all three paths.
#deixis-footnote-body(id: <standalone>, layer: layer, body("standalone"))
Following allocation anchor.

#pagebreak()
// Custom renderers may discard live-body hooks intentionally. Allocation must
// be validated through private native-entry evidence, not rendered-span counts.
#let custom(data, ..args) = {
  if not data.at("disable-links", default: false) { live.update(xs => xs + ("custom",)) }
  [Custom entry.]
}
Custom#deixis-footnote(id: <custom>, layer: layer, render-single: custom)[Unused.].
Native control#footnote[Native control entry.]

#context {
  let expected = ("float-top", "float-bottom", "column", "second", "parent", "forward", "trailing", "standalone", "custom")
  assert.eq(live.final().sorted(), expected.sorted())
  let entries = query(<deixis-footnote-entry>)
  assert.eq(entries.len(), 9)
  assert.eq(entries.map(m => m.value).dedup().len(), 9)
  assert.eq(query(footnote.entry).len(), 10)
  assert.eq(query(<deixis-reserver-left>).len(), if layer == "flow" { 0 } else { 9 })
  assert.eq(counter(footnote).final(), (1,))
  let bodies = query(<deixis-rendered-start>)
  assert.eq(bodies.len(), 8)
  for body in bodies {
    let entry = entries.find(e => str(e.value) == str(body.value.internal-id))
    assert.eq(body.location().page(), entry.location().page())
    if str(body.value.id) not in ("parent", "standalone") {
      assert.eq(body.location().page(), query(body.value.mark-lbl).first().location().page())
    }
  }
  // Direct PDF navigation to the eight standard body destinations.
  for body in query(<deixis-body-destination>) { link(body.location())[Body ] }
  [#metadata((destinations: query(<deixis-body-destination>).map(m => {
    let p = m.location().position()
    (page: p.page, x: p.x.pt(), y: p.y.pt())
  })))<test-result>]
}
