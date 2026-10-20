#import "@preview/deixis:0.2.0": *
#set page(width: 520pt, height: 300pt, margin: 25pt)
#set text(size: 10pt)

= Routing Without Notes
Use known coordinates directly. No setup or invisible anchors are needed.

#let path = deixis-route(
  from: (point: (110pt, 85pt), normal: right),
  to: (point: (350pt, 145pt), normal: left),
  route: "hobby", via: ((190pt, 55pt), (265pt, 130pt)),
)
#context {
  let drawing = deixis-prepare-connector(path, stroke: teal + 1.2pt, heads: "triangle")
  place(top + left, dx: path.origin.first(), dy: path.origin.last(), deixis-render-connector(drawing))
}
#let card(x, y, color, body) = place(top + left, dx: x, dy: y,
  rect(width: 100pt, height: 50pt, radius: 5pt, fill: color.lighten(92%),
    stroke: color + 0.7pt, align(center + horizon, body)))
#card(10pt, 60pt, teal)[Custom Source]
#card(350pt, 120pt, blue)[Custom Destination]

#place(top + left, dy: 205pt)[
  `deixis-route` returns source-local line/cubic records.
  `deixis-prepare-connector` adds heads, trimming and optional cuts.
  Your renderer can consume either stage.
]
