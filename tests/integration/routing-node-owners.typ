#import "../../src/lib.typ": *
#set page(width: 440pt, height: 280pt, margin: (left: 30pt, right: 100pt, y: 30pt))
#set text(size: 10pt)
#show: deixis-setup-notes
#let policy = sys.inputs.at("policy", default: "separate")
#let kind = sys.inputs.at("kind", default: "inset")
#let layer = sys.inputs.at("body-layer", default: "foreground")
#let edge = sys.inputs.at("layer", default: "foreground")
#let occurrence = sys.inputs.at("occurrence", default: "original")
#let live = state("routing-owner-body", 0)
#let specs = ((body: <note>), (mark: <note>,
  occurrence: if occurrence == "original" { none } else { <again> }))
#show: deixis-routing.with(policy: policy, nodes: specs)
#let paint(r) = {
  [#metadata(r.route)<routing-owner-painted>]
  deixis-render-connector(r)
}
#deixis-mark(id: <note>)[Source]
#if occurrence != "original" {
  linebreak()
  deixis-mark(of: <note>, occurrence: <again>, mark-type: occurrence)[Repeated]
}
#let options = (route: "orthogonal", radius: 0pt, layer: edge, render: paint)
#let payload = [#live.update(n => n + 1)Owned Body]
#let selected = if occurrence == "original" { options } else { none }
#if kind == "margin" {
  deixis-margin-note-body(of: <note>, width: 70pt, layer: layer, side: right,
    connector: selected, payload)
} else {
  deixis-inset-note-body(of: <note>, width: 70pt, layer: layer, connector: selected,
    placement: x => place(top + left, dx: 220pt, dy: 100pt, x), payload)
}
#if occurrence != "original" {
  deixis-connect(from: (mark: <note>, occurrence: <again>), to: (body: <note>), connector: options)
}
#let verify() = {
  assert.eq(live.final(), 1)
  let routes = query(<routing-owner-painted>).map(m => m.value)
  assert.eq(routes.len(), 1)
  assert.eq(query(<deixis-routing-plan>).len(), if policy == "manual" { 0 } else { 1 })
  routes.map(r => (origin: r.origin, end: r.end))
}
