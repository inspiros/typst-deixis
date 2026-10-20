#import "@preview/deixis:0.2.0": *
#set page(width: 520pt, height: 350pt, margin: 38pt, numbering: "i")
#set text(size: 11pt)
#show: deixis-setup-notes

= Several Passages, One Explanation

#deixis-mark(id: <idea>)[The first passage]
#deixis-endnote-body(of: <idea>)[A shared explanation with one number and several uses.]
#deixis-mark(of: <idea>, occurrence: <again>)[Another passage] uses the same note.

#pagebreak()
#deixis-mark(of: <idea>, mark-type: "region", inline: true)[$x^2 + y^2 = z^2$]#h(0.2em)
is another use of that explanation.

#deixis-print-endnotes()
#deixis-note-outline(title: [Default Outline], heading-level: 2)

// The same semantic records can drive a table, cards, or one row per mark.
#context {
  let notes = deixis-query-notes()
  table(columns: (auto, 1fr, auto), inset: 6pt,
    table.header([*Note*], [*Explanation*], [*Uses*]),
    ..notes.map(note => (note.marker, note.summary, str(note.marks.len()))).flatten(),
  )
}
