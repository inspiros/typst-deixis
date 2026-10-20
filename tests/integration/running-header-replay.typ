#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
// A running header repeats the current heading body on every later page.
// deixis-plain shows its passages without registering the annotations again.
#set page(width: 300pt, height: 220pt, margin: (left: 30pt, right: 110pt, y: 45pt),
  header: context {
    let previous = query(selector(heading).before(here()))
    if previous.len() > 0 [Section: #deixis-plain(previous.last().body)]
  })
#show: deixis-setup-notes
#let runs = state("running-header-runs", 0)
= Our #deixis-margin-note(id: <head>)[method][Margin body.#runs.update(n => n + 1)] works#deixis-footnote(id: <head-note>)[Heading footnote.#runs.update(n => n + 1)]
#lorem(40)
#pagebreak()
Later text#deixis-footnote(id: <later>)[Later footnote.] and @head.
#pagebreak()
#deixis-pin("plain-pin") #deixis-plain[A replayed #deixis-pin("plain-pin")pin and #deixis-mark[mark].]
#context {
  let sys = deixis-system.final()
  assert.eq(runs.final(), 2)
  assert.eq(sys.registry.value.notes.at(sys.registry.value.id-index.at("head")).count, 1)
  assert.eq(sys.registry.value.notes.at(sys.registry.value.id-index.at("head-note")).count, 2)
  assert.eq(sys.registry.value.notes.at(sys.registry.value.id-index.at("later")).count, 3)
  // One live footer entry each; header replays add none.
  assert.eq(query(<deixis-footnote-entry>).len(), 2)
  // The replayed pin is not registered a second time.
  assert.eq(query(<deixis-pin>).filter(p => p.value.at("name", default: none) == "plain-pin").len(), 1)
}
