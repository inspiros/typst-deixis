#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#import "../../src/core/declarations.typ": _deixis-body-declarations
#set page(width: 540pt, height: 380pt, margin: 60pt)
#show: deixis-setup-notes
#deixis-set(numbering: "a", stroke: blue, inline-mode: "underline")
#deixis-update-note-counter(10)
Root#deixis-inline-mark(id: <root>).
#deixis-inset-note-body(of: <root>, layer: "background", width: 170pt, dx: 100pt, dy: 100pt)[
  #strong[#deixis-inline-mark(id: <nested-inline>)[Nested #deixis-phantom-mark(id: <deep-phantom>)passage.]]
  #deixis-phantom-mark(id: <nested-phantom>)
  #context { deixis-phantom-mark(id: <contextual>, series: "dynamic") }
]
After#deixis-inline-mark(id: <after>).
// Top-level updates continue to run once and accept both reset forms.
#deixis-update-note-counter(n => n + 10)
#deixis-phantom-mark(id: <updated>)
#deixis-update-note-counter(0)
#deixis-phantom-mark(id: <reset>)
#deixis-phantom-mark(id: "deixis-mark-deixis-body-edge", series: "edge")

// A reset/settings/body-attachment inside content is a semantic barrier.
// Preparation must leave it and its following mark in live order.
#let reset-body = [#deixis-update-note-counter(40)#deixis-phantom-mark(id: <after-reset>)]
#let settings-body = [#deixis-set(numbering: "I")#deixis-phantom-mark(id: <after-setting>)]
#assert.eq(_deixis-body-declarations(reset-body).declarations, [])
#assert.eq(_deixis-body-declarations(settings-body).declarations, [])
#deixis-inline-note-body(inline: false)[#reset-body#settings-body]

#context {
  let registry = deixis-system.final()
  for (id, count) in (("root", 11), ("nested-inline", 12), ("deep-phantom", 13),
    ("nested-phantom", 14), ("after", 15), ("updated", 26), ("reset", 1),
    ("after-reset", 41), ("after-setting", 42)) {
    assert.eq(registry.registry.value.notes.at(registry.registry.value.id-index.at(id)).count, count)
  }
  assert.eq(registry.registry.value.notes.at(registry.registry.value.id-index.at("contextual")).count, 1)
  let inner = query(<deixis-inline-mark>).find(it => str(it.value.internal-id) == registry.registry.value.id-index.at("nested-inline")).value
  assert.eq(inner.marker-str, "l")
  assert.eq(inner.styles.stroke.paint, blue)
  assert.eq(inner.styles.inline-mode, "underline")
  assert.eq(registry.registry.value.notes.at(registry.registry.value.id-index.at("after-setting")).numbering, "I")
  assert.eq(query(<deixis-rendered-start>).len(), 2)
  // Finding another deferred mark cannot rename an existing explicit identity.
  assert.eq(registry.registry.value.id-index.at("root"), "id-root")
  assert.eq(registry.registry.value.id-index.at("nested-inline"), "id-nested-inline")
  assert.eq(query(<deixis-mark-id-root>).len(), 1)
}
