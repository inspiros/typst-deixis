#import "@preview/deixis:0.2.0": *
#set page(width: 550pt, height: 310pt, margin: (x: 100pt, y: 35pt))
#set text(size: 11pt)
#show: deixis-setup-notes

#text(size: 19pt, weight: "bold")[Put The Line Where It Belongs]

#deixis-inset-note(layer: "foreground", width: 115pt, dx: 130pt, dy: 40pt,
  connector: (route: "curve", layer: "background", heads: (body: "triangle")),
)[A foreground note][Its connector sits behind the page content.]

#v(85pt)
A margin body can sit in the background#deixis-margin-note(
  layer: "background", width: 75pt, side: right,
  connector: (route: "curve", heads: (body: "circle")),
)[The line still uses the foreground default.].

#v(20pt)
```typst
connector: (route: "curve", layer: "background")
```
