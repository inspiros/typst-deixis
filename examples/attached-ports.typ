#import "@preview/deixis:0.2.0": *
#set page(width: 350pt, height: 255pt, margin: 20pt)
#set text(size: 10pt)
#show: deixis-setup-notes
#show: deixis-routing
= Ports On Attached Content

#v(20pt)
#grid(columns: (55pt, 20pt, 105pt, 65pt), align: center + horizon,
  deixis-attach(id: <source>, pins: (
    outlet: (anchor: top, offset: (8pt, 0pt)),
    corner: (anchor: bottom + left),
    center: (anchor: center + horizon),
  ))[#rect(width: 55pt, height: 50pt, radius: 3pt, inset: 5pt)[Source]],
  deixis-attach(behavior: "avoid", rect(width: 20pt, height: 22pt,
    fill: luma(220), stroke: none)),
  [],
  deixis-attach(id: <target>)[#rect(width: 65pt, height: 50pt,
    radius: 3pt, inset: 5pt)[Target]],
)

#deixis-connect(from: (node: <source>), to: (node: <target>),
  connector: (stroke: blue + 1pt, heads: "triangle"))
#deixis-connect(from: (node: <source>), to: (node: <target>), connector: (
  ports: (mark: (pin: <outlet>, side: top), body: (side: bottom, at: 50%)),
  stroke: orange + 1pt, heads: "triangle"))

Blue chooses among the four side midpoints and recovers when the preferred
exit is blocked. Orange uses an exact attached pin, then approaches the target
along its bottom side. Pins can be placed anywhere on the content; no fixed
number of pins is required.
