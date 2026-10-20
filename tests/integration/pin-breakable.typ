#import "../../src/lib.typ": *
#set page(width: 350pt, height: 220pt, margin: 30pt)
#show: deixis-setup-notes
#deixis-attach(prefix: none, pins: (
  first: (anchor: top + left), middle: (anchor: center),
  last: (anchor: bottom + right), inset: (anchor: bottom + right, offset: (0pt, -3pt)),
))[
  #for i in range(3) {
    block(height: 110pt, breakable: false, above: 0pt, below: 0pt, {
      [Fragment #i.]
      place(bottom + right, [#metadata(i)<native-fragment-bottom>])
    })
  }
]
#context {
  let pins = query(<deixis-pin>)
  let pin(name) = pins.find(p => p.value.name == name).location()
  let last = query(<native-fragment-bottom>).last().location()
  assert.eq(last.page(), 3)
  assert.eq(pin("first").page(), 1)
  assert.eq(pin("middle").page(), 1)
  assert.eq(pin("last").page(), last.page())
  assert.eq(pin("last").position(), last.position())
  assert.eq(pin("inset").position().y, last.position().y - 3pt)
}
