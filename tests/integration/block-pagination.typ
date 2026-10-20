#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system, _deixis-layout-scopes
#import "../../src/layout/geometry.typ": _deixis-block-segments
#let mode = sys.inputs.at("mode", default: "exact")
#let layer = sys.inputs.at("layer", default: "foreground")
#let group = sys.inputs.at("group", default: "native")
#set page(width: 500pt, height: 300pt, margin: (inside: 35pt, outside: 25pt, y: 22pt))
#set text(size: 10pt)
#show: deixis-setup-notes
#let live = state("block-pagination-live", ())
#let tracked(data, ..args) = {
  if not data.at("disable-links", default: false) {
    place(top + left, [#metadata(data.id)<block-margin-top>])
  }
  deixis-native-render-single(data, ..args.named())
}
#let renderer = (native: deixis-native-render-group, aligned: deixis-aligned-render-group,
  grid: deixis-grid-render-group).at(group)
#deixis-set(margin-layout: mode, min-margin-width: 30pt,
  render-single: (margin-note: tracked), render-group: (footnote: renderer))

#for index in range(2) {
  if index > 0 { pagebreak() }
  let owner = "block-" + str(index)
  // A thread shares counters and available margin frames, but each block's
  // collected footnotes still belong to that exact block instance.
  deixis-block(id: owner, thread: "pagination", breakable: true,
    inset: (x: 12pt, y: 5pt), stroke: blue)[
    #deixis-block(id: owner + "-inner", breakable: true, inset: (x: 65pt, y: 7pt), stroke: gray)[
      #for i in range(10) {
        let id = label(owner + "-margin-" + str(i))
        let footer = label(owner + "-footer-" + str(i))
        [Paragraph #i#deixis-margin-note(id: id, side: right, width: 50pt, layer: layer,
          marker: none, dx: 3pt)[#live.update(values => values + (str(id),))Margin #i.]
        with note#deixis-footnote(id: footer, layer: layer)[#live.update(values => values + (str(footer),))Footer #i.].]
        v(36pt)
      }
      [Long collected note#deixis-footnote(id: label(owner + "-long"))[
        #live.update(values => values + (owner + "-long",))
        #for n in range(12) { [Footnote paragraph #n. #lorem(22)] ; parbreak() }
      ].]
      #metadata(owner)<block-main-end>
    ]
  ]
  [#metadata(owner)<block-after>After the block.]
}

// Per-page native footers remain an explicit rendering target. An attached
// body can change that target without moving the original's counter owner.
#pagebreak()
#deixis-block(id: "page-footers", breakable: true, inset: (x: 45pt, y: 6pt), stroke: blue)[
  #for i in range(8) {
    let id = label("page-footer-" + str(i))
    [Page text#deixis-mark(id: id).]
    deixis-footnote-body(of: id, target: "page", layer: "flow")[
      #live.update(values => values + (str(id),))Native page footer #i.
    ]
    [ Allocation anchor.]
    v(38pt)
  }
]

#context {
  assert.eq(live.final().len(), 50)
  assert.eq(live.final().dedup().len(), 50)
  let starts = query(<deixis-rendered-start>)
  let ends = query(<deixis-rendered-end>)
  assert.eq(starts.len(), 50)
  assert.eq(ends.len(), 50)
  let frames = (:)
  for p in query(<deixis-page-frame>) { frames.insert(str(p.value.page), p.value) }
  let blocks = query(<deixis-block-start>)
  let block-ends = query(<deixis-block-end>)
  let rights = query(<deixis-block-right>)
  for index in range(2) {
    let owner = "block-" + str(index)
    let inner = repr(("block", owner + "-inner"))
    let begin = blocks.find(b => b.value.id == inner)
    let finish = block-ends.find(b => b.value.id == inner)
    let edge = rights.find(b => b.value.id == inner)
    let segments = _deixis-block-segments(begin, finish, edge, frames)
    let content-end = query(<block-main-end>).find(m => m.value == owner).location()
    let after = query(<block-after>).find(m => m.value == owner).location()
    assert(content-end.page() > begin.location().page())
    let notes = starts.filter(n => n.value.inst-id == inner)
    assert.eq(notes.len(), 21)
    let footers = notes.filter(n => n.value.body-type == "footnote")
    assert.eq(footers.len(), 11)
    assert(footers.all(n => n.location().page() >= content-end.page()))
    assert(query(<deixis-footnote>).filter(n => n.value.inst-id == inner).all(n => n.value.layer == "flow"))
    let long-id = label(owner + "-long")
    let long-start = starts.find(n => n.value.id == long-id).location()
    let long-end = ends.find(n => n.value.id == long-id).location()
    assert(long-end.page() > long-start.page())
    assert.eq(finish.location().page(), long-end.page())
    assert(after.page() >= long-end.page())
    if after.page() == long-end.page() { assert(after.position().y > long-end.position().y) }
    for note in notes.filter(n => n.value.body-type == "margin-note") {
      let pos = query(<block-margin-top>).find(m => m.value == note.value.id).location().position()
      let mark = query(note.value.mark-lbl).first().location().position()
      let segment = segments.find(f => f.page == pos.page)
      assert(segment != none)
      assert.eq(pos.page, mark.page)
      assert(calc.abs(pos.x - (segment.start-x + segment.text-width + 3pt)) < 0.1pt)
      if mode == "exact" or layer == "flow" { assert(calc.abs(pos.y - mark.y) < 0.1pt) }
      else { assert(pos.y >= segment.top - 0.1pt and pos.y <= segment.bottom + 0.1pt) }
    }
  }
  let native = starts.filter(n => n.value.target-id == "page")
  assert.eq(native.len(), 8)
  for n in native {
    let original = query(n.value.mark-lbl).first().location()
    assert.eq(n.location().page(), original.page())
    let reg = deixis-system.final().registry.value.notes.at(str(n.value.internal-id))
    assert.eq(reg.count-id, repr(("block", "page-footers")))
    assert.eq(n.value.layer, "flow")
  }
  assert.eq(deixis-system.final().stack, ())
  assert.eq(_deixis-layout-scopes.final().stack, ())
  // Actual PDF destinations for all collected bodies and native page footers.
  for n in query(<deixis-body-destination>) { link(n.location())[Body ] }
  [#metadata((destinations: query(<deixis-body-destination>).map(n => {
    let p = n.location().position()
    (page: p.page, x: p.x.pt(), y: p.y.pt())
  })))<test-result>]
}
