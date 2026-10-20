#import "../../src/lib.typ": *
#set page(width: 500pt, height: 320pt, margin: (x: 100pt, y: 40pt))
#show: deixis-setup-notes
#let ticks = state("body-ownership", 0)
#let body = [#ticks.update(n => n + 1)One body.]
First page sources:
#deixis-inline-mark(id: <margin>)[overlay margin]
#deixis-inline-mark(id: <immediate>)[immediate margin]
#deixis-inline-mark(id: <foot>)[footnote]
#deixis-inline-mark(id: <inline>)[inline body]
#deixis-inline-mark(id: <inset>)[inset body]
#deixis-inline-mark(id: <end>)[endnote]
#deixis-endnote-body(of: <end>)[#body]
#pagebreak()
Second page declarations.
#deixis-margin-note-body(of: <margin>, layer: "foreground", width: 75pt, side: right)[#body]
#deixis-margin-note-body(of: <immediate>, layer: "flow", width: 75pt, side: left)[#body]
#deixis-footnote-body(of: <foot>)[#body]
#deixis-inline-note-body(of: <inline>)[#body]
#deixis-inset-note-body(of: <inset>, layer: "background", width: 75pt,
  placement: it => place(top + right, it))[#body]
#pagebreak()
Third page printer.
#deixis-print-endnotes()
#context {
  assert.eq(ticks.final(), 6)
  let bodies = query(<deixis-rendered-start>)
  assert.eq(bodies.len(), 6)
  for (name, page) in ((<margin>, 1), (<immediate>, 2), (<foot>, 2),
    (<inline>, 2), (<inset>, 2), (<end>, 3)) {
    assert.eq(bodies.find(b => b.value.id == name).location().page(), page)
  }
}
