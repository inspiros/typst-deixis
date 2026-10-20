#import ("@preview/touying:" + sys.inputs.at("touying-version", default: "0.8.0")): *
#import themes.simple: simple-theme, slide
#import "../../src/lib.typ": *
#show: simple-theme.with(aspect-ratio: "16-9", config-page(
  background: deixis-page-overlay(layer: "background"), foreground: deixis-page-overlay(),
))
#let annotations(body) = deixis-setup-notes(page-overlays: false, body)
#let numbered(key, body) = deixis-footnote(numbering: (restart: "page", pattern: n => {
  assert.eq(n, if key == "first" { 1 } else { 2 })
  [#metadata(n)<unnumbered-frame-marker>#n]
}), body)
#slide(setting: annotations)[
  #deixis-set(numbering: (inset-note: none))
  #deixis-inset-note[Persistent Passage][Persistent Aside.]
  First#numbered("first")[First Body.]
  #pause
  #deixis-inset-note[Revealed Passage][Revealed Aside.]
  Second#numbered("second")[Second Body.]
]
#context {
  let asides = query(<deixis-inset-note>)
  assert.eq(asides.len(), 4)
  assert(asides.all(n => n.value.count == none and n.value.marker-str == none))
  assert.eq(query(<unnumbered-frame-marker>).map(m => m.location().page()).dedup(), (1, 2))
}
