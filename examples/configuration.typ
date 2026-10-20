#import "@preview/deixis:0.2.0": *
#set page(width: 540pt, height: auto, margin: 35pt)
#set text(size: 11pt)
#show: deixis-setup-notes

= Reusable Note Settings

// A function preset stays small; apply it at document level or inside a block.
#let review-style() = deixis-set(
  stroke: (mark: blue, body: teal),
  fill: (mark: blue.lighten(92%), body: none),
  radius: (mark: (top-left: 3pt, bottom-right: 3pt), body: 0pt),
  container-func: (body: deixis-rect-container),
)
#review-style()

Our #deixis-endnote(id: <method>)[method][A short explanation using the shared preset.]
has an annotation.

// The default grid owns its cells. A stacked group uses each note's renderer/container.
#deixis-print-endnotes(render-group: deixis-native-render-group)

#deixis-block[
  // Local scope settings disappear when this block ends.
  #deixis-set(stroke: (mark: orange, body: purple))
  A #deixis-endnote[detail][The same preset with local colors.] is worth explaining.
  #deixis-print-endnotes(render-group: deixis-native-render-group)
]

A final #deixis-mark(id: <last>, radius: (:))[marked passage]
inherits blue and uses square corners.

= Independent Marker Styles

#deixis-block[
  #deixis-set(marker-style: (mark: it => super(it), body: it => strong(it)))
  This #deixis-mark(id: <inline-detail>)[passage] has a raised marker.
  #deixis-inline-note-body(of: <inline-detail>)[Its explanation uses a bold marker.]
]
