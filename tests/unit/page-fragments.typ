#import "../../src/routing/connections.typ": _deixis-connection-node, _deixis-prepared-connection
#import "../../src/routing/fragments.typ": *

#let node(page, virtual: false, x: 10pt) = _deixis-connection-node("body", page, ((x: x, y: 20pt),),
  identity: "note", bounds: (left: x, top: 20pt, right: x + 30pt, bottom: 50pt), virtual: virtual)
#let a = node(1)
#let b = node(4, x: 100pt)
#let outgoing = _deixis-prepared-connection(a, node(2, virtual: true), (:), adapter: "margin")
#let incoming = _deixis-prepared-connection(node(3, virtual: true), b, (:), adapter: "margin")
#let index = _deixis-margin-endpoint-index(((edge: outgoing), (edge: incoming)))
#assert.eq(index.at("note"), (source: a, target: b))
#assert.eq(_deixis-margin-endpoint-index(((edge: incoming), (edge: outgoing))), index)
#assert.eq(_deixis-margin-endpoint-index(((edge: outgoing),)).at("note"), (source: a, target: none))
#assert.eq(_deixis-margin-endpoint-index(((edge: outgoing + (source: a + (identity: none))),)), (:))
// Duplicate evidence is harmless; incompatible destinations are not guessed.
#assert.eq(_deixis-margin-endpoint-index(((edge: outgoing), (edge: incoming), (edge: incoming))), index)
#assert.eq(_deixis-margin-endpoint-index(((edge: incoming),
  (edge: incoming + (target: node(5))))).at("note").target, none)
#let edge = outgoing + (logical: index.at("note"))
#let fragment = _deixis-page-fragment(edge, 1, (role: "mark"), (role: "continuation"), outgoing: true)
#assert.eq((fragment.page, fragment.kind, fragment.status), (1, "source", "resolved"))
#assert.eq(fragment.logical.target.page, 4)
#assert.eq(_deixis-page-fragment(outgoing, 1, (:), (:), outgoing: true).status, "incomplete")
#assert.eq(_deixis-continuation-peer(b), (page: 4, point: (115pt, 35pt),
  destination: (page: 4, x: 115pt, y: 35pt)))
