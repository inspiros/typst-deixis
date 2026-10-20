#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#set page(width: 540pt, height: 380pt, margin: (left: 45pt, right: 135pt, y: 35pt))
#set text(size: 11pt)
#show: deixis-setup-notes
#let kind = sys.inputs.at("kind", default: "inset")
#let live = state("nested-palette-body", 0)
#deixis-set(palette: (blue, orange, teal, purple))
#let body = [
  #live.update(n => n + 1)
  A #deixis-mark[visual mark] inside the body.
  #deixis-inline-note-body[An anonymous nested inline body.]
]
#if kind == "margin" {
 deixis-margin-note(id: <outer>, width: 110pt, body)
} else {
 deixis-inset-note(id: <outer>, width: 160pt, dx: 180pt, dy: 60pt, body)
}
#v(60pt)
#deixis-mark(id: <after>)[Following Main Text]
#let verify() = {
 let registry = deixis-system.final()
 assert.eq(live.final(), 1)
 assert.eq(registry.registry.value.notes.len(), 2)
 assert.eq(registry.palette-counts.values().sum(), 2)
 let anon = query(<deixis-inline-mark>).filter(n => n.value.internal-id == none)
 assert.eq(anon.len(), 1)
 assert.eq(anon.first().value.accent, blue)
 assert.eq(query(<deixis-inline-note>).first().value.accent, blue)
 true
}
