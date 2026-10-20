#import "../../src/lib.typ": *
#set page(width: 440pt, height: 260pt, margin: 30pt)
#set text(size: 10pt)
#show: deixis-setup-notes
#let outside = sys.inputs.at("source", default: "inside") == "outside"
#let spec = sys.inputs.at("spill", default: "auto")
#let paint(r) = {
  let c = r.route.document.continuation
  let region = c.allocation.region
  if spec == "auto" {
    assert.eq(region.kind, "margin")
    assert.eq((region.left, region.right), (350pt, 410pt))
  } else { assert.eq(region.kind, spec) }
  assert(region.left <= c.point.first() and c.point.first() <= region.right)
  [#metadata(c.page)<scope-spill-painted>]
  deixis-render-connector(r)
}
#deixis-connect(from: (pin: <source>), to: <note>, connector: (
  spill: if spec == "auto" { auto } else { spec }, render: paint))
#if outside { deixis-pin(<source>); pagebreak() }
#deixis-block(id: <scope>, breakable: true, inset: (x: 60pt, y: 10pt))[
  #if not outside { deixis-pin(<source>) }
  #for i in range(10) { block(height: 45pt)[Paragraph #i] }
  #deixis-margin-note(id: <note>, side: right, width: 45pt)[Mark][Scoped Body]
]
#let verify() = { assert.eq(query(<scope-spill-painted>).len(), 2); true }
