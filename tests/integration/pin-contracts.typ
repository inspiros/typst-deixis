#import "../../src/lib.typ": *
#import "../../src/layout/geometry.typ": _deixis-region-bounds
#set page(width: 450pt, height: 380pt, margin: 40pt)
#show: deixis-setup-notes
#set text(size: 20pt)
#deixis-pin("text")
#deixis-pin("zero", padding: none, extra-data: (tag: "kept"))
#deixis-pin("edges", padding: (rest: 1pt, x: 2pt, left: -3pt, top: none, bottom: auto))
#deixis-attach(prefix: ".", postfix: "[end]", padding: 0pt)[xUnexpected .Literal[end]]
#deixis-attach(prefix: "(", postfix: ")", padding: none)[(Paren)]
#deixis-attach(pattern: regex("@([a-z]+)!"), padding: 0pt)[#text("@regex!")]
#deixis-attach(pattern: regex("@([a-z]+)!"), padding: 0pt)[`@raw!`]
#deixis-attach(pattern: none)[deixispinUntouched]
#deixis-attach(prefix: none, pins: (
  tl: (anchor: top + left), tr: (anchor: top + right, offset: (2pt, 0pt)),
  center: (anchor: center), bottom: (anchor: bottom + left, offset: (0pt, -3pt)),
  original: (dx: 100%, dy: 100%),
))[
  #block(width: 100pt, height: 40pt)[Box.]
]
#let attach = deixis-attach.with(prefix: "[", postfix: "]")
#attach(padding: 0pt)[#text("[Preset]")]
#deixis-attach(prefix: none)[deixispinDisabled]
#deixis-attach(padding: 0pt)[deixispinDefault]
#context {
  let pins = query(<deixis-pin>)
  let pin(name) = pins.find(p => p.value.name == name)
  let pos(name) = pin(name).location().position()
  assert(pin("Preset") != none and pin("Default") != none)
  assert.eq(pins.len(), 14)
  assert.eq(pin("text").value.padding, (left: 2pt, right: 2pt, top: 18pt, bottom: 4pt))
  assert.eq(pin("zero").value.padding, (left: 0pt, right: 0pt, top: 0pt, bottom: 0pt))
  assert.eq(pin("zero").value.tag, "kept")
  assert.eq(pin("edges").value.padding, (left: -3pt, right: 2pt, top: 0pt, bottom: 1pt))
  let text-bounds = _deixis-region-bounds((pin("text"),), 1, padding: 3pt)
  assert.eq(text-bounds.left, pos("text").x - 5pt)
  assert.eq(text-bounds.right, pos("text").x + 5pt)
  assert.eq(text-bounds.top, pos("text").y - 21pt)
  assert.eq(text-bounds.bottom, pos("text").y + 7pt)
  assert.eq(pos("tr").x - pos("tl").x, 102pt)
  assert.eq(pos("center").x - pos("tl").x, 50pt)
  assert.eq(pos("center").y - pos("tl").y, 20pt)
  assert.eq(pos("bottom").y - pos("tl").y, 37pt)
  assert.eq(pos("original").y - pos("tl").y, 40pt)
  assert(pin("Unexpected") == none and pin("Untouched") == none and pin("Disabled") == none)
}
