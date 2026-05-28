#set page(width: 300pt, height: 240pt, margin: (x: 2.5cm, rest: 1cm))

#import "../src/lib.typ": *
#show: deixis-setup-notes
#show raw: set text(size: 0.85em)

#let todo = deixis-margin-note.with(
  series: "todo",
  stroke: red,
  fill: red.transparentize(95%),
  link: "right-angle",
  container-func: rect,
)
#let first-author = deixis-margin-note.with(
  series: "comm",
  stroke: blue,
  fill: blue.transparentize(95%),
  link: "right-angle",
  container-func: rect,
)
#let second-author = deixis-margin-note.with(
  series: "comm",
  stroke: teal,
  fill: teal.transparentize(95%),
  link: "right-angle",
  container-func: rect,
)
#let remark = deixis-margin-note.with(
  marker: "",
  series: "remark",
  stroke: maroon,
  fill: maroon.transparentize(95%),
  link: "right-angle",
  container-func: rect,
)

#lorem(3)
#todo[Rewrite this sentence.]
#lorem(3)
#first-author[Good point.]
#lorem(2)
#deixis-update-note-counter(0, series: "todo")
#todo[```typc "todo"``` restarts from 1 again.].

#lorem(7)
#second-author[But ```typc "comm"``` is unaffected.]
#lorem(2)
#deixis-update-note-counter(0)  // no effect
#first-author[][This keeps counting up.]
#second-author[][Use an empty mark `[]` to avoid overlapping highlight box.]
#lorem(10)
#remark[*Remark:* ```typst #deixis-update-note-counter``` defaults to the ```typc "default"``` series!]

Counter values: \
```typc "default"```: #context deixis-note-counter(series: "default") \
```typc "todo"```: #context deixis-note-counter(series: "todo") \
```typc "comm"```:  #context deixis-note-counter(series: "comm")
