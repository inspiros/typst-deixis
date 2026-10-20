#import "@preview/deixis:0.2.0": *
#set page(width: 500pt, height: 450pt, margin: 30pt)
#set text(size: 10pt)
#show: deixis-setup-notes

= Choose Which Line Passes Over
Enable crossing gaps on participating lines. Priority chooses the overpass.

#for (i, title) in ("A Plain Crossing", "Enable A Gap", "Choose The Overpass").enumerate() {
  block(width: 440pt, height: 100pt, above: 8pt, below: 0pt, fill: rgb("f2f5f7"), radius: 4pt)[
    #place(top + left, dx: 12pt, dy: 7pt, title)
    #place(top + left, dx: 20pt, dy: 60pt, deixis-pin("left-" + str(i), padding: 0pt))
    #place(top + left, dx: 420pt, dy: 60pt, deixis-pin("right-" + str(i), padding: 0pt))
    #place(top + left, dx: 220pt, dy: 30pt, deixis-pin("top-" + str(i), padding: 0pt))
    #place(top + left, dx: 220pt, dy: 90pt, deixis-pin("bottom-" + str(i), padding: 0pt))
  ]
  let crossings = if i == 0 { none } else { (group: "panel-" + str(i), gap: 10pt) }
  deixis-connect(from: (pin: "left-" + str(i)), to: (pin: "right-" + str(i)),
    connector: (crossings: crossings, stroke: rgb("397894") + 1.2pt,
      heads: "triangle", z-index: if i == 2 { 2 } else { 0 }))
  deixis-connect(from: (pin: "top-" + str(i)), to: (pin: "bottom-" + str(i)),
    connector: (crossings: crossings, stroke: rgb("b44c45") + 1.2pt, heads: "triangle", z-index: 1))
}
