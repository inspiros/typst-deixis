#import "../../src/routing/path.typ": _deixis-render-waypoint-path
#import "../../src/lib.typ": deixis-arrowhead
#set page(width: 640pt, height: 760pt, margin: 25pt)
#set text(size: 9pt)
#let shapes = ("stealth", "triangle", "vee", "circle", "diamond", "bar")
#context grid(columns: (1fr,) * 3, gutter: 8pt,
  ..("straight-line", "right-angle", "chamfer", "curve", "ccr", "ucr").enumerate().map(((i, route)) => {
    let cases = ()
    for (j, endpoint) in ((140pt, 40pt), (40pt, 60pt), (-100pt, 40pt)).enumerate() {
      let origin = if j == 2 { (145pt, 30pt) } else { (12pt, 20pt) }
      let start = origin
      let end = (origin.at(0) + endpoint.at(0), origin.at(1) + endpoint.at(1))
      let heads = (mark: deixis-arrowhead(shape: shapes.at(i), length: 8pt, width: 7pt),
        body: deixis-arrowhead(shape: shapes.at(calc.rem(i + j, shapes.len())), length: 9pt, width: 7pt))
      cases.push(block(width: 180pt, height: 92pt, above: 0pt, below: 0pt, stroke: gray.lighten(60%) + 0.3pt, {
        text(route + " / " + shapes.at(i))
        _deixis-render-waypoint-path(..start, ..end,
          link-type: route, link-stroke: stroke(paint: blue, thickness: (0.5pt, 2pt, 4pt).at(j), cap: ("butt", "round", "square").at(j)),
          link-heads: heads, link-radius: 12pt, source-dir: "horizontal", target-dir: "vertical").join()
      }))
    }
    cases
  }).flatten(),
)
