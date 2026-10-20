#import "@preview/deixis:0.2.0": *
#set page(width: 420pt, height: 260pt, margin: 30pt)
#set text(size: 11pt)
#show: deixis-setup-notes
#let marker(name, color, request) = {
  if request.peer == none { return [] }
  // Each link has its own label and hit area, even at a shared relay point.
  let dx = if name == "A" { -24pt } else { 24pt }
  place(center + horizon, dx: dx, dy: -request.normal.last() * 8pt,
    link(request.peer.destination, box(width: 40pt, height: 12pt, inset: 1pt,
      fill: white, stroke: color + 0.6pt, radius: 2pt, align(center + horizon,
        text(size: 7pt, fill: color, [#name ↔ #request.peer-page])))))
}
#let source(name, color, x) = place(top + left, dx: x, dy: 80pt,
  deixis-attach(prefix: none, pins: (("source-" + name, (anchor: bottom + center)),),
    rect(width: 80pt, height: 30pt, fill: color.lighten(94%), stroke: color + 0.7pt,
      align(center + horizon)[Source #name])))
#let target(name, color, x) = place(top + left, dx: x, dy: 75pt,
  deixis-attach(prefix: none, pins: (("target-" + name, (anchor: top + center)),),
    rect(width: 80pt, height: 30pt, fill: color.lighten(94%), stroke: color + 0.7pt,
      align(center + horizon)[Target #name])))
= Two Links At One Exit
#block(width: 330pt)[The shafts share an exit. Separate named badges let the reader choose the link.]
#source("A", blue, 35pt)
#source("B", orange.darken(15%), 245pt)
#for (name, color) in (("A", blue), ("B", orange.darken(15%))) {
  deixis-connect(from: (pin: "source-" + name), to: (pin: "target-" + name),
    connector: (route: "orthogonal", radius: 0pt, stroke: color + 1pt, heads: "triangle",
      ports: (mark: bottom, body: top),
      via: ((relative-to: "page", offset: (210pt, 190pt)), ("split", 0pt)),
      continuation: marker.with(name, color)))
}
#pagebreak()
#set page(width: 460pt, height: 300pt, margin: 35pt)
#block(width: 110pt)[= Follow Either Direction]
#target("A", blue, 35pt)
#target("B", orange.darken(15%), 285pt)
#place(top + left, dy: 150pt,
  block(width: 330pt)[Each incoming badge returns to its own source. Links target the real nodes; they do not depend on the other badge's position.])
