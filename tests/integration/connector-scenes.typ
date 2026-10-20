#import "../../src/lib.typ": *
#set page(width: 480pt, height: 280pt, margin: (left: 30pt, right: 100pt, y: 30pt))
#show: deixis-setup-notes
#let kind = sys.inputs.at("kind", default: "inset")
#let layer = sys.inputs.at("layer", default: "foreground")
#let edge = sys.inputs.at("edge", default: "foreground")
#let form = sys.inputs.at("form", default: "callback")
#let occurrence = sys.inputs.at("occurrence", default: "original")
#let live = state("connector-scene-body", 0)
#let heads = state("connector-scene-heads", ())
#let head(request) = (body: [#heads.update(xs => xs + (request.endpoint,))#circle(radius: 2pt)],
  trim: 2pt, bounds: (left: -2pt, right: 2pt, top: -2pt, bottom: 2pt))
#let scene(doc) = {
  assert.eq(doc.layer, edge)
  assert.eq(doc.fragment.kind, "whole")
  deixis-routing-scene(nodes: (
    (pins: (<tl>, <br>)),
  ) + if kind == "explicit" { () } else {
    ((mark: <note>, occurrence: if occurrence == "original" { none } else { <again> }), (body: <note>))
  })
}
#let paint(request) = {
  assert.eq(request.route.status, "ok")
  assert(request.route.search != none)
  assert(request.route.segments.all(s => s.kind == "line"))
  [#metadata((route: request.route, cuts: request.cuts))<connector-scene>]
  deixis-render-connector(request)
}
#let options = (route: "orthogonal", radius: 0pt, layer: edge,
  heads: (mark: head, body: head), stroke: blue + 1pt, render: paint, scene: scene)
#place(top + left, dx: 130pt, dy: 0pt,
  deixis-attach(prefix: none, pins: (tl: (anchor: top + left), br: (anchor: bottom + right)),
    rect(width: 50pt, height: 90pt, fill: luma(230))))
#if form == "prepared" {
  context {
    // Prepared values can be shared; the callback form resolves only for active edges.
    let value = scene((layer: edge, fragment: (kind: "whole")))
    deixis-connect(from: (pin: <a>), to: (pin: <b>), connector: options + (scene: value))
  }
} else if kind == "explicit" {
  deixis-connect(from: (pin: <a>), to: (pin: <b>), connector: options)
}
#if kind == "explicit" {
  place(top + left, dy: 40pt, deixis-pin(<a>, padding: 0pt))
  place(top + left, dx: 300pt, dy: 40pt, deixis-pin(<b>, padding: 0pt))
} else {
  deixis-mark(id: <note>)[Original]
  if occurrence != "original" {
    linebreak()
    deixis-mark(of: <note>, occurrence: <again>, mark-type: occurrence)[Repeated]
  }
  let body = [#live.update(n => n + 1)One Body]
  let selected = if occurrence == "original" { options } else { none }
  if kind == "inset" {
    deixis-inset-note-body(of: <note>, width: 70pt, layer: layer, connector: selected,
      placement: x => place(top + left, dx: 270pt, dy: 40pt, x), body)
  } else {
    deixis-margin-note-body(of: <note>, width: 70pt, layer: layer, side: right, connector: selected, body)
  }
  if occurrence != "original" {
    deixis-connect(from: (mark: <note>, occurrence: <again>), to: (body: <note>), connector: options)
  }
}
#let verify() = {
  assert.eq(live.final(), if kind == "explicit" { 0 } else { 1 })
  assert.eq(heads.final().sorted(), ("body", "mark"))
  let records = query(<connector-scene>).map(m => m.value)
  assert.eq(records.len(), 1)
  assert.eq(query(<deixis-scene-route>).len(), 1)
  records
}
