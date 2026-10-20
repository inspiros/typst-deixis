#import "../../src/lib.typ": *
#set page(width: 500pt, height: 370pt, margin: (x: 100pt, y: 40pt))
#show: deixis-setup-notes
#let sizes = (18pt, 10pt)
#let expected = (:)
#let renderer(data, ..args) = {
  let live = not data.at("disable-links", default: false)
  if live { [#metadata((id: data.id, size: text.size, fill: text.fill, leading: par.leading))<render-style>] }
  deixis-native-render-single(data, ..args.named())
}
#for (index, layer) in ("foreground", "background", "flow").enumerate() {
  if index > 0 { pagebreak() }
  for (i, size) in sizes.enumerate() {
    let color = if i == 0 { blue } else { green }
    for kind in ("footnote", "margin", "inset") {
      let id = label(layer + kind + str(i))
      // Page footnotes use the native footer typography (std.footnote entries:
      // 0.85em text, 0.5em leading); margin and inset keep the declaration's.
      expected.insert(str(id), if kind == "footnote" { (size: 11pt * 0.85, fill: luma(0), leading: 0.5em) }
        else { (size: size, fill: color, leading: 8pt) })
      let note = if kind == "footnote" { deixis-footnote } else if kind == "margin" { deixis-margin-note } else { deixis-inset-note }
      set text(size: size, fill: color)
      set par(leading: 8pt)
      if kind == "inset" {
        [Inset#note(layer: layer, id: id, width: 65pt, dx: 80pt, dy: 5pt, render-single: renderer)[Styled inset.]]
      } else {
        [Styled#note(layer: layer, id: id, render-single: renderer)[Styled body.]]
      }
      v(12pt)
    }
  }
}
#context {
  let styles = query(<render-style>)
  assert.eq(styles.len(), 18)
  for style in styles {
    let e = expected.at(str(style.value.id))
    assert.eq(style.value.size, e.size)
    assert.eq(style.value.fill, e.fill)
    assert.eq(style.value.leading, e.leading)
  }
  let ends = query(<deixis-rendered-end>)
  for slot in query(<deixis-reserver-left>) {
    let end = ends.find(n => n.value.internal-id == slot.value.internal-id)
    assert(end.location().position().y <= slot.location().position().y + slot.value.reserved-height + 0.1pt)
  }
}
