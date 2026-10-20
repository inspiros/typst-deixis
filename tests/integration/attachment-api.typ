#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#set page(width: 500pt, height: 340pt, margin: (x: 100pt, y: 40pt))
#show: deixis-setup-notes
#let ticks = state("attachment-api-bodies", 0)
#let body = [#ticks.update(n => n + 1)One body.]
#let count = 0
#for kind in ("inline", "footnote", "endnote", "margin", "inset") {
  for entry in if kind == "inline" { ("body",) } else { ("body", "wrapper") } {
    for order in ("forward", "backward") {
      if count > 0 { pagebreak() }
      count += 1
      let id = kind + "-" + entry + "-" + order
      let mark() = deixis-inline-mark(id: id)[Original]
      if order == "backward" { mark() }
      if kind == "inline" { deixis-inline-note-body(of: id)[#body] }
      else if kind == "footnote" {
        if entry == "body" { deixis-footnote-body(of: id)[#body] }
        else { deixis-footnote(of: id)[#body] }
      } else if kind == "endnote" {
        if entry == "body" { deixis-endnote-body(of: id)[#body] }
        else { deixis-endnote(of: id)[#body] }
      } else if kind == "margin" {
        if entry == "body" { deixis-margin-note-body(of: id, side: right, width: 75pt)[#body] }
        else { deixis-margin-note(of: id, side: right, width: 75pt)[#body] }
      } else {
        if entry == "body" { deixis-inset-note-body(of: id, width: 85pt, layer: "foreground", dx: 90pt, dy: 60pt)[#body] }
        else { deixis-inset-note(of: id, width: 85pt, layer: "foreground", dx: 90pt, dy: 60pt)[#body] }
      }
      if order == "forward" { mark() }
      // Empty native footnote anchors require following visible inline content.
      [.]
      deixis-print-endnotes()
    }
  }
}
#pagebreak()
// Publishing the same spelling as an ID is fine for the same annotation.
#deixis-inline-mark(id: <same>)[Same identity]
#deixis-sidenote(of: <same>, width: 75pt)[#body]
#deixis-inline-mark(of: <same>)[Reused alias]
#context {
  let sys = deixis-system.final()
  assert.eq(count, 18)
  assert.eq(sys.registry.value.notes.len(), 19)
  assert.eq(ticks.final(), 19)
  assert.eq(query(<deixis-rendered-start>).len(), 19)
  assert.eq(sys.registry.value.pending-bodies.len(), 0)
  assert.eq(query(<same>).len(), 1)
}
