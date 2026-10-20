#import "../../src/lib.typ": *
#set page(width: 440pt, height: 290pt, margin: 32pt, numbering: "1",
  header: context [#metadata((page: here().page(), ids: deixis-query-notes(page: here().page()).map(n => n.id)))<custom-page>])
#set text(size: 10pt)
#show: deixis-setup-notes
#let kind = sys.inputs.at("kind", default: "inline")
#let live = state("custom-paginated-bodies", ())
#let renderer(data, ..args) = {
  deixis-generate-body-meta(data)
  deixis-generate-body-content(data)
}
#for kind in (kind,) {
  pagebreak(weak: true)
  let id = label(kind)
  deixis-mark(id: id)[Original]
  let body = [
    #live.update(xs => xs + (kind,))
    #for i in range(11) { [Paragraph #i: #lorem(25)] ; parbreak() }
  ]
  if kind == "inline" { deixis-inline-note-body(of: id, render-single: renderer, body) }
  else if kind == "footnote" { deixis-footnote-body(of: id, layer: "flow", render-single: renderer, body) }
  else if kind == "block-footnote" {
    deixis-block(breakable: true, inset: 8pt)[
      Block main text.
      #deixis-footnote-body(of: id, target: 0, render-single: renderer, body)
    ]
  } else {
    deixis-endnote-body(of: id, body)
    deixis-print-endnotes(render-group: deixis-native-render-group, render-single: renderer)
  }
  [Following flow.]
}
#pagebreak()
#for kind in (kind,) {
  let id = label(kind)
  [#deixis-ref(id) #deixis-ref(id, form: "page") #link(id)[Native link] ]
}
// Evaluated by the runner after pagination, outside the live layout graph.
#context [#metadata(deixis-query-notes())<renderer-catalogue>]
#let verify() = {
  assert.eq(live.final(), (kind,))
  let catalogue = query(<renderer-catalogue>).first().value
  assert.eq(catalogue.len(), 1)
  let pages = query(<custom-page>)
  for n in catalogue {
    assert(n.body.dest != none and n.body.start != none and n.body.end != none)
    assert(n.body.end.page() > n.body.start.page())
    assert.eq(pages.filter(p => n.id in p.value.ids).map(p => p.value.page).dedup().sorted(),
      range(n.body.start.page(), n.body.end.page() + 1))
  }
  (destinations: catalogue.map(n => {
    let p = n.body.dest.position()
    (page: p.page, x: p.x.pt(), y: p.y.pt())
  }))
}
