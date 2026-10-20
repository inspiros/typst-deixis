#import "@preview/deixis:0.2.0": *
#set page(width: 460pt, height: 300pt, margin: (left: 30pt, right: 100pt, y: 30pt))
#set text(size: 10pt)
#show: deixis-setup-notes
#let kind = sys.inputs.at("kind", default: "margin")
#let policy = sys.inputs.at("policy", default: "separate")
#let layer = sys.inputs.at("layer", default: "foreground")
#let edge-layer = sys.inputs.at("edge", default: "foreground")
#let form = sys.inputs.at("form", default: "inline")
#let explicit-scene = sys.inputs.at("scene", default: "off") == "on"
#show: deixis-routing.with(policy: policy)
#let live = state("routing-note-body", 0)
#let heads = state("routing-note-heads", ())
#let head(r) = (body: [#heads.update(xs => xs + (r.endpoint,))#circle(radius: 1.5pt)],
  trim: 1.5pt, bounds: (left: -1.5pt, right: 1.5pt, top: -1.5pt, bottom: 1.5pt))
#let paint(name, r) = {
  let doc = r.route.document
  assert.eq(text.size, 10pt)
  assert.eq(doc.layer, edge-layer)
  assert.eq(r.route.at("search", default: none) != none, policy != "manual" or explicit-scene)
  assert.eq(doc.fragment.kind, "whole")
  let visit = (230pt, 160pt).zip(r.route.origin).map(((v, o)) => v - o)
  assert(r.route.segments.any(s => s.start == visit or s.end == visit))
  [#metadata((name: name, document: doc))<note-policy-painted>]
  deixis-render-connector(r)
}
#let options = (route: "orthogonal", radius: 0pt, layer: edge-layer,
  via: ((pin: <visit>, offset: (1em, 0pt)),), heads: (mark: head, body: head),
  z-index: 2, stroke: blue + 0.8pt, render: paint.with("shorthand"),
  scene: if explicit-scene { deixis-routing-scene(nodes: (
    (page: 1, bounds: (left: 165pt, top: 30pt, right: 205pt, bottom: 110pt)),
  )) } else { none })
#place(top + left, dx: 135pt, dy: 0pt, deixis-attach(behavior: "avoid",
  rect(width: 40pt, height: 80pt, fill: luma(220))))
#place(top + left, dx: 190pt, dy: 130pt, deixis-pin(<visit>, padding: 0pt))
#if form == "phantom" { deixis-mark(id: <note>, mark-type: "phantom") } else {
  deixis-mark(id: <note>, mark-type: form)[Original]
}
#deixis-mark(of: <note>, occurrence: <again>)[Repeated]
#let body = [#live.update(n => n + 1)One Body]
#if kind == "margin" {
  deixis-margin-note-body(of: <note>, layer: layer, side: right,
    width: 65pt, connector: options, body)
} else {
  deixis-inset-note-body(of: <note>, layer: layer, width: 65pt, connector: options,
    placement: x => place(top + left, dx: 260pt, dy: 95pt, x), body)
}
// The repeated mark gets a connector only through this explicit declaration.
#deixis-connect(from: (mark: <note>, occurrence: <again>), to: <note>,
  connector: options + (z-index: -1, render: paint.with("explicit")))
#deixis-margin-note(connector: none, width: 65pt)[Silent][No Connector]
#context {
  assert.eq(live.final(), 1)
  assert.eq(heads.final().sorted(), ("body", "body", "mark", "mark"))
  assert.eq(query(<note-policy-painted>).map(m => m.value.name).sorted(), ("explicit", "shorthand"))
  let plans = query(<deixis-routing-plan>).map(m => m.value)
  assert.eq(plans.len(), if policy == "manual" { 0 } else { 1 })
  for plan in plans {
    assert.eq(plan.policy, policy)
    assert.eq(plan.layer, edge-layer)
    assert.eq(plan.members.len(), 2)
    assert.eq(plan.plan.routes.map(r => r.status), ("ok", "ok"))
    assert.eq(plan.plan.quality == none, policy == "avoid")
  }
}
