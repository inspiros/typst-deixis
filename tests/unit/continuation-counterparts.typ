#import "../../src/routing/continuations.typ": _deixis-counterpart-lookup, _deixis-continuation-site
#set page(width: 240pt, height: 160pt)
#let one = (kind: "test", index: 1)
#let two = (kind: "test", index: 2)
#_deixis-continuation-site(one, "foreground", (status: "resolved", page: 3, direction: "incoming", point: (80pt, 20pt), normal: (0, -1)))
#_deixis-continuation-site(two, "foreground", (status: "resolved", page: 3, direction: "incoming", point: (80pt, 20pt), normal: (0, -1)))
#_deixis-continuation-site(one, "background", (status: "resolved", page: 3, direction: "incoming", point: (90pt, 20pt), normal: (0, -1)))
#_deixis-continuation-site(one, "foreground", (status: "resolved", page: 2, direction: "incoming", point: (70pt, 20pt), normal: (0, -1)))
// Partial logical ownership cannot manufacture a pair or poison a complete one.
#_deixis-continuation-site(one, "foreground", (status: "incomplete", page: 3, direction: "incoming", point: (60pt, 20pt), normal: (0, -1)))
#context {
  let other = (_deixis-counterpart-lookup(one, "foreground", "outgoing", 3))()
  assert.eq(other, (page: 3, point: (80pt, 20pt), normal: (0, -1), direction: "incoming",
    destination: (page: 3, x: 80pt, y: 20pt)))
  assert.eq((_deixis-counterpart-lookup(one, "foreground", "incoming", 3))(), none)
  assert.eq((_deixis-counterpart-lookup(one, "foreground", "outgoing", none))(), none)
  assert.eq((_deixis-counterpart-lookup(none, "foreground", "outgoing", 3))(), none)
  assert.eq((_deixis-counterpart-lookup(two, "foreground", "outgoing", 2))(), none)
}
