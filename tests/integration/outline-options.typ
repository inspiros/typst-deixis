#import "../../src/lib.typ": *
#set page(width: 550pt, height: 1200pt, margin: 40pt)
#show: deixis-setup-notes
#deixis-mark(id: <lonely>, series: "z")[Unpaired mark]
#deixis-mark(of: <paired>)[Early reuse]
#deixis-endnote-body(id: <body-only>, series: "a")[Unpaired body.]
#deixis-endnote(id: <paired>, series: "z")[Paired explanation.]
#deixis-mark(of: <lonely>)[Later reuse without a body]
#let capture(name, ..options) = deixis-note-outline(title: none,
  summary: note => [#metadata((name: name, id: note.id))<outline-option-row>#note.summary], ..options.named())
#capture("paired")
#capture("marks", include-unpaired: "mark")
#capture("bodies", include-unpaired: "body")
#capture("all", include-unpaired: true)
#capture("series", include-unpaired: true, group-by: "series")
#capture("type", include-unpaired: true, group-by: "type")
#capture("callback", include-unpaired: true, group-by: note => if note.body == none { "Mark" } else { "Body" })
#context {
  let selected(name) = query(<outline-option-row>).filter(n => n.value.name == name).map(n => n.value.id)
  assert.eq(selected("paired"), (<paired>,))
  assert.eq(selected("marks"), (<lonely>, <paired>))
  assert.eq(selected("bodies"), (<body-only>, <paired>))
  assert.eq(selected("all"), (<lonely>, <body-only>, <paired>))
  assert.eq(selected("series"), (<lonely>, <paired>, <body-only>))
  assert.eq(selected("type"), (<lonely>, <body-only>, <paired>))
  assert.eq(selected("callback"), (<lonely>, <body-only>, <paired>))
  assert.eq(deixis-query-notes(include-unpaired: true).map(n => n.id), selected("all"))
  let uses = deixis-query-notes(include-unpaired: true).map(note =>
    note.marks.map(mark => (id: note.id, mark: mark))).flatten().sorted(key: use => use.mark.order)
  assert.eq(uses.map(use => use.id), (<lonely>, <paired>, <paired>, <lonely>))
  assert.eq(uses.map(use => use.mark.original), (true, false, true, false))
}
