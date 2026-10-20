#import "../../src/lib.typ": *
#set page(width: 260pt, height: auto, margin: 12pt)
#set text(size: 13pt)
#let teal = rgb("32736D")

// BEGIN EXAMPLE
#context {
  let path = deixis-route(
    from: (0pt, 25pt),
    to: (210pt, 25pt),
    route: "curve",
    via: ((70pt, 0pt), (140pt, 50pt)))
  let paint = deixis-prepare-connector(
    path, stroke: teal + 1pt,
    heads: (body: "stealth"),
    cuts: (at: 50%, length: 18pt),
    gap-marks: "slash")
  box(width: 220pt, height: 70pt,
    place(top + left, dy: 25pt,
      deixis-render-connector(paint)))
}
// END EXAMPLE
