#import "@preview/deixis:0.2.0": *
#set page(width: 540pt, height: 310pt, margin: 40pt)
#set text(size: 11pt)
#show: deixis-setup-notes

= Choose Which Note Stays On Top

// z-index applies within a page overlay. The default is 0.
#let at(x, y) = body => place(top + left, dx: x, dy: y, body)
#let callout = deixis-inset-note.with(
  layer: "foreground", width: 185pt,
  container-args: (inset: 10pt),
  fill: white, connector: (route: "curve", heads: (body: "triangle")),
)

#callout(z-index: 2, stroke: blue, placement: at(215pt, 85pt))[Key point][
  *Priority 2:* this explanation stays on top where the boxes overlap.
]

#v(38pt)
#callout(stroke: orange, placement: at(240pt, 118pt))[Supporting detail][
  *Priority 0:* this later note stays behind the blue box.
]

#v(90pt)
Use `z-index: 2` to raise a note. For independent control, use
`z-index: (body: 2, connector: -1)` or `connector: (z-index: 3)`.
