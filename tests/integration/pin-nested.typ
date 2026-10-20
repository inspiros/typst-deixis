#import "../../src/lib.typ": *
#import "../../src/core/query.typ": _deixis-pin-index, _deixis-pins-for
#set page(width: 520pt, height: 360pt, margin: (x: 110pt, y: 35pt))
#show: deixis-setup-notes
#let ticks = state("nested-scoped-pins", 0)
#let component = context {
  let local = here()
  let pin(name) = (name: name, scope: local)
  deixis-region-mark(pins: (pin("begin"), pin("end")), layer: "foreground")
  deixis-attach(scope: local, prefix: none, pins: (
    begin: (anchor: top + left), end: (anchor: bottom + right),
  ))[#block(width: 50pt, height: 25pt)[#ticks.update(n => n + 1)Local.]]
  [#metadata(local)<nested-pin-scope>]
}
#for layer in ("flow", "background", "foreground") {
  for kind in ("margin", "inset", "footnote") {
    if kind != "margin" or layer != "flow" { pagebreak() }
    if kind == "margin" { deixis-margin-note(layer: layer, side: right, width: 80pt)[#component] }
    else if kind == "inset" { deixis-inset-note(layer: layer, width: 80pt, dx: 80pt, dy: 40pt)[#component] }
    else { deixis-footnote(layer: layer)[#component] }
    [Visible footer anchor.]
  }
}
#context {
  assert.eq(ticks.final(), 9)
  let scopes = query(<nested-pin-scope>).map(p => p.value)
  assert.eq(scopes.len(), 9)
  assert.eq(scopes.dedup().len(), 9)
  let index = _deixis-pin-index()
  assert.eq(_deixis-pins-for(index, ("begin", "end")).len(), 0)
  for scope in scopes {
    assert.eq(_deixis-pins-for(index, ((name: "begin", scope: scope), (name: "end", scope: scope))).len(), 2)
  }
}
