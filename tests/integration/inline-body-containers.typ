#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#import "../../src/routing/frames.typ": _deixis-body-nodes
#set page(width: 560pt, height: 390pt, margin: (x: 120pt, y: 40pt))
#show: deixis-setup-notes
#let ticks = state("nested-inline-body-frames", 0)
#let cases = ()
#let painter(name, request) = [#metadata((name: name, document: request.route.document))<nested-inline-route>]
#for kind in ("margin", "inset", "footnote") {
  for layer in ("flow", "background", "foreground") {
    if cases.len() > 0 { pagebreak() }
    let outer = "outer-" + kind + "-" + layer
    let inner = "inner-" + kind + "-" + layer
    cases.push(inner)
    let body = [Nested #deixis-inline-note-body(id: inner, inline: true,
      breakable: false, inline-mode: "underline")[#ticks.update(n => n + 1)Framed body.]]
    deixis-connect(from: outer, to: inner, connector: (route: "curve", render: painter.with(inner)))
    if kind == "margin" { deixis-margin-note(id: outer, layer: layer, side: right, width: 95pt, body) }
    else if kind == "inset" { deixis-inset-note(id: outer, layer: layer, width: 100pt, dx: 90pt, dy: 65pt, body) }
    else { deixis-footnote(id: outer, layer: layer, body) }
    [Visible native footer anchor. Native #link(label(inner))[inner link].]
  }
}
#context {
  assert.eq(ticks.final(), 9)
  assert.eq(deixis-system.final().registry.value.notes.len(), 18)
  let nodes = _deixis-body-nodes()
  for inner in cases {
    assert.eq(nodes.at("id-" + inner).len(), 1)
    assert.eq(query(label(inner)).len(), 1)
  }
  assert.eq(query(<deixis-rendered-start>).len(), 18)
  [#metadata((destinations: cases.map(inner => {
    let pos = query(label(inner)).first().location().position()
    (page: pos.page, x: pos.x.pt(), y: pos.y.pt())
  })))<test-result>]
}
