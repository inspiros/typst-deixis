#import "@preview/deixis:0.2.0": *
#set page(width: 500pt, height: auto, margin: 35pt)
#set text(size: 11pt)
#show: deixis-setup-notes

#text(size: 19pt, weight: "bold")[Reuse A Diagram, Keep Its Pins Local]

Both cards use pins called `begin` and `end`. Each card gives them a private
scope, so its highlight stays around that card.

#let card(title, color) = context {
  let local = here()
  let pin(name) = (name: name, scope: local)
  deixis-region-mark(pins: (pin("begin"), pin("end")),
    layer: "foreground", fill: none, stroke: color + 1.2pt, radius: 5pt)
  deixis-attach(scope: local, prefix: none, pins: (
    begin: (anchor: top + left, padding: 5pt),
    end: (anchor: bottom + right, padding: 5pt),
  ))[
    #rect(width: 180pt, height: 65pt, fill: color.lighten(92%), stroke: none,
      align(center + horizon, title))
  ]
}

#v(9pt)
#grid(columns: (1fr, 1fr), gutter: 30pt,
  card([First instance], rgb("27645e")),
  card([Second instance], rgb("9a5d20")))
#v(9pt)

```typst
#context {
  let local = here()
  let pin(name) = (name: name, scope: local)
  deixis-attach(scope: local, pins: (
    begin: (anchor: top + left),
    end: (anchor: bottom + right),
  ))[Content]
  deixis-region-mark(pins: (pin("begin"), pin("end")))
}
```

Ordinary string pins remain global. For repeated occurrences within a scope,
add `select: "first"`, `"last"`, or `"all"` to the target record. A record
without `select` requires a unique match.
