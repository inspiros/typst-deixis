#set page(width: 300pt, height: 240pt, margin: (x: 1cm, rest: 1cm))

#import "../../src/lib.typ": *
#show: deixis-setup-notes
#show raw: set text(size: 0.85em)

Test notes:
#deixis-footnote(
  label: <note-1>,
  backlink: true,
  marker-style: (mark: it => text(fill: red, super(it))),
)[Note 1.]
#deixis-footnote(
  label: <note-2>,
  backlink: "always",  // equivalent to true
  marker-style: (mark: it => text(fill: blue, super(it))),
)[Note 2.]
#deixis-footnote(
  label: <note-3>,
  backlink: "none",  // equivalent to false
)[Note 3.]
#deixis-footnote(
  label: <note-4>,
  backlink: "multiple",  // only if they are ref-ed at least once
)[Note 4.]

*Cross-reference features supported by `deixis`:*
#grid(
  align: left,
  columns: (3fr, 1fr),
  row-gutter: 0.8em,
  stroke: none,
  [Ref using ```typst @label```], [#deixis-ref(<note-1>)],
  [Ref using ```typst #deixis-ref(<label>)```], [#deixis-ref(<note-1>, <note-2>)],
  [Ref with supplement], [@note-1[Note]],
  [Ref 3 or more consecutive notes], [#deixis-ref(<note-1>, <note-2>, <note-3>)],
  [Ref 2 or 3+ non-consecutive notes], [#deixis-ref(<note-1>, <note-2>, <note-4>)]
)
