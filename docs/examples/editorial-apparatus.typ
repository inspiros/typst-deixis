#import "../../src/lib.typ": *
#set page(width: 340pt, height: auto, margin: 15pt)
#set text(size: 11pt)
#set heading(numbering: none)
#show: deixis-setup-notes

// BEGIN EXAMPLE
#let apparatus(n, ..args) = block[
  #deixis-generate-body-marker(n)
  #emph(n.data.lemma)#h(0.3em)
  #deixis-generate-body-content(n)
]
#let source = deixis-endnote.with(
  series: "sources", numbering: "a",
  render-single: apparatus)
#let editor = deixis-endnote.with(
  series: "editorial", numbering: "1")

The #source(id: <reading>, data: (lemma: [harbour],))[
  harbour][MS A; MS B reads “haven”.]
was quiet. The #deixis-mark(of: <reading>)[harbour]
returns in the next stanza.#editor[The repetition is deliberate.]

== Source Readings
#deixis-print-endnotes(series: "sources",
  render-group: deixis-native-render-group)
== Editorial Notes
#deixis-print-endnotes(series: "editorial")
// END EXAMPLE

#context {
  let notes = deixis-query-notes()
  assert.eq(notes.map(n => n.count), (1, 1))
  assert.eq(notes.first().marks.len(), 2)
  assert(notes.all(n => n.body.dest != none and n.body.start != none and n.body.end != none))
}
