#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#import "../../src/core/references.typ": _deixis-reference-sites
#import "../../src/core/query.typ": _deixis-pin-index, _deixis-pins-for
#import "../../src/layout/geometry.typ": _deixis-region-bounds
#set page(width: 470pt, height: 300pt, margin: 40pt)
#show: deixis-setup-notes
#let ticks = state("region-fragment-live", 0)
#let body(name) = [#ticks.update(n => n + 1)#name]
#let painter(name, request) = [#metadata((name: name, document: request.route.document))<repeat-fragment-route>]
#let shape(name, ..args) = {
  let a = args.named()
  box(width: a.width, height: a.height, {
    place(top + left, [#metadata((name: name, width: a.width, height: a.height, stroke: a.stroke, radius: a.radius))<repeat-fragment-shape>])
    deixis-rect-region(..a)
  })
}
Original#deixis-inline-mark(id: <owner>).
#deixis-inset-note-body(of: <owner>, layer: "foreground", width: 75pt, backlink: true,
  placement: it => place(top + right, it))[#body("First-page body.")]
#pagebreak()
#deixis-region-mark(of: <owner>, occurrence: <span>, padding: 3pt, radius: 6pt,
  region-shape: shape.with("wrapped"), layer: "background")[
  #deixis-pin("span-start", padding: 0pt)
  #body("First region fragment.")
  #v(120pt)
  #colbreak()
  #body("Middle region fragment.")
  #deixis-inset-note(id: <middle>, layer: "foreground", width: 75pt,
    placement: it => place(top + right, it))[#body("Middle-page body.")]
  #v(120pt)
  #colbreak()
  #body("Last region fragment.")
  #v(120pt)
  #deixis-pin("span-end", padding: 0pt)
]
#pagebreak()
#deixis-inset-note(id: <later>, layer: "foreground", width: 75pt,
  placement: it => place(top + right, it))[#body("Later-page body.")]
// An unnamed, marker-free region declared here still returns to its first
// painted frame on page 2, not to this distant declaration on page 5.
#deixis-region-mark(of: <owner>, pins: ("span-start", "span-end"), marker: none,
  region-shape: shape.with("pins"), layer: "foreground")
#deixis-connect(from: (mark: <owner>, occurrence: <span>), to: <owner>,
  connector: (render: painter.with("before")))
#deixis-connect(from: (mark: <owner>, occurrence: <span>), to: <middle>,
  connector: (render: painter.with("inside")))
#deixis-connect(from: (mark: <owner>, occurrence: <span>), to: <later>,
  connector: (render: painter.with("after")))
#context {
  assert.eq(ticks.final(), 6)
  assert.eq(deixis-system.final().registry.value.notes.len(), 3)
  assert.eq(query(<deixis-region-mark>).len(), 0)
  assert.eq(query(<deixis-region-occurrence>).len(), 2)
  let index = _deixis-pin-index()
  for region in query(<deixis-region-occurrence>) {
    let data = region.value
    let name = if data.occurrence-name == none { "pins" } else { "wrapped" }
    let pins = _deixis-pins-for(index, data.pins)
    let segments = query(<repeat-fragment-shape>).filter(s => s.value.name == name)
    assert.eq(segments.map(s => s.location().page()), (2, 3, 4))
    for segment in segments {
      let page = segment.location().page()
      let bounds = _deixis-region-bounds(pins, page, padding: data.styles.padding)
      assert(calc.abs(segment.location().position().x - bounds.left) < 0.001pt)
      assert(calc.abs(segment.location().position().y - bounds.top) < 0.001pt)
      assert(calc.abs(segment.value.height - (bounds.bottom - bounds.top)) < 0.001pt)
      if name == "wrapped" {
        if page != 2 { assert.eq(segment.value.stroke.top, none); assert.eq(segment.value.radius.top-left, 0pt) }
        if page != 4 { assert.eq(segment.value.stroke.bottom, none); assert.eq(segment.value.radius.bottom-right, 0pt) }
      }
    }
  }
  let uid = deixis-system.final().registry.value.id-index.at("owner")
  let destinations = _deixis-reference-sites(destinations: true).at(uid)
  assert.eq(destinations.map(d => d.page()), (2, 2))
  [#metadata((destinations: destinations.map(d => (page: d.page(), x: d.position().x.pt(), y: d.position().y.pt()))))<test-result>]
}
