#import "../../src/lib.typ": *
#import "../../src/render/body.typ": _deixis-render-context
#set page(width: 400pt, height: 310pt, margin: 30pt)
#show: deixis-setup-notes
#let probe(id) = box(width: 90pt, height: 20pt, {
  place(top + left, [#metadata(id)<gap-start>])
  place(bottom + left, [#metadata(id)<gap-end>])
})
#let single(data, ..args) = block(above: 0pt, below: 0pt, probe(data.test-id))
#for size in (18pt, 10pt) {
  set text(size: size)
  context [#metadata(_deixis-render-context())<spacing-style>]
}
#for (i, (name, renderer)) in (("native", deixis-native-render-group),
  ("aligned", deixis-default-render-group), ("grid", deixis-grid-render-group)).enumerate() {
  if i > 0 { pagebreak() }
  context {
    let contexts = query(<spacing-style>).map(m=>m.value)
    let data = range(2).map(i => (test-id: name + str(i), internal-id: name + str(i),
      render-context: contexts.at(i), body: probe(name + str(i)), marker-str: none,
      render-single: single, gap: 2em))
    renderer(data)
    v(20pt)
    renderer(data.map(n=>n + (test-id: n.test-id + "override", body: probe(n.test-id + "override"))), gap: 7pt)
  }
}
#context {
  let starts = query(<gap-start>)
  let ends = query(<gap-end>)
  assert.eq(starts.len(), 12)
  for name in ("native", "aligned", "grid") {
    for (suffix, expected) in (("", 20pt), ("override", 7pt)) {
      let end = ends.find(n=>n.value == name + "0" + suffix).location().position().y
      let start = starts.find(n=>n.value == name + "1" + suffix).location().position().y
      assert(calc.abs(start - end - expected) < 0.001pt, message: name + suffix)
    }
  }
}
