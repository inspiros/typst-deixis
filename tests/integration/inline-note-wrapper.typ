#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#set page(width: 380pt, height: 400pt, margin: 30pt)
#show: deixis-setup-notes
// One call creates a mark and its explanation. The default inline aside stays
// in the sentence; inline: false places a callout block after the line.
#let runs = state("inline-wrapper-runs", 0)
#outline()
= Heading #deixis-inline-note(id: <heading>)[passage][aside#runs.update(n => n + 1)]
Before #deixis-inline-note(id: <aside>)[term][an inline aside#runs.update(n => n + 1)] after.

Before #deixis-inline-note(id: <callout>, inline: false)[term][A callout.#runs.update(n => n + 1)] after.

Solo#deixis-inline-note(id: <solo>)[solo aside#runs.update(n => n + 1)] and
#deixis-inline-note(id: <plain>, marker: none)[plain][unnumbered#runs.update(n => n + 1)] and
#deixis-inline-note(id: <region>, mark-type: "region")[$x^2$][region aside#runs.update(n => n + 1)].
#deixis-mark(id: <later>)[Original] then #deixis-inline-note(of: <later>)[attached#runs.update(n => n + 1)].
See @aside and @later.
#context {
  let sys = deixis-system.final()
  assert.eq(runs.final(), 7)
  let counts = ("heading", "aside", "callout", "solo", "plain", "region", "later").map(id => sys.registry.value.notes.at(sys.registry.value.id-index.at(id)).count)
  assert.eq(counts, (1, 2, 3, 4, 5, 6, 7))
  let bodies = query(<deixis-inline-note>)
  assert.eq(bodies.len(), 7)
  // Body starts and their marks: an aside shares the passage's line.
  let mark-y(id) = query(label("deixis-mark-" + sys.registry.value.id-index.at(id))).first().location().position().y
  let body-y(id) = query(<deixis-rendered-start>).find(b => b.value.id == label(id)).location().position().y
  for id in ("aside", "solo", "plain", "later") {
    assert(calc.abs(body-y(id) - mark-y(id)) < 8pt, message: "aside left its line: " + id)
  }
  assert(body-y("callout") > mark-y("callout") + 8pt, message: "callout should follow the line")
  // The outline shows the heading's passage without creating another note.
  assert.eq(query(outline.entry).len(), 1)
}
