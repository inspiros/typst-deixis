#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#import "../../src/core/references.typ": _deixis-reference-sites
#set page(width: 560pt, height: 450pt, margin: (x: 110pt, y: 40pt))
#show: deixis-setup-notes
#let ticks = state("repeated-adapter-bodies", 0)
Shared#deixis-endnote(series: "shared", id: <root>, backlink: true)[#ticks.update(n => n + 1)Shared root.]
#let body(prefix) = [#ticks.update(n => n + 1)#prefix body. Root#deixis-mark(of: <root>, occurrence: prefix).]
#let painter(expected, request) = {
  [#metadata((expected: expected, source: request.route.document.source-page,
    bounds: request.route.document.nodes.mark.bounds))<repeat-route>]
}
#for (i, layer) in ("foreground", "background", "flow").enumerate() {
  if i > 0 { pagebreak() }
  for kind in ("margin", "inset", "footnote") {
    let prefix = kind + "-" + layer
    let id = label(prefix)
    [Before#deixis-mark(of: id). Primary#deixis-inline-mark(id: id).]
    let content = [#body(prefix)Self#deixis-mark(of: id, occurrence: "self").]
    if kind == "margin" {
      deixis-margin-note-body(content, of: id, layer: layer, side: right, width: 90pt, backlink: "multiple",
        connector: (route: "straight-line", render: painter.with(i + 1)))
    } else if kind == "inset" {
      deixis-inset-note-body(content, of: id, layer: layer, width: 90pt, dx: 60pt, dy: 45pt, backlink: "multiple",
        connector: (route: "straight-line", render: painter.with(i + 1)))
    } else {
      deixis-footnote-body(content, of: id, layer: layer, backlink: "multiple")
    }
    [After#deixis-mark(of: id).]
    v(45pt)
  }
}
#pagebreak()
Inline#deixis-inline-mark(id: <inline>).
#deixis-inline-note-body(of: <inline>, inline: true, backlink: true)[#ticks.update(n => n + 1)Inline body.]
Repeated inline#deixis-mark(of: <inline>).
#deixis-print-endnotes()
#context {
  assert.eq(ticks.final(), 11)
  assert.eq(deixis-system.final().registry.value.notes.len(), 11)
  assert.eq(query(<deixis-rendered-start>).len(), 11)
  assert.eq(query(<deixis-mark-occurrence>).len(), 37)
  assert.eq(query(<repeat-route>).len(), 6)
  let sites = _deixis-reference-sites()
  for note in query(<deixis-footnote>) {
    assert.eq(sites.at(str(note.value.internal-id)).len(), 3)
  }
  for slot in query(<deixis-reserver-left>) {
    let end = query(<deixis-rendered-end>).find(n => n.value.internal-id == slot.value.internal-id)
    assert(end.location().position().y <= slot.location().position().y + slot.value.reserved-height + 0.1pt)
  }
}
