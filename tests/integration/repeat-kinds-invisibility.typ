#import "../../src/lib.typ": *
#set page(width: 650pt, height: 400pt, margin: 40pt)
#show: deixis-setup-notes
Original#deixis-inline-mark(id: <shared>).
#deixis-pin("invisible-region", padding: 0pt)Geometry.#deixis-pin("invisible-region", padding: 0pt)
#let tag(name, body) = [#box(body)#label(name)]
#let sample(prefix, emit) = {
  emit(prefix + "leading")
  [#tag(prefix + "origin", [AA])#emit(prefix + "inline")#tag(prefix + "inline", [BB])]
  block[Top.]
  emit(prefix + "block")
  block[#tag(prefix + "block", [Bottom.])]
  parbreak()
  emit(prefix + "paragraph")
  parbreak()
  [#tag(prefix + "paragraph", [Last.])]
}
#for layer in ("foreground", "background") {
  grid(columns: (180pt, 180pt, 180pt), gutter: 10pt,
    sample(layer + "base", _ => []),
    sample(layer + "phantom", name => deixis-phantom-mark(of: <shared>, occurrence: name)),
    sample(layer + "region", name => deixis-region-mark(of: <shared>, occurrence: name,
      pins: ("invisible-region",), layer: layer, marker: none)))
}
#context {
  for layer in ("foreground", "background") {
    let origin(prefix) = query(label(layer + prefix + "origin")).first().location().position()
    let a = origin("base")
    for prefix in ("phantom", "region") {
      let b = origin(prefix)
      assert.eq(a.y, b.y)
      for slot in ("inline", "block", "paragraph") {
        let baseline = query(label(layer + "base" + slot)).first().location().position()
        let annotated = query(label(layer + prefix + slot)).first().location().position()
        assert(calc.abs((baseline.x - a.x) - (annotated.x - b.x)) < 0.001pt)
        assert(calc.abs((baseline.y - a.y) - (annotated.y - b.y)) < 0.001pt)
      }
    }
  }
}
