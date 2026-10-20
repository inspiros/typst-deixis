#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#set page(width: 470pt, height: 370pt, margin: 40pt)
#show: deixis-setup-notes
#let marker(it) = [M#it]
#let body-marker(it) = [B#it]
#show regex("Inherited text|Unaffected text"): it => context {
  assert.eq(text.fill, blue)
  it
}
#deixis-set(stroke: green, fill: green.lighten(90%), radius: (top-left: 3pt, rest: 1pt))
Forward #deixis-mark(of: <shared>)[First passage].
Original#deixis-inline-mark(id: <shared>, inline-mode: "text-fill", marker-style: marker,
  stroke: (mark: blue, body: red), fill: (mark: yellow, body: orange)).
#deixis-endnote-body(of: <shared>, marker-style: (mark: marker, body: body-marker),
  backlink: true)[One body.]
#deixis-set(stroke: purple, fill: purple.lighten(80%))
Inherited #deixis-mark(of: <shared>)[Inherited text].
Override #deixis-mark(of: <shared>, marker-style: (mark: it => [R#it], body: it => panic("body style ran on repeat")),
  inline-mode: (mark: "underline", body: "text-fill"), stroke: (mark: teal, body: red),
  radius: (mark: (top-left: 7pt), body: 0pt))[Overridden text].
Body-only #deixis-mark(of: <shared>, marker-style: (body: it => panic("body style ran")),
  stroke: (body: orange))[Unaffected text].
#deixis-print-endnotes()
#context {
  let registry = deixis-system.final()
  let mark = registry.registry.value.notes.at(registry.registry.value.id-index.at("shared"))
  assert.eq(mark.mark-styles.stroke.paint, blue)
  assert.eq(mark.mark-styles.fill, yellow)
  assert.eq(query(<deixis-rendered-start>).len(), 1)
  assert.eq(query(<deixis-mark-occurrence>).len(), 4)
  // Actual text-fill geometry stays in the original mark's resolved color even
  // after global defaults change, including a body-only local override.
  [#metadata("component-contract")<test-result>]
}
