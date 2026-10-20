#import "../../src/lib.typ": *
#set page(width: 520pt, height: 360pt, margin: 45pt)
#show: deixis-setup-notes
#show: deixis-routing.with(policy: sys.inputs.at("policy", default: "separate"), rounds: 0)
#place(top + left, dx: 0pt, dy: 200pt)[#deixis-attach(id: <a>)[#rect(width: 30pt, height: 20pt)]]
#place(top + left, dx: 220pt, dy: 200pt)[#deixis-attach(id: <b>)[#rect(width: 30pt, height: 20pt)]]
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
  sample("base", () => []), sample("edges", () => deixis-connect(from: (node: <a>), to: (node: <b>))))
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
