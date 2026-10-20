#import "@preview/deixis:0.2.0": *
#set page(width: 340pt, height: 285pt, margin: 20pt)
#set text(size: 10pt)
#show: deixis-setup-notes
#show: deixis-routing.with(spacing: 8pt)
= Routing Objects In Place

#let card(id, body) = deixis-attach(id: id,
  rect(width: 52pt, height: 30pt, radius: 3pt, fill: luma(245),
    stroke: luma(160) + 0.6pt, align(center + horizon, body)))
#grid(columns: (52pt, 90pt, 64pt), rows: (34pt, 54pt, 34pt),
  column-gutter: 22pt, row-gutter: 10pt, align: center + horizon,
  grid.cell(x: 0, y: 1, card(<source>)[Source]),
  grid.cell(x: 2, y: 0, card(<first>)[First]),
  grid.cell(x: 2, y: 2, card(<second>)[Second]),
  grid.cell(x: 1, y: 0, rowspan: 3,
    deixis-attach(behavior: "avoid", rect(width: 40pt, height: 110pt,
      fill: luma(230), stroke: none))),
)

#deixis-connect(from: (node: <source>), to: (node: <first>),
  connector: (stroke: blue + 1pt, heads: "triangle"))
#deixis-connect(from: (node: <source>), to: (node: <second>),
  connector: (stroke: orange + 1pt, heads: "triangle"))

Objects register their own bounds. Declare connections separately; the wrapper
plans them together after layout. Either declaration can also come first.
