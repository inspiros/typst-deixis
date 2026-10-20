#import "@preview/deixis:0.2.0": *
#set page(width: 420pt, height: 290pt, margin: 28pt)
#set text(size: 10pt)

= Filled And Open Arrow Tips

Compare a sharply opened filled tip with the thin stroked `vee`.
#v(10pt)

#for (i, shape) in ("triangle", "stealth", "vee").enumerate() {
  block(height: 40pt, above: 0pt, below: 0pt)[
    #shape
    #context {
      let route = deixis-route(from: (90pt, 12pt), to: (325pt, 12pt))
      let request = deixis-prepare-connector(route, stroke: blue + 1pt,
        heads: deixis-arrowhead(shape: shape, length: 10pt, width: 9pt))
      place(top + left, dx: route.origin.first(), dy: route.origin.last(),
        deixis-render-connector(request))
    }
  ]
}
