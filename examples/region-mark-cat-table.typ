#set page(width: 300pt, height: 240pt, margin: 1cm)

#import "@preview/deixis:0.1.0": *
#show: deixis-setup-notes
#show raw: set text(size: 0.85em)

Breakdown of standard #deixis-pin("feline-l")feline#deixis-pin("feline-r") architecture and performance metrics:
#deixis-region-mark(
  stroke: none,
  fill: yellow.transparentize(50%),
  radius: 0pt,
  pins: ("feline-l", "feline-r"),
  layer: "background",
)

#{
  set text(size: 0.8em)
  figure(
    table(
      align: left + horizon,
      columns: (auto, auto),

      table.header([*Property*], [*Specification*]),
      [\#legs], [4],
      [Max speed], [#deixis-pin("tab-tl")48 km/h],
      [Battery Life], [16--18 hours#deixis-pin("tab-br", padding: (bottom: 0.2em, right: 1em))],
      [Fuel Source], [Tuna],
      [Storage Capacity], [$infinity$]
  ))
}
#deixis-footnote(
  mark-type: "region",
  marker-style: it => text(fill: blue, super(it)),
  stroke: orange,
  fill: orange.transparentize(95%),
  pins: ("tab-tl", "tab-br"),
)[Top performance achieved at #sym.tilde.basic#[]3:00 AM, must recharge under direct sunlight #emoji.sun.]
