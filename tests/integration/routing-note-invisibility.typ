#import "../../src/lib.typ": *
#set page(width: 560pt, height: 360pt, margin: (left: 30pt, right: 100pt, y: 30pt))
#show: deixis-setup-notes
#let kind = sys.inputs.at("kind", default: "margin")
#let policy = sys.inputs.at("policy", default: "separate")
#let layer = sys.inputs.at("layer", default: "foreground")
#show: deixis-routing.with(policy: policy, nodes:
  if sys.inputs.at("nodes", default: "off") == "on" { ((body: "one", behavior: "ignore"),) } else { () })
#for name in ("one", "two", "three", "four") { deixis-mark(id: name)[Source] }
#let options = (route: "orthogonal", radius: 0pt)
#let emit(name) = {
  if kind == "margin" {
    deixis-margin-note-body(of: name, layer: layer, width: 65pt, connector: options)[Body]
  } else {
    deixis-inset-note-body(of: name, layer: layer, width: 65pt, connector: options,
      placement: x => place(top + left, dx: 250pt, dy: 190pt, x))[Body]
  }
}
#let tag(name, body) = [#box(body)#label(name)]
#let sample(prefix, notes) = {
  if notes { emit("one") }
  [#tag(prefix + "origin", [AA])#if notes { emit("two") }#tag(prefix + "inline", [BB])]
  block[Top.]
  if notes { emit("three") }
  block[#tag(prefix + "block", [Bottom.])]
  parbreak()
  if notes { emit("four") }
  parbreak()
  [#tag(prefix + "paragraph", [Last.])]
}
#grid(columns: (180pt, 180pt), gutter: 10pt, sample("base", false), sample("notes", true))
#context {
  let a = query(<baseorigin>).first().location().position()
  let b = query(<notesorigin>).first().location().position()
  assert.eq(a.y, b.y)
  for slot in ("inline", "block", "paragraph") {
    let base = query(label("base" + slot)).first().location().position()
    let note = query(label("notes" + slot)).first().location().position()
    assert(calc.abs((base.x - a.x) - (note.x - b.x)) < 0.001pt)
    assert(calc.abs((base.y - a.y) - (note.y - b.y)) < 0.001pt)
  }
  assert.eq(query(<deixis-routing-plan>).len(), if policy == "manual" { 0 } else { 1 })
}
