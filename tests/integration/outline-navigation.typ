#import "../../src/lib.typ": *
#set page(width: 500pt, height: 430pt, margin: 40pt, numbering: "i / 1")
#show: deixis-setup-notes
#counter(page).update(4)
#deixis-mark(of: <shared>, occurrence: <early>)[Earlier occurrence]
#deixis-mark(of: <shared>, occurrence: <same-page>)[Same page]
#pagebreak()
#set page(numbering: "A")
#counter(page).update(2)
#deixis-mark(id: <shared>)[Original]
#deixis-endnote-body(of: <shared>)[One shared explanation.]
#pagebreak()
#set page(numbering: (..nums) => [P#nums.pos().first()])
#counter(page).update(2)
#deixis-mark(of: <shared>, mark-type: "region", inline: true, occurrence: <region>)[A later region]
#pagebreak()
#set page(numbering: "1")
#counter(page).update(17)
#deixis-print-endnotes()
#deixis-note-outline(title: [Shared outline])
#context {
  let notes = deixis-query-notes()
  assert.eq(notes.len(), 1)
  assert.eq(notes.first().marks.map(m => m.dest.page()), (1, 1, 2, 3))
  let destinations = (0, 2, 3).map(i => notes.first().marks.at(i).dest)
  [#metadata((destinations: destinations.map(loc => {
    let pos = loc.position()
    (page: pos.page, x: pos.x.pt(), y: pos.y.pt())
  })))<test-result>]
}
