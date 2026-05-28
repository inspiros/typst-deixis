#set page(width: 300pt, height: 240pt, margin: (right: 2.5cm, rest: 1cm))

#import "@preview/deixis:0.1.0": *
#show: deixis-setup-notes
#show raw: set text(size: 0.85em)

#set text(size: 0.9em)
#deixis-margin-note(
  stroke: blue + 0.5pt,
  fill: blue.transparentize(95%),
  link: "curve",
  link-waypoints: (
    (0pt, 20pt),
    (50pt, 40pt),
    (50pt, -50pt),
    "right-angle",  // change link type
    (60pt, 40pt),
    "straight-line",
  ),
  link-marks: "body",
  container-func: rect,
)[][
  Waypoints allow creating complicated links.
]
#deixis-margin-note(
  inline-mode: "highlight",
  stroke: red + 0.5pt,
  fill: red.transparentize(95%),
  link: "chamfer",
  container-func: rect,
)[
  Margin links always exit up or down.
][
  *Fact:* The default margin links just follow auto-generated waypoints.
]

#v(70pt)
#deixis-inset-note(
  inline-mode: "highlight",
  width: 120pt,
  stroke: (nodes: green, link: stroke(paint: green, dash: "densely-dotted")),
  fill: green.transparentize(95%),
  link: "ccr",
  link-waypoints: (
    // component anchor + alignment keywords
    (80pt, "mark-right"),
    (0pt, "body-right"),
  ),
  link-ports: (mark: right, body: right),
  link-marks: "both",
  layer: "flow",
)[
  Inset links give inline marks 3 link ports:\
  `right, top, bottom`.
][
  Inset notes (and region marks) have 4 link ports:\
  `left, right, top, bottom`.
]
