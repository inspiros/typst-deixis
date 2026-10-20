#import "../../src/lib.typ": *
#set page(width: 340pt, height: auto, margin: 15pt)
#set text(size: 11pt)
#set heading(numbering: none)
#show: deixis-setup-notes

// BEGIN EXAMPLE
#deixis-mark(id: <lemma>, series: "glossary",
  marker: none, data: (term: "Lemma",))[*Lemma*]
means the dictionary form of a word.
#deixis-endnote-body(of: <lemma>)[A dictionary headword.]
Later, #context {
  let n = deixis-query-notes(series: "glossary")
    .find(n => n.id == <lemma>)
  link(n.dest)[lemma]
} links to its first use.

#deixis-mark(id: <token>, series: "glossary",
  marker: none, data: (term: "Token",))[*Token*]
means one occurrence of a word.
#deixis-endnote-body(of: <token>)[One occurrence in a text.]

== Glossary
#context {
  let terms = deixis-query-notes(series: "glossary")
    .sorted(key: n => n.data.term)
  for n in terms {
    block[#strong(link(n.dest, n.data.term)): #n.summary]
  }
}
// END EXAMPLE

// The view uses safe summaries; it never prints the registered endnote bodies.
#context {
  let terms = deixis-query-notes(series: "glossary")
  assert.eq(terms.len(), 2)
  assert(terms.all(n => n.body.dest == none and n.body.start == none))
}
