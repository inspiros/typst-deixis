#import "@preview/deixis:0.2.0": *
#set page(width: 470pt, height: auto, margin: 35pt)
#set text(size: 11pt)
#show: deixis-setup-notes

#text(size: 19pt, weight: "bold")[Pins Describe Geometry]

Attach two corners to a native box. Padding expands the annotation around the
box; it does not change the surrounding layout.

#align(center, deixis-attach(prefix: none, pins: (
  begin: (anchor: top + left, padding: 5pt),
  end: (anchor: bottom + right, padding: 5pt),
))[
  #rect(width: 180pt, height: 55pt, fill: rgb("e8f2ef"), stroke: none,
    align(center + horizon)[Native content])
])
#deixis-region-mark(pins: ("begin", "end"), layer: "foreground",
  fill: none, stroke: rgb("27645e") + 1pt, radius: 3pt)

```typst
pins: (
  begin: (anchor: top + left, padding: 5pt),
  end: (anchor: bottom + right, padding: 5pt),
)
```

Use `offset: (dx, dy)` to move an anchor. Use `padding: 0pt` for an exact
point, or negative padding to shrink a region's bounds.
