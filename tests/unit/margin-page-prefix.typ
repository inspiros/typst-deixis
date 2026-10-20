#import "../../src/layout/margin.typ": _deixis-predict-cascade

// Pruning future originals must keep this page's placements and the final
// destination sides used by its outgoing connectors, even with spillover,
// changing widths/binding, and declarations out of physical-page order.
#context {
  let frames = range(1, 5).map(p => (page: p, top: 10pt, bottom: 160pt,
    l-space: (55 + p * 3) * 1pt, r-space: (80 - p * 2) * 1pt,
    binding: if calc.even(p) { right } else { left }))
  let render(data, ..args) = box(width: 40pt, height: data.height)
  for mode in ("adaptive", "flow", "exact") {
    for seed in range(12) {
      let notes = range(30).map(i => (
        mark-page: calc.rem(i * 7 + seed, 4) + 1, mark-x: 100pt, mark-y: (12 + i * 3) * 1pt,
        note-data: (internal-id: i, side: (auto, right, "outside").at(calc.rem(i, 3)),
          width: auto, dx: auto, dy: 0pt, gap: calc.rem(i, 5) * 2pt,
          render-single: render, target-id: "page", spillover: calc.rem(i, 7) != 0,
          height: (15 + calc.rem(i * 17, 35)) * 1pt,
          mark-align-strictness: ("none", "loose", "strict").at(calc.rem(i + seed, 3))),
      ))
      let full = _deixis-predict-cascade(notes, frames, ltr, mode, min-margin-width: 40pt)
      for page in range(1, 5) {
        let pruned = _deixis-predict-cascade(notes.filter(n => n.mark-page <= page), frames, ltr, mode,
          min-margin-width: 40pt)
        let active(plan) = plan.filter(n => n.block-idx == page - 1)
        let outgoing(plan) = plan.filter(n => n.mark-page == page and n.block-idx > page - 1)
          .map(n => (id: n.note-data.internal-id, side: n.note-data.side))
        assert.eq(active(pruned), active(full))
        assert.eq(outgoing(pruned), outgoing(full))
      }
    }
  }
}
