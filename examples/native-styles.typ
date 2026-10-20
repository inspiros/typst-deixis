#import "@preview/deixis:0.2.0": *
#set page(width: 540pt, height: auto, margin: (left: 35pt, right: 125pt, y: 35pt))
#set text(size: 11pt)
#show: deixis-setup-notes

= Native Borders, Separate Connection Style

#deixis-set(stroke: (
  mark: (top: blue, bottom: blue, left: orange + 1.5pt, right: teal + 1.5pt),
  body: (left: teal + 2pt, rest: none),
  connector: gray + 0.7pt,
))

This #deixis-margin-note(id: <idea>, width: 95pt,
  container-func: deixis-rect-container, container-args: (inset: 5pt),
  connector: (route: "straight-line"),
)[passage][A left border can be enough.]
has a light connection and a separate body border.

#v(14pt)
#deixis-region-mark(inline: true,
  stroke: (left: orange + 1.5pt, bottom: blue, rest: none),
  radius: (top: 4pt, bottom-right: 4pt),
)[$x^2 + y^2 = z^2$]

Native edge dictionaries work for rectangular regions and bodies. The connector
uses a single stroke, supplied by the `link` component above.
