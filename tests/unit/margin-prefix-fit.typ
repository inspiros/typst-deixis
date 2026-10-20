#import "../../src/layout/margin.typ": _deixis-pack-margin, _deixis-margin-prefix-bottom

// The incremental overflow predicate must agree with the full packing oracle
// at every prefix, including negative offsets, varied gaps/heights, and mixed
// strict/loose anchors. This checks fit, not just matching a helper formula.
#let frame = (top: 10pt, bottom: 160pt, end: 160pt)
#for layout in ("adaptive", "flow") {
  for seed in range(243) {
    let forward = frame.top
    let compact = frame.top
    let prefix = ()
    for i in range(7) {
      let digit = calc.rem(calc.floor(seed / calc.pow(3, calc.rem(i, 5))), 3)
      let height = (4 + calc.rem(seed + i * 29, 61)) * 1pt
      let anchor = (calc.rem(seed * 13 + i * 47, 290) - 50) * 1pt
      let p = (h: height, y: anchor - if digit == 1 { height / 2 } else { 0pt },
        anchor-y: anchor, gap: calc.rem(seed + i * 7, 21) * 1pt,
        mark-align-strictness: ("none", "loose", "strict").at(digit))
      compact = _deixis-margin-prefix-bottom(p, frame, layout, forward, compact, prefix.len())
      forward = calc.max(p.y, forward + if i == 0 { 0pt } else { p.gap }) + p.h
      prefix.push(p)
      let packed = _deixis-pack-margin(prefix, frame, layout)
      assert.eq(compact > frame.bottom + 0.1pt, packed.last() + p.h > frame.bottom + 0.1pt,
        message: repr((layout, seed, i, compact, packed.last() + p.h)))
    }
  }
}
