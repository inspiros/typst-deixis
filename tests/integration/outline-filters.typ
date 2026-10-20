#import "../../src/lib.typ": *
#set page(width: 500pt, height: 700pt, margin: 45pt)
#show: deixis-setup-notes
#deixis-block(id: <outlined>, thread: "outline-thread", inset: 10pt)[
  #deixis-inline-mark(id: <lonely-inline>, series: "orphan")[Inline only]
  #deixis-phantom-mark(id: <lonely-phantom>, series: "orphan")
  #deixis-region-mark(id: <lonely-region>, series: "orphan", inline: true)[Region only]
  #deixis-inline-mark(series: "anonymous")[Anonymous inline]
  #deixis-region-mark(series: "anonymous", inline: true)[Anonymous region]
  #deixis-endnote(id: <paired>, series: "reading")[Paired body.]
  #deixis-endnote-body(id: <body-only>, series: "reading")[Standalone body.]
]
#let row(name, note) = {
  [#metadata((name: name, type: note.type, series: note.series, id: note.id))<filtered-outline>]
  [Summary.]
}
#deixis-note-outline(title: none, target: <outlined>, include-unpaired: "mark", series: "orphan", summary: row.with("marks"))
#deixis-note-outline(title: none, target: <outlined>, include-unpaired: "mark", series: "anonymous", summary: row.with("anonymous"))
#deixis-note-outline(title: none, thread: "outline-thread", include-unpaired: "body", series: "reading", summary: row.with("bodies"))
#deixis-note-outline(title: none, target: "page", include-unpaired: true, summary: row.with("page"))
#deixis-note-outline(title: none, include-unpaired: true, include-types: ("endnote",), exclude-types: ("phantom-mark",), group-by: "series", summary: row.with("endnotes"))
#context {
  let rows = query(<filtered-outline>).map(n => n.value)
  assert.eq(rows.filter(n => n.name == "marks").map(n => n.type), ("inline-mark", "phantom-mark", "region-mark"))
  assert.eq(rows.filter(n => n.name == "marks").map(n => n.id), (<lonely-inline>, <lonely-phantom>, <lonely-region>))
  assert.eq(rows.filter(n => n.name == "anonymous").map(n => n.type), ("inline-mark", "region-mark"))
  assert.eq(rows.filter(n => n.name == "bodies").map(n => n.id), (<paired>, <body-only>))
  assert.eq(rows.filter(n => n.name == "page"), ())
  assert.eq(rows.filter(n => n.name == "endnotes").map(n => n.id), (<paired>, <body-only>))
}
