#import ("@preview/touying:" + sys.inputs.at("touying-version", default: "0.8.0")): *
#import themes.simple: simple-theme, slide
#import "../../src/lib.typ": *
#show: simple-theme.with(aspect-ratio: "16-9", config-page(
  background: deixis-page-overlay(layer: "background"), foreground: deixis-page-overlay(),
))
#let annotations(body) = deixis-setup-notes(page-overlays: false, [
  #deixis-update-note-counter(0)
  #deixis-set(omit: (series: ("todo",)))
  #body
])
#slide(setting: annotations)[
  Visible#deixis-footnote[VisibleBody].
  #pause
  #deixis-inset-note(series: "todo", mark-type: "region", inline: true,
    connector: "curve", layer: "foreground")[KeptPassage][REMOVED BODY]
  #deixis-footnote(series: "todo")[KeptFootPassage][REMOVED FOOT]
  After#deixis-footnote[AfterBody].
]
