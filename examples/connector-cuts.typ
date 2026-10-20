#import "@preview/deixis:0.2.0": *
#set page(width: 480pt, height: 430pt, margin: 30pt)
#set text(size: 10pt)
#show: deixis-setup-notes

= Cut The Curve Without Bending It
Each row uses the same route. Cuts only hide intervals of that route.

#for (i, title) in ("Original Curve", "Cut A Middle Interval", "Add Optional Ticks").enumerate() {
  block(width: 420pt, height: 95pt, above: 5pt, below: 0pt)[
    #title
    #place(top + left, dx: 65pt, dy: 50pt, deixis-pin("source-" + str(i), padding: 0pt))
    #place(top + left, dx: 390pt, dy: 50pt, deixis-pin("target-" + str(i), padding: 0pt))
  ]
  deixis-connect(from: (pin: "source-" + str(i)), to: (pin: "target-" + str(i)), connector: (
    route: "curve", stroke: rgb("397894") + 1pt, heads: "triangle",
    via: ((relative-to: "mark", offset: (80pt, -30pt)),
      (relative-to: "mark", offset: (230pt, 30pt))),
    cuts: if i == 0 { none } else { (at: 50%, length: 36pt) },
    gap-marks: if i == 2 { "slash" } else { none },
  ))
}
