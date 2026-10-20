#import "../../src/lib.typ": *
#set page(width: 420pt, height: 260pt, margin: 25pt)
#set text(size: 10pt)
#show: deixis-setup-notes
#let live = state("fixed-block-footnotes-live", 0)
#for height in (auto, 360pt, 90pt) {
  pagebreak(weak: true)
  let id = repr(height)
  deixis-block(id: "fixed-" + id, height: height, breakable: true,
    inset: (x: 60pt, y: 8pt), stroke: blue)[
    Text#deixis-footnote(id: label(id))[
      #live.update(n => n + 1)Footer begins. #lorem(35)
    ]
    #v(20pt)
    #metadata(id)<fixed-main-end>
  ]
  [#metadata(id)<fixed-after>After the block. #link(label(id))[Body.]]
}
#context {
  assert.eq(live.final(), 3)
  let starts = query(<deixis-block-start>)
  let ends = query(<deixis-block-end>)
  let bodies = query(<deixis-rendered-start>)
  for height in (auto, 360pt, 90pt) {
    let id = repr(height)
    let start = starts.find(m => m.value.id == repr(("block", "fixed-" + id))).location()
    let end = ends.find(m => m.value.id == repr(("block", "fixed-" + id))).location()
    let main-end = query(<fixed-main-end>).find(m => m.value == id).location()
    let body = bodies.find(m => m.value.id == label(id)).location()
    let body-end = query(<deixis-rendered-end>).find(m => m.value.id == label(id)).location()
    let after = query(<fixed-after>).find(m => m.value == id).location()
    assert(body.page() >= main-end.page())
    if body.page() == main-end.page() { assert(body.position().y > main-end.position().y) }
    assert.eq(body-end.page(), end.page())
    assert(body-end.position().y <= end.position().y + 0.1pt)
    assert(after.page() >= end.page())
    if after.page() == end.page() { assert(after.position().y > end.position().y) }
    if height == 360pt { assert(end.page() > start.page()) }
    else { assert.eq(end.page(), start.page()) }
  }
}
