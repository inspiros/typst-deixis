#import "@preview/deixis:0.2.0": *
#set page(width: 420pt, height: 260pt, margin: 30pt)
#set text(size: 10pt)
#show: deixis-setup-notes
#let badge(name, color, r) = {
  let other = (r.counterpart)()
  if other == none { return [] }
  // Shared exits still need separate labels and clickable areas.
  place(center + horizon, dx: if name == "A" { -24pt } else { 24pt },
    dy: -r.normal.last() * 8pt,
    link(other.destination, box(width: 40pt, height: 12pt, inset: 1pt,
      fill: white, stroke: color + 0.6pt, radius: 2pt,
      align(center + horizon, text(size: 7pt, fill: color, [#name ↔ #other.page])))))
}
#let card(name, color, x, incoming: false) = place(top + left, dx: x, dy: 80pt,
  deixis-attach(pins: ((name): (anchor: if incoming { top } else { bottom })),
    rect(width: 75pt, height: 28pt, fill: color.lighten(94%), stroke: color + 0.6pt,
      align(center + horizon, text(if incoming { "Target " + name } else { "Source " + name })))))
= Linking Spill Points

Each badge jumps to the accepted spill point on the other page.
Use a small `portal` when the connection is already clear; labels help at shared exits.
#card("A", blue, 35pt)
#card("B", orange.darken(15%), 245pt)
#for (name, color) in (("A", blue), ("B", orange.darken(15%))) {
  deixis-connect(from: (pin: (name: name, page: 1)), to: (pin: (name: name, page: 2)), connector: (
    route: "orthogonal", radius: 0pt, stroke: color + 1pt, heads: "triangle",
    ports: (mark: bottom, body: top),
    via: ((relative-to: "page", offset: (210pt, 180pt)), ("split", 0pt)),
    continuation: badge.with(name, color)))
}
#pagebreak()
#set page(width: 460pt, height: 300pt, margin: 35pt)
#place(top + left, dy: 130pt, block(width: 335pt)[= Follow The Paired Badge])
#card("A", blue, 35pt, incoming: true)
#card("B", orange.darken(15%), 285pt, incoming: true)
#place(top + left, dy: 160pt, block(width: 335pt)[
  Pairing follows the connection declaration, even if two connections share
  endpoints or a spill point. The remote point may have moved around an obstacle.
])
