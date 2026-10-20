#import "../../src/core/order.typ": *
#let settings = (stack: (), z-index: (inset-note: (nodes: 3, connector: -1), region-mark: 4))
#assert.eq(_deixis-resolve-z-index(settings, auto, "inset-note", "body"), 3)
#assert.eq(_deixis-resolve-z-index(settings, auto, "inset-note", "connector"), -1)
#assert.eq(_deixis-resolve-z-index(settings, (nodes: 7), "inset-note", "body"), 7)
#assert.eq(_deixis-resolve-z-index(settings, (nodes: 7), "inset-note", "connector"), -1)
#assert.eq(_deixis-resolve-z-index(settings, auto, "region-mark", "mark"), 4)
#let inherited = _deixis-inherited-z-index((z-index: 6), (body: 2))
#assert.eq(_deixis-resolve-z-index(settings, inherited, "inset-note", "body"), 2)
#assert.eq(_deixis-resolve-z-index(settings, inherited, "inset-note", "connector"), 6)
#assert.eq(_deixis-inherited-z-index((z-index: 6), auto), 6)
#assert.eq(_deixis-inherited-z-index((z-index: 6), -3), -3)
#let hints = _deixis-order-hints((mark: -3, body: (rest: 2), connector: 2),
  connector: (inset-note: (z-index: 7, render: _ => panic("Dormant callback executed."),
    heads: (body: (z-index: 99))), rest: (z-index: -1)))
#assert.eq(hints.func(), metadata)
#assert.eq(hints.value, (-3, -1, 2, 7))
#assert.eq(_deixis-order-hints(auto), none)
#assert.eq(_deixis-group-z-index("test", ((z-index: 2), (z-index: 2))), 2)
#assert.eq(_deixis-group-z-index("test", ()), 0)
Ordering resolution remains separate from native styles.
