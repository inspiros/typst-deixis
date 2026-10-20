#import ("@preview/touying:" + sys.inputs.at("touying-version", default: "0.8.0")): *
#import themes.simple: simple-theme, slide
#import "../../src/lib.typ": *
#show: simple-theme.with(aspect-ratio: "16-9", config-page(
  background: deixis-page-overlay(layer: "background"), foreground: deixis-page-overlay(),
))
#let annotations(body) = deixis-setup-notes(page-overlays: false, [
  #deixis-update-note-counter(0, target: "page", series: "default")
  #body
])
#slide(setting: annotations)[
  First#deixis-footnote(layer: "flow")[First frame note.]
  Second#deixis-footnote(layer: "flow")[Second frame note.]
  #pause
  Revealed text.
]
#slide(setting: annotations)[
  Restart#deixis-footnote(layer: "flow")[New slide note.]
]
