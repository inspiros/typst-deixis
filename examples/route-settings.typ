#import "@preview/deixis:0.2.0": *
#set page(width: 790pt, height: 465pt, margin: 25pt)
#set text(size: 10pt)
#show: deixis-setup-notes

= Adjust Curve Handles
The orange knots stay fixed. Larger tension shortens the handles; `1` keeps the default shape.

#let families = (
  (name: "Simple Curve", kind: "curve"),
  (name: "Centripetal Catmull–Rom", kind: "catmull-rom"),
  (name: "Uniform Catmull–Rom", kind: "catmull-rom", parameterization: "uniform"),
)
#grid(columns: (240pt,) * 3, gutter: 8pt,
  ..([*Tension 0.5*], [*Tension 1*], [*Tension 2*]),
  ..families.enumerate().map(((i, family)) => (0.5, 1, 2).map(tension => {
    let scope = "handles-" + str(i) + "-" + str(tension)
    let pin(name) = (name: name, scope: scope)
    let route = (kind: family.kind, tension: tension)
    if "parameterization" in family { route.parameterization = family.parameterization }
    block(width: 240pt, height: 105pt, fill: rgb("f2f5f7"), radius: 4pt, {
      place(top + left, dx: 10pt, dy: 8pt, family.name)
      for (name, x, y) in (("start", 15pt, 70pt), ("knot", 80pt, 43pt), ("end", 220pt, 70pt)) {
        place(top + left, dx: x, dy: y, {
          deixis-pin(name, scope: scope, padding: 0pt)
          place(top + left, dx: -1.5pt, dy: -1.5pt, circle(radius: 1.5pt, fill: orange, stroke: none))
        })
      }
      deixis-connect(from: (pin: pin("start")), to: (pin: pin("end")),
        connector: (route: route, via: ((pin: pin("knot")),),
          stroke: rgb("397894") + 1pt, heads: "triangle"))
    })
  })).flatten(),
)

#v(10pt)
The route name remains enough for ordinary use. Add settings only when needed:
#raw("connector: (route: (kind: \"curve\", tension: 2), heads: \"triangle\")", lang: "typst")
