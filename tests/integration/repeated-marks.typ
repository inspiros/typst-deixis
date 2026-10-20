#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#import "../../src/core/references.typ": _deixis-reference-index, _deixis-reference-target, _deixis-reference-sites
#set page(width: 510pt, height: 490pt, margin: 45pt)
#show: deixis-setup-notes
#deixis-set(marker-style: it => it)
#let ticks = state("repeated-body-count", 0)
#let body(text) = [#ticks.update(n => n + 1)#text]
Forward#deixis-mark(of: <shared>).
Primary#deixis-inline-mark(id: <shared>, series: "notes", marker-position: left).
#deixis-endnote-body(of: <shared>, backlink: "multiple", body("Shared explanation."))
Again#deixis-mark(of: <shared>).
Next#deixis-inline-mark(id: <next>, series: "notes").
#deixis-endnote-body(of: <next>, body("Next explanation."))
#deixis-block(id: <local>)[
  #context assert.eq(deixis-note-counter(), 0)
  Other scope#deixis-mark(of: <shared>).
  #context assert.eq(deixis-note-counter(), 0)
  Local#deixis-footnote(layer: "flow", body("Local explanation."))
]
#pagebreak()
Later page#deixis-mark(of: <shared>).
Phantom#deixis-phantom-mark(id: <phantom>, series: "notes").
#deixis-endnote-body(of: <phantom>, body("Phantom explanation."))
Phantom repeated#deixis-mark(of: <phantom>).
Region #deixis-region-mark(id: <region>, inline: true, series: "notes")[Region original].
#deixis-endnote-body(of: <region>, body("Region explanation."))
Region repeated#deixis-mark(of: <region>).
Literal#deixis-endnote(series: "notes", marker: [C], id: <literal>, body("Literal explanation."))
Literal repeated#deixis-mark(of: <literal>).
#{
  set text(size: 9pt)
  let style(it) = { assert.eq(text.size, 9pt); [R#it] }
  [Custom #deixis-mark(of: <shared>, marker: "X", marker-style: style,
    inline-mode: "underline")[another passage].]
}
References: @shared and #deixis-ref(<shared>, <shared>).
#deixis-print-endnotes()
#deixis-print-endnotes()
#deixis-note-outline(title: none, include-types: ("endnote",), summary: note => [#metadata(note.id)<repeated-outline-row>Summary.])
#context {
  let sys = deixis-system.final()
  assert.eq(sys.registry.value.notes.len(), 6)
  assert.eq(sys.registry.value.counters.at("page").at("notes"), 5)
  assert.eq(ticks.final(), 6)
  assert.eq(query(<deixis-rendered-start>).len(), 6)
  assert.eq(query(<repeated-outline-row>).len(), 5)
  let occurrences = query(<deixis-mark-occurrence>)
  assert.eq(occurrences.len(), 8)
  let index = _deixis-reference-index()
  let shared = _deixis-reference-target(index, <shared>)
  let sites = _deixis-reference-sites()
  assert.eq(sites.at(shared.uid).len(), 7)
  let primary = index.locations.at("deixis-mark-" + shared.uid)
  assert.eq(primary.page(), 1)
  assert(primary != occurrences.first().location())
  let targets = (shared.dest, primary) + sites.at(shared.uid)
  [#metadata((destinations: targets.map(loc => (
    page: loc.page(), x: loc.position().x.pt(), y: loc.position().y.pt(),
  ))))<test-result>]
}
