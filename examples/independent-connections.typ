#import "@preview/deixis:0.2.0": *
#set page(width: 550pt, height: 300pt, margin: 35pt)
#set text(size: 11pt)
#show: deixis-setup-notes

#text(size: 19pt, weight: "bold")[Two Passages, One Explanation]

#deixis-inset-note(id: <shared>, connector: none,
  layer: "foreground", width: 135pt, dx: 230pt, dy: 45pt,
  stroke: (mark: teal, body: teal), fill: (body: rgb("edf5f3")),
)[First passage][The body stays here. Each connection chooses its own route and style.]

#v(70pt)
#deixis-mark(of: <shared>, occurrence: <again>, stroke: teal)[Another passage]

#deixis-connect(from: <shared>, to: <shared>,
  connector: (route: "curve", stroke: teal + 0.8pt, heads: (body: "triangle"),
    ports: (body: (side: left, at: 25%))))
#deixis-connect(from: (mark: <shared>, occurrence: <again>), to: <shared>,
  connector: (route: "curve", stroke: orange + 0.8pt, heads: (body: "circle"),
    ports: (body: (side: left, at: 75%))))

#v(30pt)
```typst
#deixis-connect(
  from: (mark: <shared>, occurrence: <again>),
  to: <shared>,
)
```
