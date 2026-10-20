#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#set page(width: 500pt, height: 340pt, margin: (x: 95pt, y: 40pt))
#show: deixis-setup-notes
#let live = state("z-nested-live", 0)
#let cases = 0
#for kind in ("inline", "endnote", "footnote", "margin", "inset") {
  for layer in if kind in ("inline", "endnote") { ("flow",) } else { ("flow", "foreground", "background") } {
    if cases > 0 { pagebreak() }
    cases += 1
    let id = kind + "-" + layer
    let content = [#live.update(n => n + 1)Self region
      #deixis-region-mark(of: id, occurrence: <self>, inline: true,
        layer: "foreground", z-index: -3)[$x^2$].]
    // Inline mark owns the counter; its priority is inherited by reused regions
    // unless that occurrence supplies a local override.
    deixis-mark(id: id, z-index: (mark: 4, body: 2))[Original]
    if kind == "inline" { deixis-inline-note-body(of: id, inline: false)[#content] }
    else if kind == "endnote" { deixis-endnote-body(of: id)[#content] }
    else if kind == "footnote" { deixis-footnote-body(of: id, layer: layer, backlink: true)[#content] }
    else if kind == "margin" { deixis-margin-note-body(of: id, layer: layer, width: 80pt, side: right, backlink: true)[#content] }
    else { deixis-inset-note-body(of: id, layer: layer, width: 100pt, dx: 110pt, dy: 60pt, backlink: true)[#content] }
    [.]
    deixis-print-endnotes()
  }
}
#pagebreak()
#let order = state("z-shared-state", "")
#for (id, priority, x) in (("a", 3, 120pt), ("b", -1, 220pt)) {
  deixis-inset-note(id: id, mark-type: "phantom", z-index: priority,
    layer: "foreground", width: 75pt,
    placement: body => place(top + left, dx: x, dy: 90pt, body),
  )[#order.update(s => s + id)Body #id.]
}
#context {
  assert.eq(cases, 11)
  assert.eq(live.final(), cases)
  assert.eq(deixis-system.final().registry.value.notes.len(), cases + 2)
  assert.eq(query(<deixis-rendered-start>).len(), cases + 2)
  assert.eq(query(<deixis-region-occurrence>).len(), cases)
  assert.eq(query(<deixis-occurrence-destination>).len(), cases)
  assert.eq(order.final(), "ba")
  let registry = deixis-system.final()
  assert.eq(registry.registry.value.notes.at("id-a").count, 12)
  assert.eq(registry.registry.value.notes.at("id-b").count, 13)
}
