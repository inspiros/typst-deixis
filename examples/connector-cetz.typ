#set page(width: 600pt, height: 260pt, margin: 50pt)
#import "@preview/deixis:0.2.0": *
#import "@preview/cetz:0.5.2"
#show: deixis-setup-notes

// Optional adapter: CeTZ renders the head; Deixis owns routing and trimming.
// The canvas bounds are translated back to a tip at the local origin. Positive
// canvas y is reversed so it matches Deixis's native y-down coordinate frame.
#let cetz-head(request) = {
  let l = request.length / 1pt
  let w = request.width / 1pt
  let drawing = cetz.canvas(length: 1pt, y: -1, {
    cetz.draw.line((0, -w / 2), (l, 0), (0, w / 2), (l * 0.25, 0), close: true,
      fill: request.fill, stroke: none)
  })
  (
    body: place(top + left, dx: -request.length, dy: -request.width / 2, drawing),
    trim: request.length * 0.75 - 0.15pt,
    bounds: (left: -request.length, top: -request.width / 2, right: 0pt, bottom: request.width / 2),
  )
}

= A Third-Party Head
The package runtime does not depend on CeTZ.

#v(20pt)
#deixis-inset-note(layer: "foreground", width: 150pt, dx: 170pt, dy: 25pt,
  connector: (
    route: "catmull-rom-centripetal",
    ports: (mark: right, body: left),
    heads: (body: deixis-arrowhead(render: cetz-head, length: 11pt, width: 8pt)),
    stroke: purple + 1pt,
  ),
)[Custom][Drawn with CeTZ.]
