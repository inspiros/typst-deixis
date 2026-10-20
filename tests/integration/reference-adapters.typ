#import "../../src/lib.typ": *
#import "../../src/core/references.typ": *
#import "../../src/render/body.typ": _deixis-should-render-backlinks
#set page(width: 540pt, height: 430pt, margin: (x: 110pt, y: 40pt))
#show: deixis-setup-notes
#deixis-set(marker-style: it => it)
#let labels = ()
#for (i, layer) in ("foreground", "background", "flow").enumerate() {
  if i > 0 { pagebreak() }
  for kind in ("margin", "inset", "footnote") {
    let id = label(layer + "-" + kind)
    let lbl = id
    labels.push(lbl)
    let body = [Standalone #kind in #layer.]
    [Declaration #kind.]
    if kind == "margin" {
      deixis-margin-note-body(body, id: id, layer: layer, side: right, backlink: "multiple")
    } else if kind == "inset" {
      deixis-inset-note-body(body, id: id, layer: layer, width: 100pt, dx: 50pt, dy: 90pt, backlink: "multiple")
    } else {
      deixis-footnote-body(body, id: id, layer: layer, backlink: "multiple")
    }
    [First: #deixis-ref(id, lbl). Again: #deixis-ref(lbl).]
    v(20pt)
  }
}
#pagebreak()
Phantom#deixis-phantom-mark(id: <phantom>, marker: sym.ast).
Region #deixis-region-mark(id: <region>, inline: true, marker: [R])[Marked text].
References to mark-only content: @phantom and @region.
#deixis-inset-note-body(id: <single-inset>, layer: "foreground", width: 100pt,
  dx: 50pt, dy: 100pt, backlink: "multiple")[Standalone with one reference.]
Single inset: @single-inset.
Crowded#deixis-footnote(id: <crowded>, layer: "foreground", backlink: true)[
  A footer body long enough to wrap together with its many return-link hooks.
]
#for i in range(16) { [Reference #deixis-ref(<crowded>). ] }
#context {
  let index = _deixis-reference-index()
  let sites = _deixis-reference-sites()
  for lbl in labels {
    let note = _deixis-reference-target(index, lbl)
    assert(note != none and note.dest != none)
    assert.eq(sites.at(note.uid).len(), 2)
  }
  assert.eq(query(<deixis-rendered-start>).len(), 11)
  let single = query(<deixis-inset-note>).find(n => n.value.id == <single-inset>)
  assert(not _deixis-should-render-backlinks(single.value))
  for slot in query(<deixis-reserver-left>) {
    let end = query(<deixis-rendered-end>).find(n => n.value.internal-id == slot.value.internal-id)
    assert(end.location().position().y <= slot.location().position().y + slot.value.reserved-height + 0.1pt)
  }
  assert.eq(sites.at(_deixis-reference-target(index, <crowded>).uid).len(), 16)
  let targets = labels.map(lbl => _deixis-reference-target(index, lbl).dest)
  for lbl in (<phantom>, <region>) {
    let note = _deixis-reference-target(index, lbl)
    assert(note.dest != none)
    targets.push(note.dest)
  }
  [#metadata((destinations: targets.map(loc => (
    page: loc.page(), x: loc.position().x.pt(), y: loc.position().y.pt(),
  ))))<test-result>]
}
