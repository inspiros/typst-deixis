#import "../../src/lib.typ": *
#set page(width: 650pt, height: 390pt, margin: 40pt)
#show: deixis-setup-notes
Primary#deixis-inline-mark(id: <hidden>).
#let tag(name, body) = [#box(body)#label(name)]
#let sample(prefix, emit) = {
  emit(prefix + "initial")
  [#tag(prefix + "origin", [AA])#emit(prefix + "inline")#tag(prefix + "inline", [BB])]
  block[Top.]
  emit(prefix + "block")
  block[#tag(prefix + "block", [Bottom.])]
  parbreak()
  emit(prefix + "paragraph")
  parbreak()
  [#tag(prefix + "paragraph", [Last.])]
}
#grid(columns: (180pt, 180pt, 180pt), gutter: 10pt,
  sample("base", _ => []), sample("repeat", _ => deixis-mark(of: <hidden>, marker: none)),
  sample("named", name => deixis-mark(of: <hidden>, marker: none, occurrence: name)))
#context {
  assert.eq(query(<deixis-mark-occurrence>).len(), 8)
  assert.eq(query(<deixis-occurrence-corner>).len(), 0)
  let origin(prefix) = query(label(prefix + "origin")).first().location().position()
  let a = origin("base")
  for prefix in ("repeat", "named") {
    let b = origin(prefix)
    assert.eq(a.y, b.y)
    for slot in ("inline", "block", "paragraph") {
      let base = query(label("base" + slot)).first().location().position()
      let repeated = query(label(prefix + slot)).first().location().position()
      assert(calc.abs((base.x - a.x) - (repeated.x - b.x)) < 0.001pt)
      assert(calc.abs((base.y - a.y) - (repeated.y - b.y)) < 0.001pt)
    }
  }
}
