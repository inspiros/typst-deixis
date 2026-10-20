#import "../../src/lib.typ": *
#set page(width: 260pt, height: auto, margin: 12pt)
#set text(size: 13pt)
#let teal = rgb("32736D")

// BEGIN EXAMPLE
#for shape in ("stealth", "triangle",
  "vee", "circle", "diamond", "bar") {
  context {
    let path = deixis-route(
      from: (0pt, 0pt),
      to: (105pt, 0pt))
    let paint = deixis-prepare-connector(
      path, stroke: teal + 1pt,
      heads: (body: shape))
    box(width: 120pt, height: 16pt,
      deixis-render-connector(paint))
    text(size: 9pt, shape)
    linebreak()
  }
}
// END EXAMPLE
