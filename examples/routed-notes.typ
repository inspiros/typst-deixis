#import "@preview/deixis:0.2.0": *
#set page(width: 420pt, height: 290pt, margin: (left: 25pt, right: 105pt, y: 25pt))
#set text(size: 10pt)
#show: deixis-setup-notes
#show: deixis-routing.with(policy: "avoid")
= Routing Note Connectors

#let arrow = (route: "orthogonal", radius: 0pt, heads: "triangle")
#place(top + left, dx: 135pt, dy: 45pt,
  deixis-attach(behavior: "avoid", rect(width: 35pt, height: 75pt,
    fill: luma(225), stroke: none)))

#v(14pt)
#deixis-inset-note(width: 75pt, layer: "foreground", stroke: blue,
  placement: x => place(top + left, dx: 215pt, dy: 95pt, x),
  connector: arrow + (ports: (mark: right, body: left)))[A Callout][
  This body stays where it was placed.
]

#v(14pt)
#deixis-margin-note(width: 75pt, side: right, stroke: orange,
  connector: arrow)[A Margin Note][
  Margin placement still owns this body's position.
]

#v(105pt)
Both shorthand connectors use the surrounding routing policy and avoid the
registered gray object. Change it to `"separate"` to also try separating their
shafts, or use `"manual"` for their native paths.
