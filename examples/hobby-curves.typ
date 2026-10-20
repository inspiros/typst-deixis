#import "@preview/deixis:0.2.0": *
#set page(width: 790pt, height: 350pt, margin: 25pt)
#set text(size: 10pt)
#show: deixis-setup-notes

= Compare Hobby Interpolation
All curves visit the orange knots. Hobby solves their tangent directions together;
its tension changes that solve as well as the handle lengths.

#let policies = (
  (name: "Centripetal Catmull–Rom", route: "ccr"),
  (name: "Hobby", route: "hobby"),
  (name: "Hobby With Tension 2", route: (kind: "hobby", tension: 2)),
)
#grid(columns: (240pt,) * 3, gutter: 8pt,
  ..policies.map(policy => {
    let scope = policy.name
    let pin(i) = (name: "p" + str(i), scope: scope)
    let points = ((15pt, 85pt), (55pt, 45pt), (125pt, 105pt), (220pt, 65pt))
    block(width: 240pt, height: 155pt, fill: rgb("f2f5f7"), radius: 4pt, {
      place(top + left, dx: 10pt, dy: 10pt, strong(policy.name))
      for (i, point) in points.enumerate() {
        place(top + left, dx: point.first(), dy: point.last(), {
          deixis-pin("p" + str(i), scope: scope, padding: 0pt)
          place(top + left, dx: -2pt, dy: -2pt, circle(radius: 2pt, fill: orange, stroke: none))
        })
      }
      deixis-connect(from: (pin: pin(0)), to: (pin: pin(3)), connector: (
        route: policy.route, via: ((pin: pin(1)), (pin: pin(2))),
        stroke: rgb("397894") + 1.1pt, heads: "triangle"))
    })
  }),
)

#v(12pt)
Start with `connector: (route: "hobby")`. For free endpoints, curl adjusts the
boundary condition (default `1`); a fixed port direction takes priority.
#raw("connector: (route: (kind: \"hobby\", tension: 1.5, curl: (mark: 0, body: 1)))", block: true, lang: "typst")
Hobby is a stylistic choice: tight turns and uneven spacing can still overshoot.
