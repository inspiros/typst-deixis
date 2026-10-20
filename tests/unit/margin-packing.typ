#import "../../src/layout/margin.typ": _deixis-predict-cascade

// Exact layout must never move colliding notes to a later page or thread block.
#context {
  let frames = (1, 2).map(p => (
    idx: p - 1, page: p, top: 10pt, bottom: 100pt, l-space: 80pt, r-space: 80pt,
  ))
  let render(data, ..args) = box(width: 50pt, height: 70pt)
  let notes = range(3).map(i => (
    mark-page: 1, mark-x: 100pt, mark-y: 20pt,
    note-data: (
      side: right, width: auto, dx: auto, dy: 0pt, gap: 30pt,
      render-single: render, target-id: "page", spillover: true,
    ),
  ))
  let exact = _deixis-predict-cascade(notes, frames, ltr, "exact")
  assert.eq(exact.map(n => n.block-idx), (0, 0, 0))
  let automatic = notes.map(n => n + (note-data: n.note-data + (side: auto)))
  let exact-auto = _deixis-predict-cascade(automatic, frames, ltr, "exact")
  assert.eq(exact-auto.map(n => n.note-data.side), ("right",) * 3)
  let offset = notes.first() + (note-data: notes.first().note-data + (dy: 300pt))
  let exact-offset = _deixis-predict-cascade((offset,), frames, ltr, "exact")
  assert.eq(exact-offset.first().note-data.y, 20pt)
  let adaptive = _deixis-predict-cascade(notes, frames, ltr, "adaptive")
  assert.eq(adaptive.map(n => n.block-idx), (0, 1, 1))
  let fixed-last = notes.slice(0, 2) + (notes.last() + (
    note-data: notes.last().note-data + (spillover: false),
  ),)
  let mixed = _deixis-predict-cascade(fixed-last, frames, ltr, "adaptive")
  assert.eq(mixed.filter(n => n.block-idx == 0).len(), 2)

  // Existing terminal behavior is explicit: retain every body even when the
  // last frame cannot contain it. The page-level breaker keeps an oversized
  // first body; block/thread prediction can continue to a later block.
  for mode in ("adaptive", "flow") {
    let terminal = _deixis-predict-cascade(notes, frames.slice(0, 1), ltr, mode)
    assert.eq(terminal.len(), 3)
    assert(terminal.last()._margin-placement.final-y + terminal.last()._margin-placement.h > frames.first().bottom)
    let tall-render(data, ..args) = box(width: 50pt, height: 120pt)
    let tall = notes.first() + (note-data: notes.first().note-data + (render-single: tall-render))
    let page-tall = _deixis-predict-cascade((tall,), frames, ltr, mode)
    let block-tall = _deixis-predict-cascade((tall,), frames, ltr, mode, cascade-breaker: false)
    assert.eq(page-tall.first().block-idx, 0)
    assert.eq(block-tall.first().block-idx, 1)
  }

  // A physical page's first block owns anchors before its top. Later blocks
  // on that page start at their top (with the existing 1pt boundary tolerance).
  // A gap between physical pages belongs to the preceding block.
  let threaded = (
    (page: 1, top: 10pt, bottom: 50pt, l-space: 80pt, r-space: 80pt),
    (page: 1, top: 70pt, bottom: 100pt, l-space: 80pt, r-space: 80pt),
    (page: 3, top: 5pt, bottom: 100pt, l-space: 80pt, r-space: 80pt),
    (page: 3, top: 120pt, bottom: 200pt, l-space: 80pt, r-space: 80pt),
  )
  for (p, y, owner) in (
    (0, 20pt, 0), (1, 0pt, 0), (1, 68pt, 0), (1, 69pt, 1), (1, 80pt, 1),
    (2, 500pt, 1), (3, -50pt, 2), (3, 118pt, 2), (3, 119pt, 3), (4, 0pt, 3),
  ) {
    let note = notes.first() + (mark-page: p, mark-y: y)
    let owned = _deixis-predict-cascade((note,), threaded, ltr, "exact")
    assert.eq(owned.first().mark-block, owner)
  }
}
