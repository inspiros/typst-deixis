#import "../../src/layout/margin.typ": deixis-margin-note-adaptive-layout
#set page(width: 400pt, height: 200pt, margin: 0pt)

// Exercise the public painter directly, rather than predictor-fixed sides.
// The second note's gap fits before its natural position; it must not inflate
// the occupied bottom and incorrectly send the third note to the other margin.
#let render(data, ..args) = box(width: 100%, height: 10pt, {
  if not data.at("disable-links", default: false) {
    [#metadata(data.test-id)<packed-note>]
  }
})
#let notes = ((1, 10pt, right, 0pt), (2, 40pt, right, 20pt), (3, 55pt, auto, 0pt)).map(
  ((id, y, side, gap)) => (
    mark-page: 1,
    note-data: (test-id: id, y: y, side: side, gap: gap, width: auto, dx: auto, dy: 0pt, render-single: render),
  ),
)
#place(top + left, deixis-margin-note-adaptive-layout(
  notes, 0pt, 200pt, 100pt, 200pt, 200pt, 80pt, 80pt, 1,
))
#context {
  let placed = query(<packed-note>)
  assert.eq(placed.len(), 3)
  assert(placed.all(n => n.location().position().x == 300pt))
  assert.eq(placed.map(n => n.location().position().y), (10pt, 40pt, 55pt))
}
