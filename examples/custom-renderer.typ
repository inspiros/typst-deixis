#import "@preview/deixis:0.2.0": *
#set page(width: 480pt, height: 330pt, margin: 35pt)
#set text(size: 11pt)
#show: deixis-setup-notes

#let card(note, ..args) = block(width: 180pt, inset: 10pt, radius: 4pt,
  fill: rgb("eef5f8"), stroke: rgb("8baab7"))[
  #strong[Explanation #deixis-generate-body-marker(note)]
  #parbreak()
  #deixis-generate-body-content(note)
]

= A Custom Explanation Card

This passage#deixis-inset-note(id: <detail>, render-single: card,
  layer: "foreground", width: 180pt, dx: 55pt, dy: 65pt)[
  The card has its own layout. Its marker publishes the native link destination,
  and its content keeps live start/end locations for queries and connectors.
] has a separately styled explanation.

#v(145pt)
See @detail or #link(<detail>)[the card].
#deixis-connect(from: <detail>, to: (body: <detail>, point: "start"),
  connector: (route: "curve", stroke: rgb("56839a") + 0.8pt,
    ports: (mark: bottom, body: (side: left, gap: 14pt)), heads: (body: "triangle")))
