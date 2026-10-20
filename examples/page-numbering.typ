#import "@preview/deixis:0.2.0": *
#set page(width: 340pt, height: 320pt, margin: 30pt, numbering: "1")
#set text(size: 11pt)
#show: deixis-setup-notes
#let note = deixis-footnote.with(numbering: (restart: "page", pattern: "1"))

= Footnotes By Page

#for i in range(12) [
  A useful observation#note(id: label("observation-" + str(i)))[
    Supporting detail #(i + 1).
  ] stays close to its source. #lorem(14)
  #parbreak()
]

#pagebreak()
= One Original, One Marker

A later use#deixis-mark(of: <observation-0>) keeps the first note's marker,
even on another page. Its identity and assigned count stay unchanged.
This page's first new note#note[The page-local sequence starts at one.] also uses 1.
Use the links to tell the two explanations apart; reuse never creates a new note.

// For symbols, replace pattern: "1" with pattern: "*".
// A separate series creates a separate page-local sequence.
