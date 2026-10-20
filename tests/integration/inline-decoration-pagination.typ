#import "../../src/lib.typ": *
#set page(width: 300pt, height: 220pt, margin: 25pt,
  header: context [#metadata((page: here().page(), ids: deixis-query-notes(page: here().page()).map(n => n.id)))<inline-page>])
#set text(size: 11pt)
#show: deixis-setup-notes
#let mode = sys.inputs.at("mode", default: "highlight")
#let ownership = sys.inputs.at("ownership", default: "attached")
#let live = state("inline-decoration-live", 0)
Before #if ownership == "attached" { deixis-mark(id: <long>)[Original] }
#deixis-inline-note-body(..(if ownership == "attached" { (of: <long>,) } else { (id: <long>,) }),
  inline: true, inline-mode: mode, backlink: true)[
  #live.update(n => n + 1)STARTLONG #lorem(220) ENDLONG
] After.
#context [#metadata(deixis-query-notes(include-unpaired: true))<inline-catalogue>]
#let verify() = {
  assert.eq(live.final(), 1)
  let n = query(<inline-catalogue>).first().value.first()
  assert(n.body.start.page() < n.body.end.page())
  assert(n.body.dest != none)
  let pages = query(<inline-page>).filter(m => <long> in m.value.ids).map(m => m.value.page)
  assert.eq(pages.dedup().sorted(), range(n.body.start.page(), n.body.end.page() + 1))
  (destinations: if ownership == "attached" {
    let p = n.body.dest.position()
    ((page: p.page, x: p.x.pt(), y: p.y.pt()),)
  } else { () })
}
