#import "../../src/lib.typ": *
#set page(width: 460pt, height: 340pt, margin: 40pt)
#show: deixis-setup-notes
#deixis-pin("negative", padding: (x: -3pt, y: -2pt))
#deixis-attach(prefix: none, postfix: "end", pins: (
  top: (dx: 0%), bottom: (dy: 100%), offset: (dx: 100%, dy: 100% - 3pt),
  array: (100%, 100%), origin: (:),
))[
  #block(width: 120pt, height: 50pt)[deixispinLiteral]
]
#deixis-attach(prefix: "")[`deixispinStillLiteral`]
#deixis-attach(prefix: "pin", postfix: "end")[pinScannedend#text[Content.]]
#context {
  let pins = query(<deixis-pin>)
  assert.eq(pins.map(p => p.value.name).sorted(), ("Scanned", "array", "bottom", "negative", "offset", "origin", "top"))
  let pin(name) = pins.find(p => p.value.name == name)
  let pos(name) = pin(name).location().position()
  assert.eq(pin("negative").value.padding, (left: -3pt, right: -3pt, top: -2pt, bottom: -2pt))
  assert.eq((pos("bottom").y - pos("top").y), 50pt)
  assert.eq((pos("array").x - pos("top").x), 120pt)
  assert.eq(pos("array").y, pos("bottom").y)
  assert.eq(pos("offset").y, pos("bottom").y - 3pt)
  assert.eq(pos("origin"), pos("top"))
}
