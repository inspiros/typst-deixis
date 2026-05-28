#set page(width: 300pt, height: 240pt, margin: (x: 2.5cm, rest: 1cm))

#import "../src/lib.typ": *
#show: deixis-setup-notes
#show raw: set text(size: 0.85em)

If ```typc spillover: true```, and both margins
#deixis-margin-note(
  stroke: red,
  link: "right-angle",
  container-func: rect,
)[
  #lorem(20)
]
in one page has been filled
#deixis-margin-note[
  #lorem(28)
].

Subsequent notes
#deixis-margin-note[
  A spilled note.
]
will be _spilled_ to the next page
#deixis-margin-note[
  Margin notes cannot create new pages, one needs to use ```typst #pagebreak()``` manually.
]
if possible
#deixis-margin-note(
  stroke: orange,
  link: "right-angle",
  container-func: rect,
)[
  A spilled note with link crossing page border.
].

#pagebreak()
