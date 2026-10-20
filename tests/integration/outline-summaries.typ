#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#set page(width: 520pt, height: 550pt, margin: 50pt)
#show: deixis-setup-notes
#let runs = state("outline-body-runs", 0)

#deixis-pin("selection-start")
Text#deixis-footnote(layer: "flow", id: <outer-body>)[
  Real *formatted* body. #runs.update(n => n + 1)
  #context [Physical page #here().page().]
  Nested#deixis-inline-mark(id: <nested>)[word]#deixis-inline-note-body(of: <nested>)[Only once.]
]
// Bounds on the same line must use source order rather than just page/y.
Before#deixis-endnote(id: <before-body>)[Before boundary.]#deixis-pin("same-line")After#deixis-endnote(id: <after-body>)[After boundary.]
#deixis-pin("selection-end")
#deixis-endnote(id: <opaque-body>)[#context [Only contextual output.]]
#deixis-print-endnotes()

#let capture(name, note) = {
  [#metadata((name: name, id: note.id, loc: note.loc))<outline-row>]
  [A safe custom summary.]
}
#deixis-note-outline(title: none, after: "selection-start", before: "selection-end")
#deixis-note-outline(title: none)
#deixis-note-outline(title: none, after: "same-line", before: "selection-end", summary: capture.with("after"))
#deixis-note-outline(title: none, after: "selection-start", before: "same-line", summary: capture.with("before"))
#deixis-note-outline(title: none, include-types: ("endnote",), summary: capture.with("all-endnotes"))
#context {
  assert.eq(runs.final(), 1, message: "An outline must not execute note bodies again.")
  assert.eq(deixis-system.final().registry.value.notes.len(), 5)
  let starts = query(<deixis-rendered-start>)
  assert.eq(starts.len(), 5)
  let rows = query(<outline-row>)
  assert.eq(rows.filter(n => n.value.name == "after").map(n => n.value.id), (<after-body>,))
  assert.eq(rows.filter(n => n.value.name == "before").map(n => n.value.id), (<outer-body>, <nested>, <before-body>))
  assert.eq(rows.filter(n => n.value.name == "all-endnotes").map(n => n.value.id), (<before-body>, <after-body>, <opaque-body>))
  [#metadata((destinations: query(<deixis-inline-mark>).map(n => {
    let loc = query(n.value.mark-lbl).first().location()
    (page: loc.page(), x: loc.position().x.pt(), y: loc.position().y.pt())
  })))<test-result>]
}
