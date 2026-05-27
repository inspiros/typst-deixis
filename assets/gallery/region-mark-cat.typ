#set page(width: 300pt, height: 240pt, margin: (x: 1cm, rest: 1cm))

#import "../../src/lib.typ": *
#show: deixis-setup-notes
#show raw: set text(size: 0.85em)

#align(center,
  deixis-attach(
  pins: (
    cat-top-left: (dx: 40%, dy: 35%),
    cat-bottom-right: (dx: 62%, dy: 63%),
  )
)[
  #image("../loading-cat.jpg", width: 80%)
])

#deixis-region-mark(
  id: <cat>,
  pins: ("cat-top-left", "cat-bottom-right"),
  marker-style: (mark: it => text(fill: white, super(it))),
  marker-position: top + center,
  stroke: red,
  fill: red.transparentize(90%),
)
#deixis-footnote-body(
  id: <cat>,
)[A loading cat.]
