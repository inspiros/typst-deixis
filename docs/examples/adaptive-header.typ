#import "../../src/lib.typ": *
#set page(width: 320pt, height: 170pt,
  margin: (x: 15pt, top: 30pt, bottom: 15pt), numbering: "1")
#set text(size: 11pt)
#show: deixis-setup-notes

// BEGIN EXAMPLE
#let header = context {
  let notes = deixis-query-notes(
    include-types: "endnote",
    page: here().page())
  if notes.len() > 0 {
    let pages = notes.map(n =>
      n.marks.map(m => m.dest.page())
    ).flatten().dedup().sorted()
    text(size: 9pt)[
      Notes For Pages
      #pages.map(str).join([, ])
    ]
  }
}
#set page(header: header)

Our #deixis-endnote(
  id: <method>,
)[
  method
][An explanation of the method.]
needs context.
#pagebreak()
Use the #deixis-mark(
  of: <method>,
)[
  method again
].
#deixis-print-endnotes()
// END EXAMPLE
