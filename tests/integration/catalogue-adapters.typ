#import "../../src/lib.typ": *
#set page(width: 540pt, height: 420pt, margin: (x: 100pt, y: 40pt))
#show: deixis-setup-notes
#let bodies = state("catalogue-adapter-bodies", 0)
#let expected = ()
#for (i, kind) in ("inline-note", "footnote", "endnote", "margin-note", "inset-note").enumerate() {
  for (j, order) in ("body-first", "mark-first").enumerate() {
    if i > 0 or j > 0 { pagebreak() }
    let id = label(kind + "-" + order)
    let mark() = deixis-mark(id: id)[Original]
    let body = [#bodies.update(n => n + 1)One live body.]
    let emit-body() = {
      if kind == "inline-note" { deixis-inline-note-body(of: id, body) }
      else if kind == "footnote" { deixis-footnote-body(of: id, body) }
      else if kind == "endnote" { deixis-endnote-body(of: id, body) }
      else if kind == "margin-note" { deixis-margin-note-body(of: id, side: right, width: 80pt, body) }
      else { deixis-inset-note-body(of: id, layer: "foreground", width: 90pt, dx: 80pt, dy: 70pt, body) }
    }
    if order == "body-first" { emit-body() }
    mark()
    if order == "mark-first" { emit-body() }
    [Following text.]
    deixis-mark(of: id, mark-type: "region", inline: true)[Repeated region]
    deixis-mark(of: id, mark-type: "phantom")
    deixis-print-endnotes()
    expected.push((id: id, type: kind, body-first: order == "body-first"))
  }
}
#context {
  let notes = deixis-query-notes()
  assert.eq(notes.len(), 10)
  assert.eq(bodies.final(), 10)
  for e in expected {
    let n = notes.find(n => n.id == e.id)
    assert.eq(n.type, e.type)
    assert.eq(n.marks.len(), 3)
    assert.eq(n.marks.map(m => m.type), ("inline-mark", "region-mark", "phantom-mark"))
    assert(n.body.dest != none and n.body.start != none and n.body.end != none)
    assert.eq(n.body.dest.page(), n.body.start.page())
    assert.eq(n.body.order < n.order, e.body-first)
    for m in n.marks { [#link(m.dest)[Mark] ] }
    [#link(n.body.dest)[Body] ]
  }
  [#metadata((destinations: notes.map(n => n.body.dest).map(loc => {
    let pos = loc.position()
    (page: pos.page, x: pos.x.pt(), y: pos.y.pt())
  })))<test-result>]
}
