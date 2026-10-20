#import "@preview/deixis:0.2.0": *
#set page(width: 790pt, height: 470pt, margin: 25pt)
#set text(size: 10pt)
#show: deixis-setup-notes

= Compare Interpolating Curves
Every column uses the same knots. Centripetal spacing is useful for uneven knots.

#let scenes = (
  (name: "Balanced Knots", points: ((60pt, -25pt), (135pt, 25pt))),
  (name: "Uneven Knots", points: ((15pt, 25pt), (185pt, -20pt))),
  (name: "Clustered Knots", points: ((60pt, -25pt), (60.5pt, -25pt), (180pt, 25pt))),
)
#grid(columns: (240pt,) * 3, gutter: 8pt,
  ..([*Curve*], [*Centripetal Catmull–Rom*], [*Uniform Catmull–Rom*]),
  ..scenes.enumerate().map(((i, scene)) => ("curve", "ccr", "ucr").map(kind => {
    let scope = "comparison-" + str(i) + "-" + kind
    let pin(name) = (name: name, scope: scope)
    block(width: 240pt, height: 105pt, fill: rgb("f2f5f7"), radius: 4pt, {
      place(top + left, dx: 10pt, dy: 8pt, scene.name)
      place(top + left, dx: 15pt, dy: 58pt, deixis-pin("start", scope: scope, padding: 0pt))
      place(top + left, dx: 220pt, dy: 58pt, deixis-pin("end", scope: scope, padding: 0pt))
      for (j, p) in scene.points.enumerate() {
        place(top + left, dx: 15pt + p.first(), dy: 58pt + p.last(), {
          deixis-pin("knot-" + str(j), scope: scope, padding: 0pt)
          place(top + left, dx: -1.5pt, dy: -1.5pt, circle(radius: 1.5pt, fill: orange, stroke: none))
        })
      }
      deixis-connect(from: (pin: pin("start")), to: (pin: pin("end")),
        connector: (route: kind, stroke: rgb("397894") + 1pt, heads: "triangle",
          via: scene.points.enumerate().map(((j, _)) => (pin: pin("knot-" + str(j))))))
    })
  })).flatten(),
)
