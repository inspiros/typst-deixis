#import ("@preview/touying:" + sys.inputs.at("touying-version", default: "0.8.0")): *
#import themes.simple: simple-theme, slide
#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#show: simple-theme.with(aspect-ratio: "16-9", config-page(margin: (left: 50pt, right: 120pt, y: 30pt),
  background: deixis-page-overlay(layer: "background"), foreground: deixis-page-overlay()))
#let annotations(body) = deixis-setup-notes(page-overlays: false, body)
#let drawing(self: none) = {
  // A slide's authored palette setting restarts for each native subslide.
  deixis-set(palette: (blue, orange))
  let first = "hidden-" + str(self.subslide)
  let content = deixis-margin-note(id: first, width: 80pt)[First][A revealed body.]
  if self.subslide == 1 { hide(content) } else { content }
  v(25pt)
  deixis-inset-note(id: "shown-" + str(self.subslide), width: 100pt, dx: 140pt, dy: 20pt)[Second][A visible body.]
}
#slide(setting: annotations)[
  #touying-fn-wrapper(drawing)
  #pause
]
#let verify() = {
 let notes = deixis-system.final().registry.value.notes
 assert.eq(notes.len(), 4)
 for i in (1,2) {
  assert.eq(notes.at("id-hidden-"+str(i)).accent, blue)
  assert.eq(notes.at("id-shown-"+str(i)).accent, orange)
 }
 let live = query(<deixis-rendered-start>).map(m => str(m.value.id))
 assert("hidden-1" not in live)
 assert("hidden-2" in live)
 assert.eq(live.len(), 3)
 true
}
