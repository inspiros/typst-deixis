#set page(width: 300pt, height: 240pt, margin: (x: 1cm, rest: 1cm))

#import "../src/lib.typ": *
#show: deixis-setup-notes
#show raw: set text(size: 0.85em)

#lorem(10)
#deixis-endnote[A plain endnote.]
#lorem(10)
#deixis-endnote(
  stroke: maroon,
  fill: maroon.transparentize(90%),
)[
  Endnotes use a different counter
][
  They default to the `"endnote"` series.
].
#lorem(10)
// print all previous notes
#deixis-print-endnotes()

#lorem(5)
#deixis-endnote[
  ```typst #deixis-print-endnotes()``` flushes out unprinted notes by default, but it can do more than that.
]
#box()<split>
This
#deixis-endnote(
  stroke: gray,
  fill: none,
)[
  invisible note
][
  This note is not supposed to be printed.
]
is added after the label ```typst #box()<split>```.
// print with filter
#deixis-print-endnotes(before: <split>)
