#import "@preview/deixis:0.2.0": *
#set page(width: 510pt, height: auto, margin: (left: 35pt, right: 145pt, y: 30pt))
#set text(size: 11pt)
#show: deixis-setup-notes

#text(size: 19pt, weight: "bold")[Declare Once, Reuse Clearly]

// Counter and mark options belong on the original. The attached wrapper renders
// only the body and inherits the original's series and rendering scope.
Declare an annotation for #deixis-mark(id: <idea>, series: "ideas")[the first passage].
#deixis-margin-note(of: <idea>, side: right, width: 105pt,
  connector: "straight-line", dy: -8pt, backlink: "multiple")[
  One explanation, one number. Only the original mark connects automatically.
]

#deixis-mark(of: <idea>, inline-mode: "underline")[Another passage]
reuses its number and body.

#deixis-mark(of: <idea>)[A third passage] adds another occurrence.

The same ID works in prose: @idea, or in a native #link(<idea>)[Typst link].
