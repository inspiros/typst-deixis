// Fixed workload shared by scripts/benchmark.py and checkout regression runs.
#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#set page(width: 15cm, height: 21cm, margin: (left: 1.5cm, right: 4.5cm, y: 1.5cm))
#set text(size: 9pt)
#show: deixis-setup-notes
#let n = int(sys.inputs.at("n", default: "20"))
#let kind = sys.inputs.at("kind", default: "margin")
#assert(kind in ("margin", "footnote", "references", "native"))
// Allocate real reading space: the old compact stress fixture could fit its
// source on fewer pages than its margin bodies, hiding terminal overflow.
#if kind == "margin" { deixis-set(overflow: "error") }
#for i in range(n) [
  Sentence #i
  #if kind == "margin" [#deixis-margin-note[term][Margin #i.]]
  #if kind == "footnote" [#deixis-footnote[Footnote #i.]]
  #if kind == "references" [#deixis-mark(id: label("k" + str(i)))[named] see #ref(label("k" + str(calc.max(0, i - 1))))]
  #if kind == "native" [text#std.footnote[Native #i.]]
  .
  #parbreak()
]
#context {
  let registry = deixis-system.final().registry.value
  assert.eq(registry.notes.len(), if kind == "native" { 0 } else { n })
  if kind == "margin" { assert.eq(query(<deixis-body-destination>).len(), n) }
  if kind == "footnote" { assert.eq(query(<deixis-footnote-entry>).len(), n) }
  if kind == "references" { assert.eq(query(<deixis-ref-marker>).len(), n) }
}
