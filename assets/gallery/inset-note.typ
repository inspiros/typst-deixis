#set page(width: 300pt, height: 240pt, margin: (x: 1cm, rest: 1cm))

#import "../../src/lib.typ": *
#show: deixis-setup-notes
#show raw: set text(size: 0.85em)

Inset notes can be placed
#deixis-inset-note(
  stroke: orange,
  fill: yellow.transparentize(90%),
  link: "right-angle",
  link-ports: (mark: right, body: bottom),
  link-marks: "both",
  placement: body => deixis-absolute-place(top + right, dx: -5pt, dy: 5pt, body),
)[anywhere][A manually placed note.]

- #lorem(2)
- #lorem(3)#deixis-inset-note(
  marker: none,
  stroke: red,
  fill: red.transparentize(95%),
  link: "straight-line",
  link-marks: "mark",
  width: 4.5cm,
  dx: 1em,
  dy: 0pt,
  anchor: (mark: right + horizon, body: left + horizon),
  layer: "flow",
)[Alternatively, use `dx`, `dy`, and `anchor` to align the body.]
- #lorem(2)

#import "@preview/meander:0.4.2"
#import "@preview/colorful-boxes:1.4.3": outline-colorbox

#let note-body = deixis-inset-note-body(
  id: <meander>,
  width: 50%,
  stroke: purple,
  fill: purple.transparentize(95%),
  layer: "flow",  // important !!!
  container-func: (body, ..args) => outline-colorbox(body,
    color: (stroke: args.at("stroke").paint, fill: args.at("fill")),
    stroke: args.at("stroke").thickness,
    title: args.at("title", default: [Note])),
  title: [`meander` note],
)[A _true_ inset note.]
#meander.reflow({
  import meander: *

  placed(horizon + right, note-body)
  container()
  content[
    #set par(justify: true)
    Text will wrap around this note
    #deixis-inline-mark(id: <meander>).
    Note that you must set ```typc layer: "flow"``` (render immediately) for this to work.
    #lorem(29)
  ]
})
