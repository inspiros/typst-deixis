#import "@preview/deixis:0.2.0": *
#set page(width: 500pt, height: 495pt, margin: 30pt)
#set text(size: 10pt)
#show: deixis-setup-notes

#let point(name, x, y) = place(top + left, dx: x, dy: y,
  deixis-pin(name, padding: 0pt))
#let blue-line = rgb("397894") + 1.2pt
#let red-line = rgb("b44c45") + 1.2pt
#let halo(request) = {
  deixis-render-connector(request + (
    stroke: stroke(paint: white, thickness: request.stroke.thickness + 4pt, cap: "round"),
    heads: (mark: none, body: none),
    gap-marks: none,
  ))
  deixis-render-connector(request)
}

= Pass Under An Object
The background connector passes behind an opaque native block.
#block(width: 440pt, height: 85pt, above: 8pt, below: 8pt)[
  #point("under-start", 20pt, 40pt)#point("under-end", 420pt, 40pt)
  #place(top + left, dx: 155pt, dy: 10pt,
    block(width: 130pt, height: 60pt, fill: rgb("e6eef2"), radius: 4pt,
      align(center + horizon)[Opaque Object]))
]
#deixis-connect(from: (pin: "under-start"), to: (pin: "under-end"),
  connector: (route: "polyline", layer: "background", stroke: blue-line, heads: "triangle"))

= Give A Crossing Line A Halo
The higher-priority line paints a narrow background-colored band first.
#block(width: 440pt, height: 85pt, above: 8pt, below: 8pt)[
  #point("halo-left", 20pt, 40pt)#point("halo-right", 420pt, 40pt)
  #point("halo-top", 220pt, 5pt)#point("halo-bottom", 220pt, 75pt)
]
#deixis-connect(from: (pin: "halo-left"), to: (pin: "halo-right"),
  connector: (route: "polyline", stroke: blue-line, heads: "triangle"))
#deixis-connect(from: (pin: "halo-top"), to: (pin: "halo-bottom"),
  connector: (route: "polyline", stroke: red-line, heads: "triangle", render: halo, z-index: 1))

= Leave A True Gap
An undrawn segment leaves a gap without painting over the background.
#block(width: 440pt, height: 85pt, above: 8pt, below: 0pt)[
  #point("gap-left", 20pt, 40pt)#point("gap-right", 420pt, 40pt)
  #point("gap-top", 220pt, 5pt)#point("gap-bottom", 220pt, 75pt)
]
#deixis-connect(from: (pin: "gap-left"), to: (pin: "gap-right"), connector: (
  stroke: blue-line, heads: "triangle",
  segments: (
    (route: "polyline", via: ((relative-to: "mark", offset: (194pt, 0pt)),)),
    (route: "none", via: ((relative-to: "mark", offset: (206pt, 0pt)),)),
    (route: "polyline"),
  ),
))
#deixis-connect(from: (pin: "gap-top"), to: (pin: "gap-bottom"),
  connector: (route: "polyline", stroke: red-line, heads: "triangle"))
