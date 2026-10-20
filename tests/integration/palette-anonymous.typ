#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#set page(width: 530pt, height: 400pt, margin: (left: 40pt, right: 140pt, y: 30pt))
#show: deixis-setup-notes
#let layer = sys.inputs.at("layer", default: "foreground")
#let live = state("anonymous-palette-live", 0)
#deixis-set(palette: (blue, orange, teal, purple))
#deixis-margin-note(width: 100pt, layer: layer)[Wrapper][#live.update(n=>n+1)Anonymous Wrapper]
#v(30pt)
#deixis-inline-note-body(id: <standalone>)[#live.update(n=>n+1)Named Standalone]
#deixis-margin-note-body(width: 100pt, layer: layer)[#live.update(n=>n+1)Anonymous Standalone]
#v(30pt)
#deixis-mark[Unpaired Mark]
#deixis-region-mark(inline: true)[$x^2$]
#hide[#deixis-mark(id: <hidden>)[Hidden]]
#deixis-mark(id: <after-hidden>)[After Hidden]
#deixis-mark(of: <hidden>)[Hidden Original Reuse]
#context [#metadata(deixis-query-notes(include-unpaired: true).map(n => n.accent))<palette-query>]
#let verify() = {
 assert.eq(query(<palette-query>).first().value, (blue, orange, teal, purple, blue, orange, teal))
 assert.eq(live.final(), 3)
 let registry = deixis-system.final()
 assert.eq(registry.registry.value.notes.len(), 4)
 assert.eq(registry.at("palette-counts").values().sum(), 7)
 true
}
