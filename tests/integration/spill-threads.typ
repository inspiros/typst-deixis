#import "../../src/lib.typ": *
#set page(width: 440pt, height: 260pt, margin: 30pt)
#set text(size: 10pt)
#show: deixis-setup-notes
#let live = state("spill-thread-bodies", 0)
#let paint(r) = {
  let c = r.route.document.continuation
  let region = c.allocation.region
  assert.eq(region.kind, "margin")
  assert.eq((region.left, region.right), (if c.page == 1 { 350pt } else { 360pt }, 410pt))
  assert(region.left <= c.point.first() and c.point.first() <= region.right)
  [#metadata(c.page)<thread-spill-painted>]
  deixis-render-connector(r)
}
#deixis-connect(from: (pin: <source>), to: "note2", connector: (render: paint))
#deixis-block(id: <first>, thread: "flow", height: 150pt, inset: (x: 60pt, y: 10pt))[
  #deixis-pin(<source>)
  #for i in range(3) {
    deixis-margin-note(id: "note" + str(i), side: right, width: 40pt)[Mark][
      #live.update(n => n + 1)#block(height: 55pt)[Body #i]
    ]
  }
]
#pagebreak()
#deixis-block(id: <second>, thread: "flow", height: 180pt, inset: (x: 50pt, y: 10pt))[
  The Next Thread Frame
]
#let verify() = {
  assert.eq(query(<thread-spill-painted>).map(n => n.value).sorted(), (1, 2))
  assert.eq(live.final(), 3)
}
