#import "@preview/deixis:0.2.0": *
#set page(width: 480pt, height: auto, margin: 35pt)
#set text(size: 11pt)
#show: deixis-setup-notes

#text(size: 19pt, weight: "bold")[Connect To A Body In The Text]

An explanation can stay in the normal document flow and still receive an arrow.

#deixis-mark(id: <idea>, inline-mode: "underline", stroke: teal)[A new idea]
deserves a short explanation.

#v(22pt)
Here it is: #deixis-inline-note-body(of: <idea>, inline: true,
  breakable: false, inline-mode: "box", stroke: teal,
  fill: teal.lighten(94%))[a useful connection].

#deixis-connect(from: <idea>, to: <idea>, connector: (
  route: "curve", stroke: teal + 0.8pt,
  ports: (mark: (side: bottom, at: 50%), body: (side: top, at: 50%, gap: 2pt)),
  heads: (body: "triangle"),
))

#v(15pt)
```typst
#deixis-mark(id: <idea>)[A new idea]
#deixis-inline-note-body(of: <idea>,
  inline: true, breakable: false)[Explanation]
#deixis-connect(from: <idea>, to: <idea>)
```

`breakable: false` keeps the body in one native frame. The same option works for
a block body with `inline: false`. Connections use the painted frame and add no
extra body or counter value.
