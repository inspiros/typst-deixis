#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#set page(width: 440pt, height: 340pt, margin: 30pt, numbering: "1")
#set text(size: 10pt)
#show: deixis-setup-notes
#let placement = sys.inputs.at("placement", default: "top")
#let scope = sys.inputs.at("scope", default: "parent")
#let caption-position = sys.inputs.at("caption", default: "bottom")
#let columns-mode = sys.inputs.at("columns", default: "one")
#set figure.caption(position: if caption-position == "top" { top } else { bottom })
#let live = state("local-figure-live", ())
#let make(index) = {
  let owner = "figure-" + str(index)
  place(if placement == "top" { top } else { bottom }, float: true, scope: scope)[
    #deixis-block(id: owner, inset: 0pt)[
      #figure(caption: [CAPTION#index#deixis-footnote(id: owner + "-caption", numbering: "a", backlink: true)[
        #live.update(xs => xs + (owner + "-caption",))CAPTIONNOTE#index
      ].])[
        #rect(width: 100%, height: 65pt, inset: 8pt, fill: rgb("eef5f8"))[
          #metadata(index)<local-figure-picture>
          DIAGRAM#index#deixis-footnote(id: owner + "-diagram", numbering: "a", backlink: true)[
            #live.update(xs => xs + (owner + "-diagram",))DIAGRAMNOTE#index
          ].
        ]
      ]#label(owner + "-native")
      #metadata(index)<local-figure-content-end>
    ]
  ]
}
#let main = [
  Outside Before#deixis-footnote(id: <outside-before>, layer: "flow")[OUTSIDEBEFORE].

  #lorem(65)
  #make(0)
  #lorem(45)
  #make(1)
  #lorem(80)

  Outside After#deixis-footnote(id: <outside-after>, layer: "flow")[OUTSIDEAFTER].
  See #ref(<figure-0-native>) and #ref(<figure-1-native>).
]
#if columns-mode == "two" { columns(2, main) } else { main }
#context [#metadata((notes: deixis-query-notes(), native: counter(footnote).final(),
  figures: query(figure).len(), numbers: query(figure).map(f => counter(figure.where(kind: f.kind)).at(f.location()).first())))<local-figure-catalogue>]
#let verify() = {
  assert.eq(live.final().sorted(), ("figure-0-caption", "figure-0-diagram", "figure-1-caption", "figure-1-diagram"))
  let data = query(<local-figure-catalogue>).first().value
  assert.eq(data.notes.len(), 6)
  assert.eq(data.native, (0,))
  assert.eq(data.figures, 2)
  assert.eq(data.numbers, (1, 2))
  assert.eq(query(<figure-0-native>).first().func(), figure)
  assert.eq(query(<figure-1-native>).first().func(), figure)
  assert.eq(query(<deixis-footnote-entry>).len(), 2)
  assert.eq(query(<deixis-reserver-left>).len(), 0)
  assert.eq(data.notes.find(n => n.id == <outside-before>).count, 1)
  assert.eq(data.notes.find(n => n.id == <outside-after>).count, 2)
  let pictures = query(<local-figure-picture>)
  let result = ()
  for index in range(2) {
    let owner = "figure-" + str(index)
    let picture = pictures.find(m => m.value == index).location().position()
    let end = query(<local-figure-content-end>).find(m => m.value == index).location().position()
    let local = data.notes.filter(n => type(n.id) == str and n.id.starts-with(owner))
    assert.eq(local.map(n => n.count).sorted(), (1, 2))
    for n in local {
      let p = n.body.dest.position()
      assert.eq(p.page, picture.page)
      assert.eq(n.body.start.page(), picture.page)
      assert.eq(n.body.end.page(), picture.page)
      assert(p.y >= end.y)
      assert(p.x >= 29pt and p.x <= 411pt)
      assert(p.y <= 310pt)
      assert.eq(n.marks.len(), 1)
      assert.eq(n.marks.first().dest.page(), picture.page)
    }
    result.push((owner: owner, page: picture.page, x: picture.x.pt(), y: picture.y.pt()))
  }
  assert.eq(deixis-system.final().stack, ())
  (figures: result, destinations: data.notes.map(n => {
    let p = n.body.dest.position()
    (page: p.page, x: p.x.pt(), y: p.y.pt())
  }) + query(figure).map(f => {
    let p = f.location().position()
    (page: p.page, x: p.x.pt(), y: p.y.pt())
  }) + data.notes.filter(n => type(n.id) == str).map(n => {
    let p = n.marks.first().dest.position()
    (page: p.page, x: p.x.pt(), y: p.y.pt())
  }))
}
