#import "../../src/lib.typ": *
#set page(width: 420pt, height: 520pt, margin: 35pt)
#set text(size: 11pt)
#show: deixis-setup-notes
// Page footnotes use the native footer typography, like std.footnote entries:
// 0.85em of the document text, whatever the declaration's local size. Custom
// callbacks run in that context for flow and overlay bodies alike.
#let footer-size = 11pt * 0.85
#let marker(size, it) = {
  assert.eq(text.size, size)
  super(it)
}
#let body-style(size, it) = {
  assert.eq(text.size, size)
  text(size: 0.85em, it)
}
#for layer in ("flow", "foreground") {
  for (i, size) in (18pt, 9pt, 14pt).enumerate() {
    set text(size: size)
    deixis-set(body-style: body-style.with(footer-size))
    [Text#deixis-footnote(id: label(layer + "-styled-" + str(i)), layer: layer,
      // The in-text mark keeps its declaration size; the body marker is in the footer.
      marker-style: (mark: marker.with(size), body: marker.with(footer-size)),
      marker: if i == 0 { [Wide marker] } else { auto })[A custom style in the footer context. #lorem(14)]]
  }
}
// Block-collected footnotes are laid out by Deixis and keep the declaration's context.
#deixis-block[
  #set text(size: 14pt)
  #deixis-set(body-style: body-style.with(14pt))
  Local#deixis-footnote(marker-style: marker.with(14pt))[A collected body in its declaration context.]
]
#context {
  let ends = query(<deixis-rendered-end>)
  assert.eq(ends.len(), 7)
  let slots = query(<deixis-reserver-left>)
  assert.eq(slots.len(), 3)
  for slot in slots {
    let end = ends.find(n => n.value.internal-id == slot.value.internal-id)
    assert(end.location().position().y <= slot.location().position().y + slot.value.reserved-height + 0.1pt)
  }
}
