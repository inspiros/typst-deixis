#set page(width: 600pt, height: 580pt, margin: 50pt)
#import "@preview/deixis:0.2.0": *
#show: deixis-setup-notes

= Connector Heads
Native shapes share the same routing and endpoint contract.
#parbreak()
#v(12pt)

#for (i, shape) in ("stealth", "triangle", "vee", "circle", "diamond", "bar").enumerate() {
  block(height: 56pt, above: 0pt, below: 0pt)[
    #deixis-inset-note(layer: "foreground", width: 170pt, dx: 180pt, dy: 0pt,
      stroke: (connector: blue + 1pt, nodes: gray + 0.5pt),
      connector: (
        route: "orthogonal",
        ports: (mark: right, body: left),
        heads: (body: deixis-arrowhead(shape: shape, length: 9pt, width: 7pt)),
      ),
    )[#shape][A #shape head.]
  ]
}
