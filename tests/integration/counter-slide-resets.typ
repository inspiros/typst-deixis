#import ("@preview/touying:" + sys.inputs.at("touying-version", default: "0.8.0")): *
#import themes.simple: simple-theme, slide
#import "../../src/lib.typ": *
#show: deixis-setup-notes.with(page-overlays: false)
#show: simple-theme.with(aspect-ratio: "16-9",
  config-common(page-preamble: deixis-update-note-counter(0, target: "page", series: "default")), config-page(
  background: deixis-page-overlay(layer: "background"), foreground: deixis-page-overlay(),
))
#slide[
  First#deixis-footnote(layer: "flow")[First frame note.]
  Second#deixis-footnote(layer: "flow")[Second frame note.]
  #pause
  Revealed text.
]
#slide[
  Restart#deixis-footnote(layer: "flow")[New slide note.]
]
