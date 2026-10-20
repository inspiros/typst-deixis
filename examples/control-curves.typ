#import "@preview/deixis:0.2.0": *
#set page(width: 730pt, height: 355pt, margin: 25pt)
#set text(size: 10pt)
#show: deixis-setup-notes

= Knots And Influence Points
An interpolating curve visits its knots. A B-spline is pulled by its controls.
Both connect the same endpoints; the pale polygon shows the supplied points.

#let points = ((20pt, 95pt), (75pt, 25pt), (140pt, 120pt), (215pt, 35pt), (305pt, 95pt))
#grid(columns: (330pt, 330pt), gutter: 15pt,
  ..("curve", "b-spline").map(kind => {
    let scope = kind
    let target(i) = (name: "p" + str(i), scope: scope)
    let influences = range(1, points.len() - 1).map(i => (pin: target(i)))
    block(width: 330pt, height: 180pt, fill: rgb("f2f5f7"), radius: 4pt, {
      place(top + left, dx: 12pt, dy: 10pt,
        strong(if kind == "curve" { [Visits The Knots] } else { [Pulled By Controls] }))
      for (i, point) in points.enumerate() {
        place(top + left, dx: point.first(), dy: point.last(), {
          deixis-pin("p" + str(i), scope: scope, padding: 0pt)
          place(top + left, dx: -2pt, dy: -2pt,
            circle(radius: 2pt, fill: if i in (0, points.len() - 1) { rgb("397894") } else { orange }, stroke: none))
        })
      }
      place(top + left, curve(..(curve.move(points.first()),) + points.slice(1).map(curve.line),
        stroke: (paint: rgb("bec9d0"), thickness: 0.6pt, dash: "dashed")))
      deixis-connect(from: (pin: target(0)), to: (pin: target(points.len() - 1)),
        connector: (route: if kind == "curve" { kind } else { (kind: kind, controls: influences) },
          via: if kind == "curve" { influences } else { none },
          stroke: rgb("397894") + 1.2pt, heads: "triangle"))
    })
  }),
)

#v(12pt)
Use controls for broad bends. Keep `via` for points the connector must visit:
#raw("connector: (route: (kind: \"b-spline\", controls: ((pin: \"bend\"),)))", block: true, lang: "typst")
Control points can also use explicit mark/body/page reference frames and offsets.
