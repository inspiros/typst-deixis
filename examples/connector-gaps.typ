#import "@preview/deixis:0.2.0": *
#set page(width: 480pt, height: 310pt, margin: 30pt)
#set text(size: 10pt)
#show: deixis-setup-notes

= Mark A Deliberate Gap
Use paired ticks for a longer hidden section. A small crossing gap can stay plain.

#for (i, (name, marks)) in (("Plain", none), ("Slash", "slash"), ("Bar", "bar")).enumerate() {
  block(width: 420pt, height: 62pt, above: 5pt, below: 0pt)[
    #name
    #place(top + left, dx: 70pt, dy: 30pt, deixis-pin("start-" + str(i), padding: 0pt))
    #place(top + left, dx: 400pt, dy: 30pt, deixis-pin("end-" + str(i), padding: 0pt))
    #place(top + left, dx: 200pt, dy: 8pt,
      block(width: 90pt, height: 44pt, fill: rgb("e8f0f4"), radius: 3pt,
        align(center + horizon)[Object]))
  ]
  deixis-connect(from: (pin: "start-" + str(i)), to: (pin: "end-" + str(i)), connector: (
    route: "polyline", stroke: rgb("397894") + 1pt, heads: "triangle", gap-marks: marks,
    via: ((relative-to: "mark", offset: (120pt, 0pt)), "none",
      (relative-to: "mark", offset: (230pt, 0pt)), "polyline"),
  ))
}
