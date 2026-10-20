#import "@preview/deixis:0.2.0": *
#set page(width: 530pt, height: auto, margin: 35pt)
#set text(size: 11pt)
#show: deixis-setup-notes

= An Index Of Marked Passages

#deixis-mark(id: <idea>)[A first idea]
#deixis-endnote-body(of: <idea>)[One explanation shared by two passages.]
leads to #deixis-mark(of: <detail>)[an early detail].

#deixis-mark(of: <idea>)[The idea returns]
before #deixis-mark(id: <detail>)[the original detail].
#deixis-endnote-body(of: <detail>)[A second explanation.]

#deixis-print-endnotes()

#context {
  let uses = deixis-query-notes().map(note =>
    note.marks.map(mark => (note: note, mark: mark))).flatten().sorted(key: use => use.mark.order)
  table(columns: (auto, 1fr), inset: 6pt,
    table.header([*Note*], [*Marked Passage*]),
    ..uses.map(use => (link(use.mark.dest, use.note.marker), use.mark.summary)).flatten(),
  )
}
