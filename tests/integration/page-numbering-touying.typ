#import ("@preview/touying:" + sys.inputs.at("touying-version", default: "0.8.0")): *
#import themes.simple: simple-theme, slide
#import "../../src/lib.typ": *
#show: deixis-setup-notes.with(page-overlays: false)
#show: simple-theme.with(aspect-ratio: "16-9", config-page(
  background: deixis-page-overlay(layer: "background"), foreground: deixis-page-overlay(),
))
#let f(key, body) = deixis-footnote(numbering: (restart: "page", pattern: n => [
  #metadata((key: key, value: n))<frame-page-marker>#n
]), body)
#slide[
  First#f("first")[Persistent body.]
  #pause
  Second#f("second")[Revealed body.]
]
#slide[
  Third#f("third")[New slide body.]
]
#context {
  let markers = query(<frame-page-marker>)
  assert.eq(markers.map(m => m.location().page()).dedup(), (1, 2, 3))
  assert(markers.all(m => m.value.value == if m.value.key == "second" { 2 } else { 1 }))
}
