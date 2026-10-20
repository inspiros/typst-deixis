#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#set page(width: 420pt, height: 300pt, margin: 30pt, numbering: "1",
  header: context [#metadata((page: here().page(),
    ids: deixis-query-notes(page: here().page()).map(n => n.id)))<local-table-page>])
#set text(size: 10pt)
#show: deixis-setup-notes
#let layer = sys.inputs.at("layer", default: "foreground")
#let caption-position = sys.inputs.at("caption", default: "bottom")
#let repeat = sys.inputs.at("repeat", default: "mark")
#set figure.caption(position: if caption-position == "top" { top } else { bottom })
#show figure: set block(breakable: true)
#let live = state("local-table-live", ())
#let table-body = {
  table(columns: (1fr, 1fr), inset: 7pt,
    table.header([Item], [Value#if repeat == "mark" { deixis-mark(of: <units>) } else { deixis-ref(<units>) }]),
    ..range(14).map(i => (
      [ROW#i#if i in (0, 13) {
        deixis-footnote(id: "row-" + str(i), layer: layer, numbering: "a", backlink: true)[
          #live.update(xs => xs + ("row-" + str(i),))ROWNOTE#i
        ]
      }], [#lorem(12)],
    )).flatten())
  [#metadata(none)<local-table-main-end>]
}
Outside Before#deixis-footnote(id: <outside-before>, layer: "flow")[OUTSIDEBEFORE].
#deixis-block(id: <table-owner>, breakable: true)[
  #figure(caption: [Measurement#deixis-mark(id: <units>, numbering: "a") Units.])[
    #table-body
  ]
  #deixis-footnote-body(of: <units>, layer: layer, backlink: true)[
    #live.update(xs => xs + ("units",))UNITNOTE
    #for i in range(8) { [DETAIL#i #lorem(20)] ; parbreak() }
    ENDUNITNOTE
  ]
  #metadata(none)<local-table-caption-end>
]
#metadata(none)<local-table-after>
Outside After#deixis-footnote(id: <outside-after>, layer: "flow")[OUTSIDEAFTER].
#context [#metadata((notes: deixis-query-notes(),
  native: counter(footnote).final(), figures: query(figure).len()))<local-table-catalogue>]
#let verify() = {
  assert.eq(live.final().sorted(), ("row-0", "row-13", "units"))
  let record = query(<local-table-catalogue>).first().value
  let notes = record.notes
  let local = notes.filter(n => n.id not in (<outside-before>, <outside-after>))
  assert.eq(local.len(), 3)
  let declarations = query(<deixis-footnote>).filter(n => n.value.inst-id == repr(("block", "table-owner")))
  assert.eq(declarations.len(), 3)
  assert(declarations.all(n => n.value.layer == "flow"))
  assert.eq(record.native, (0,))
  assert.eq(record.figures, 1)
  assert.eq(query(<deixis-footnote-entry>).len(), 2)
  assert.eq(query(<deixis-reserver-left>).len(), 0)
  assert.eq(notes.find(n => n.id == <outside-before>).count, 1)
  assert.eq(notes.find(n => n.id == <outside-after>).count, 2)
  assert.eq(local.map(n => n.count).sorted(), (1, 2, 3))
  let units = local.find(n => n.id == <units>)
  let table-end = query(<local-table-main-end>).first().location()
  let caption-end = query(<local-table-caption-end>).first().location()
  let after = query(<local-table-after>).first().location()
  assert(table-end.page() > query(<deixis-block-start>).first().location().page())
  let repeats = query(<deixis-mark-occurrence>)
  if repeat == "mark" {
    assert(repeats.len() >= 2)
    assert.eq(units.marks.len(), repeats.len() + 1)
    assert.eq(repeats.map(m => m.location().page()).dedup().len(), repeats.len())
  } else { assert.eq(units.marks.len(), 1) }
  for n in local {
    assert(n.body.dest != none and n.body.start != none and n.body.end != none)
    assert(n.body.start.page() >= caption-end.page())
    if n.body.start.page() == caption-end.page() {
      assert(n.body.start.position().y >= caption-end.position().y)
    }
    assert(n.body.end.page() <= after.page())
  }
  assert(units.body.end.page() > units.body.start.page())
  let pages = query(<local-table-page>).filter(p => <units> in p.value.ids).map(p => p.value.page).dedup().sorted()
  assert.eq(pages, range(units.body.start.page(), units.body.end.page() + 1))
  assert.eq(deixis-system.final().stack, ())
  (repeat: repeat, caption: caption-position,
    header-pages: if repeat == "mark" { repeats.map(m => m.location().page()) } else { () },
    start: units.body.start.page(), end: units.body.end.page(),
    destinations: notes.map(n => {
      let p = n.body.dest.position()
      (page: p.page, x: p.x.pt(), y: p.y.pt())
    }) + local.map(n => n.marks.map(m => {
      let p = m.dest.position()
      (page: p.page, x: p.x.pt(), y: p.y.pt())
    })).flatten())
}
