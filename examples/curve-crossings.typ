#import "@preview/deixis:0.2.0": *
#set page(width: 500pt, height: 570pt, margin: 30pt)
#set text(size: 10pt)
#show: deixis-setup-notes

= Cross Curves Without Reshaping Them
Automatic gaps keep the original curve. Indicators are a separate choice.

#for (i, title) in ("A Plain Curved Crossing", "Cut A Gap In The Curve", "Two Curves With Optional Ticks").enumerate() {
  block(width: 440pt, height: 140pt, above: 8pt, below: 0pt, fill: rgb("f2f5f7"), radius: 4pt)[
    #place(top + left, dx: 12pt, dy: 7pt, title)
    #place(top + left, dx: 20pt, dy: 65pt, deixis-pin("left-" + str(i), padding: 0pt))
    #place(top + left, dx: 420pt, dy: 95pt, deixis-pin("right-" + str(i), padding: 0pt))
    #place(top + left, dx: 220pt, dy: 30pt, deixis-pin("top-" + str(i), padding: 0pt))
    #place(top + left, dx: 220pt, dy: 125pt, deixis-pin("bottom-" + str(i), padding: 0pt))
  ]
  let crossings = if i == 0 { none } else { (group: "panel-" + str(i), gap: 12pt) }
  deixis-connect(from: (pin: "left-" + str(i)), to: (pin: "right-" + str(i)),
    connector: (route: "curve", crossings: crossings, stroke: rgb("397894") + 1.2pt,
      via: ((relative-to: "mark", offset: (100pt, -28pt)),
        (relative-to: "mark", offset: (280pt, 42pt))), heads: "triangle",
      gap-marks: if i == 2 { "slash" } else { none }))
  deixis-connect(from: (pin: "top-" + str(i)), to: (pin: "bottom-" + str(i)),
    connector: (route: if i == 2 { "curve" } else { "polyline" }, crossings: crossings,
      via: if i == 2 { ((relative-to: "mark", offset: (-30pt, 30pt)),
        (relative-to: "mark", offset: (30pt, 65pt))) } else { none },
      stroke: rgb("b44c45") + 1.2pt, heads: "triangle", z-index: 1))
}
