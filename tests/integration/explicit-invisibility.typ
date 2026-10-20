#import "../../src/lib.typ": *
#set page(width: 520pt, height: 360pt, margin: 45pt)
#show: deixis-setup-notes
#deixis-inset-note(id: <n>, layer: "foreground", connector: none,
  width: 70pt, dx: 140pt, dy: 200pt)[Source][Body]
#let tag(name, body) = [#box(body)#label(name)]
#let sample(prefix, emit) = {
  emit()
  [#tag(prefix + "origin", [AA])#emit()#tag(prefix + "inline", [BB])]
  block[Top.]
  emit()
  block[#tag(prefix + "block", [Bottom.])]
  parbreak()
  emit()
  parbreak()
  [#tag(prefix + "paragraph", [Last.])]
}
#grid(columns: (180pt, 180pt), gutter: 10pt,
  sample("base", () => []), sample("edges", () => deixis-connect(from: <n>, to: <n>)))
#context {
  assert.eq(query(<deixis-connection>).len(), 4)
  let a = query(<baseorigin>).first().location().position()
  let b = query(<edgesorigin>).first().location().position()
  assert.eq(a.y, b.y)
  for slot in ("inline", "block", "paragraph") {
    let base = query(label("base" + slot)).first().location().position()
    let edge = query(label("edges" + slot)).first().location().position()
    assert(calc.abs((base.x - a.x) - (edge.x - b.x)) < 0.001pt)
    assert(calc.abs((base.y - a.y) - (edge.y - b.y)) < 0.001pt)
  }
}
