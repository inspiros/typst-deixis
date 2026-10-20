#import "../../src/lib.typ": *
#set page(width: 280pt, height: 150pt, margin: (left: 10pt, right: 95pt, y: 15pt))
#set text(size: 13pt)
#show: deixis-setup-notes

// BEGIN EXAMPLE
#deixis-set(palette: (
  rgb("3B6D9A"), rgb("387C69"),
  rgb("9A663F"),
))
#for i in range(3) {
  deixis-margin-note(width: 70pt,
    side: right)[Passage][
    Explanation #(i + 1).
  ]
  v(20pt)
}
// END EXAMPLE
