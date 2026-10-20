#import "@preview/deixis:0.2.0": *
#set page(width: 510pt, height: 315pt, margin: 30pt)
#set text(size: 11pt)
#show: deixis-setup-notes

#text(size: 19pt, weight: "bold")[Pins Can Connect Anything]

Attach a socket to a card, route through a pin, then enter another card.

#let card(name, color, body) = deixis-attach(prefix: none,
  pins: ((name, (anchor: if name == <out> { right } else { left })),),
  rect(width: 120pt, height: 62pt, radius: 6pt, stroke: color + 0.7pt,
    fill: color.lighten(93%), align(center + horizon, body)))

#place(top + left, dx: 0pt, dy: 105pt, card(<out>, teal)[Source card])
#place(top + left, dx: 310pt, dy: 155pt, card(<in>, blue)[Destination card])
#place(top + left, dx: 220pt, dy: 95pt, {
  deixis-pin(<bend>, padding: 0pt)
  place(top + left, dx: -2.5pt, dy: -2.5pt, circle(radius: 2.5pt, fill: orange, stroke: none))
})

#deixis-connect(from: (pin: <out>), to: (pin: <in>),
  connector: (route: "curve", stroke: teal + 1pt,
    ports: (mark: (side: right, gap: 3pt), body: (side: left, gap: 3pt)),
    via: ((pin: <bend>),), heads: (body: "triangle")))

#place(top + left, dy: 240pt, text(size: 9pt, fill: gray)[
  `from: (pin: <out>)` · `via: ((pin: <bend>),)` · `to: (pin: <in>)`
])
