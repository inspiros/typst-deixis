#import "../../src/lib.typ": *
#set page(width: 500pt, height: 300pt, margin: (left: 30pt, right: 110pt, y: 30pt))
#set text(size: 10pt)
#show: deixis-setup-notes
#let kind = sys.inputs.at("kind", default: "inset")
#let layer = sys.inputs.at("body-layer", default: "foreground")
#let edge = sys.inputs.at("layer", default: "foreground")
#let policy = sys.inputs.at("policy", default: "separate")
#let behavior = sys.inputs.at("behavior", default: "avoid")
#let live = state("routing-node-bodies", 0)
#let heads = state("routing-node-heads", ())
#show: deixis-routing.with(policy: policy, nodes: ((body: <obstacle>, behavior: behavior),))
#let head(r) = (body: [#heads.update(xs => xs + (r.endpoint,))#circle(radius: 1.5pt)],
  trim: 1.5pt, bounds: (left: -1.5pt, right: 1.5pt, top: -1.5pt, bottom: 1.5pt))
#let paint(r) = {
  [#metadata((route: r.route, cuts: r.cuts))<routing-node-painted>]
  deixis-render-connector(r)
}
#deixis-connect(from: (pin: <a>), to: (pin: <b>), connector: (
  route: "orthogonal", radius: 0pt, layer: edge,
  heads: (mark: head, body: head), render: paint))
#place(top + left, dx: if kind == "margin" { 420pt } else { 10pt },
  dy: if kind == "margin" { 20pt } else { 110pt }, deixis-pin(<a>, padding: 0pt))
#place(top + left, dx: if kind == "margin" { 420pt } else { 450pt },
  dy: if kind == "margin" { 230pt } else { 110pt }, deixis-pin(<b>, padding: 0pt))
#let payload = [#live.update(n => n + 1)#block(height: 70pt)[Registered Body]]
#if kind == "margin" {
  place(top + left, dy: 80pt, deixis-mark(id: <obstacle>)[Mark])
  deixis-margin-note-body(of: <obstacle>, width: 75pt, side: right, layer: layer,
    connector: none, payload)
} else if kind == "inline" {
  place(top + left, dx: 210pt, dy: 90pt,
    deixis-inline-note-body(id: <obstacle>, breakable: false, inline: true, payload))
} else {
  deixis-inset-note-body(id: <obstacle>, width: 75pt, layer: layer, connector: none,
    placement: x => place(top + left, dx: 210pt, dy: 90pt, x), payload)
}
#let verify() = {
  assert.eq(live.final(), 1)
  assert.eq(heads.final().sorted(), ("body", "mark"))
  let values = query(<routing-node-painted>).map(m => m.value)
  assert.eq(values.len(), 1)
  let r = values.first().route
  assert.eq(r.at("search", default: none) != none, policy != "manual")
  if policy != "manual" {
    assert.eq(r.status, "ok")
    let direct = if kind == "margin" { 210pt } else { 440pt }
    if behavior == "avoid" { assert(r.length > direct) }
    else { assert.eq(r.length, direct) }
    assert.eq(r.interactions.len() > 0, behavior in ("cut", "cross"))
  }
  assert.eq(values.first().cuts.len() > 0, policy != "manual" and behavior == "cut")
  (length: r.length, origin: r.origin, end: r.end)
}
