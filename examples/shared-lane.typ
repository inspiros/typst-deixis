#import "@preview/deixis:0.2.0": *
#set page(width: 350pt, height: 290pt, margin: 20pt)
#set text(size: 10pt)
#show: deixis-setup-notes
#show: deixis-routing.with(policy: "manual")
= Deliberately Sharing A Lane

#deixis-attach(pins: (
  lane-start: (dx: 30%, dy: 0%),
  lane-end: (dx: 70%, dy: 0%),
))[
  #v(22pt)
  #grid(columns: (55pt, 20pt, 105pt, 65pt), align: center + horizon,
    deixis-attach(id: <source>, pins: (
      outlet: (anchor: top, offset: (8pt, 0pt)),
    ))[#rect(width: 55pt, height: 50pt, radius: 3pt, inset: 5pt)[Source]],
    deixis-attach(behavior: "avoid", rect(width: 20pt, height: 22pt,
      fill: luma(220), stroke: none)), [],
    deixis-attach(id: <target>)[#rect(width: 65pt, height: 50pt,
      radius: 3pt, inset: 5pt)[Target]],
  )
]

#let lane = (
  (route: "orthogonal", via: ((pin: <lane-start>),)),
  (route: "polyline", via: ((pin: <lane-end>),)),
  (route: "orthogonal"),
)
#deixis-connect(from: (node: <source>), to: (node: <target>), connector: (
  ports: (mark: top, body: top), segments: lane,
  stroke: blue + 2.5pt, heads: "triangle"))
#deixis-connect(from: (node: <source>), to: (node: <target>), connector: (
  ports: (mark: (pin: <outlet>, side: top), body: bottom), segments: lane,
  stroke: orange + 1pt, heads: "triangle"))

The two exact pins bound a straight shared segment, with orthogonal approaches.
Manual routing preserves this path without automatic collision search.
The later, thinner orange shaft paints over blue on their common segment.
Obstacle-only `policy: "avoid"` also permits overlap, but chooses its own path
between exact visits instead of accepting mixed route sections.
