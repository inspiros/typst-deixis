#import "@preview/deixis:0.2.0": *
#set page(width: 460pt, height: auto, margin: 35pt)
#set text(size: 11pt)
#show: deixis-setup-notes

#text(size: 19pt, weight: "bold")[Give The Body Some Room]

This note has a native rectangle around its body#deixis-endnote(
  container-func: deixis-rect-container,
  container-args: (inset: 7pt),
  stroke: (mark: none, body: rgb("27645e") + 0.8pt),
  fill: (mark: none, body: rgb("e8f2ef")),
)[Container options travel with the body. The same geometry is used for measurement and rendering.].

#deixis-print-endnotes(render-group: deixis-native-render-group)

```typst
container-func: deixis-rect-container,
container-args: (inset: 7pt),
```

Use a stacked endnote group to keep single-note containers. The default grid
aligns markers and bodies directly.
