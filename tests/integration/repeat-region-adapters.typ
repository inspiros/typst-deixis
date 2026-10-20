#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#set page(width: 500pt, height: 340pt, margin: (x: 95pt, y: 40pt))
#show: deixis-setup-notes
#let ticks = state("repeated-regions-adapters", 0)
#let cases = 0
#for kind in ("inline", "endnote", "footnote", "margin", "inset") {
  for layer in if kind in ("inline", "endnote") { ("flow",) } else { ("flow", "foreground", "background") } {
    if cases > 0 { pagebreak() }
    cases += 1
    let id = kind + "-" + layer
    let region-layer = ("flow", "foreground", "background").at(calc.rem(cases, 3))
    let content = [#ticks.update(n => n + 1)Self region
      #deixis-region-mark(of: id, occurrence: <self>, inline: true, layer: region-layer)[$x^2$].]
    deixis-inline-mark(id: id)[Original]
    if kind == "inline" { deixis-inline-note-body(of: id, inline: false)[#content] }
    else if kind == "endnote" { deixis-endnote-body(of: id)[#content] }
    else if kind == "footnote" { deixis-footnote-body(of: id, layer: layer, backlink: true)[#content] }
    else if kind == "margin" { deixis-margin-note-body(of: id, layer: layer, width: 80pt, side: right, backlink: true)[#content] }
    else { deixis-inset-note-body(of: id, layer: layer, width: 100pt, dx: 110pt, dy: 60pt, backlink: true)[#content] }
    [.]
    deixis-print-endnotes()
  }
}
#context {
  assert.eq(cases, 11)
  assert.eq(ticks.final(), cases)
  assert.eq(deixis-system.final().registry.value.notes.len(), cases)
  assert.eq(query(<deixis-rendered-start>).len(), cases)
  assert.eq(query(<deixis-region-occurrence>).len(), cases)
  assert.eq(query(<deixis-mark-occurrence>).len(), cases)
  assert.eq(query(<deixis-occurrence-destination>).len(), cases)
}
