#import "../../src/lib.typ": *
#set page(width: 500pt, height: 310pt, margin: (inside: 45pt, outside: 30pt, y: 30pt))
#set text(size: 10pt)
#show: deixis-setup-notes
#deixis-set(margin-layout: "exact", min-margin-width: 25pt)
#let tracked(data, ..args) = {
  if not data.at("disable-links", default: false) {
    place(top + left, [#metadata(data.id)<scope-margin-top>])
  }
  deixis-native-render-single(data, ..args.named())
}
#deixis-set(render-single: (margin-note: tracked))

// Both nested native blocks repeat their vertical insets on every fragment.
// Margin notes must follow the physical fragment rather than its first page.
#deixis-block(id: "outer", breakable: true, inset: (x: 15pt, y: 7pt), stroke: blue)[
  #deixis-block(id: "inner", breakable: true, inset: (x: 65pt, y: 9pt), stroke: green)[
    #for i in range(10) {
      [Paragraph #i#deixis-margin-note(side: right, id: label("scope-note-" + str(i)),
        width: 50pt, dx: 3pt)[A fragment note.]]
      if i == 0 { deixis-footnote(id: <scoped-footnote>)[Collected after all block content.] }
      v(42pt)
    }
    #metadata(none)<scoped-content-end>
    Immediate#deixis-margin-note(layer: "flow", side: right, width: 50pt, dx: 3pt,
      id: <immediate-scoped>)[Immediate fragment.]
  ]
]

// A fixed-height thread has a later block on the same page; packed bodies can
// spill between the blocks without changing instance ownership of footnotes.
#pagebreak()
#deixis-set(margin-layout: "adaptive")
#let fixed(data, ..args) = box(width: 100%, height: 45pt, {
  deixis-native-render-single(data, ..args.named())
})
#deixis-block(id: <thread-first>, thread: "fragments", height: 90pt,
  inset: (x: 65pt, y: 5pt), stroke: blue)[
  First#deixis-margin-note(side: right, width: 55pt, render-single: fixed, id: <thread-note-1>)[First.]
  Next#deixis-margin-note(side: right, width: 55pt, render-single: fixed, id: <thread-note-2>)[Next.]
  Local#deixis-footnote(id: <thread-footnote-1>)[First block footnote.]
]
#v(10pt)
#deixis-block(id: <thread-second>, thread: "fragments", height: 90pt,
  inset: (x: 65pt, y: 5pt), stroke: green)[
  Local#deixis-footnote(id: <thread-footnote-2>)[Second block footnote.]
]

#let verify() = {
  let starts = query(<deixis-rendered-start>)
  let margins = starts.filter(n => str(n.value.id).starts-with("scope-note-"))
  assert.eq(margins.len(), 10)
  assert(margins.any(n => n.location().page() > 1))
  for note in margins + starts.filter(n => n.value.id == <immediate-scoped>) {
    let mark = query(note.value.mark-lbl).first().location()
    let top = query(<scope-margin-top>).find(n => n.value == note.value.id).location()
    assert.eq(note.location().page(), mark.page())
    // The right note edge is 3pt into the inner block's right inset.
    let content-left = 30pt + if calc.odd(mark.page()) { 15pt } else { 0pt }
    assert(calc.abs(top.position().x - (content-left + 15pt + 65pt + 265pt + 3pt)) < 0.1pt)
    assert(calc.abs(top.position().y - mark.position().y) < 0.1pt)
  }
  let fn = starts.find(n => n.value.id == <scoped-footnote>)
  let content-end = query(<scoped-content-end>).first().location()
  assert(fn.location().page() >= content-end.page())
  for (body-label, block-label) in ((<thread-footnote-1>, <thread-first>), (<thread-footnote-2>, <thread-second>)) {
    let body = starts.find(n => n.value.id == body-label)
    assert.eq(body.value.inst-id, repr(("block", str(block-label))))
  }
  let first = starts.find(n => n.value.id == <thread-note-1>)
  let second = starts.find(n => n.value.id == <thread-note-2>)
  let second-block = query(<deixis-block-start>).find(n => n.value.id == repr(("block", str(<thread-second>))))
  assert(second.location().page() == second-block.location().page())
  assert(second.location().position().y >= second-block.location().position().y)
  assert(first.location().position().y < second.location().position().y)
  assert.eq(starts.len(), 16)
}
