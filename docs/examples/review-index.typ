#import "../../src/lib.typ": *
#set page(width: 340pt, height: auto, margin: 15pt)
#set text(size: 11pt)
#set heading(numbering: none)
#show: deixis-setup-notes

// BEGIN EXAMPLE
#let comment = deixis-endnote.with(series: "review")
The result is #comment(data: (
  author: "Ada", status: "open", title: [Check Scope],
))[general][Does the argument cover the boundary case?].
The #comment(data: (
  author: "Lin", status: "resolved", title: [Name The Source],
))[source][The citation has been added.] is now identified.
#deixis-print-endnotes(series: "review")

== Open Comments By Ada
#context {
  let pending = deixis-query-notes(series: "review")
    .filter(n => n.data.author == "Ada"
      and n.data.status == "open")
  for n in pending {
    block(link(n.dest)[#n.marker #n.data.title])
  }
}
// END EXAMPLE

#context {
  let notes = deixis-query-notes(series: "review")
  assert.eq(notes.len(), 2)
  assert.eq(notes.filter(n => n.data.author == "Ada" and n.data.status == "open").len(), 1)
  assert(notes.all(n => n.body.dest != none))
}
