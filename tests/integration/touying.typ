#import ("@preview/touying:" + sys.inputs.at("touying-version", default: "0.6.3")): *
#import themes.simple: simple-theme, slide
#import "../../src/lib.typ": *
#show: simple-theme.with(aspect-ratio: "16-9", config-page(
  background: deixis-page-overlay(layer: "background"), foreground: deixis-page-overlay(),
))

// Apply after the theme configures each physical slide's page layers.
#let annotations(body) = deixis-setup-notes(page-overlays: false, [
  #deixis-update-note-counter(0)
  #body
])
#slide(setting: annotations)[
  Slide note#deixis-footnote(layer: "flow")[Frame footnote.]
  #v(1em)
  #deixis-inset-note(layer: "foreground", width: 95pt, dx: 15pt, dy: 30pt,
    connector: "straight-line")[Slide mark][Frame callout.]
  #pause
  Revealed slide content.
]
