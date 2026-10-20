#import "@preview/deixis:0.2.0": *
#set page(width: 300pt, height: 200pt, margin: 20pt)
#show: deixis-setup-notes
#show: deixis-routing.with(policy: sys.inputs.at("policy", default: "separate"))
#let mode = sys.inputs.at("mode", default: "both")
#let layer = sys.inputs.at("layer", default: "foreground")
#let visits = sys.inputs.at("visits", default: "off") == "on"
#let heads = state("group-port-heads", 0)
#let live = state("group-port-live", 0)
#let head(r) = (body: [#heads.update(n => n + 1)#circle(radius: 2pt)], trim: 2pt,
  bounds: (left: -2pt, right: 2pt, top: -2pt, bottom: 2pt))
#let paint(r) = {
  let doc = r.route.document
  let source = r.route.origin
  let target = r.route.origin.zip(r.route.end).map(((a, b)) => a + b)
  assert.eq(doc.endpoints.mark.point, source)
  assert.eq(doc.endpoints.body.point, target)
  assert.eq(doc.fragment.source, doc.endpoints.mark)
  assert.eq(doc.fragment.target, doc.endpoints.body)
  assert.eq(doc.dx, target.first() - source.first())
  assert.eq(doc.dy, target.last() - source.last())
  assert.eq(r.route.start-tangent, doc.endpoints.mark.normal)
  assert.eq(r.route.end-tangent, doc.endpoints.body.normal.map(n => -n))
  if mode in ("source", "both", "sliding") { assert.ne(source, (60pt, 85pt)) }
  if mode in ("target", "both") { assert.ne(target, (210pt, 85pt)) }
  if mode == "sliding" {
    assert.eq(source.first(), 60pt)
    assert.eq(doc.endpoints.mark.normal, (1, 0))
    assert(70pt <= source.last() and source.last() <= 100pt)
  }
  if mode == "pin" { assert.eq(source, (45pt, 70pt)) }
  if visits {
    let p = (140pt - source.first(), 85pt - source.last())
    assert(r.route.segments.any(s => s.start == p or s.end == p))
  }
  [#metadata((source: source, target: target))<group-ports-painted>]
  deixis-render-connector(r)
}
#let ports = (if mode == "sliding" { (mark: right) }
  else if mode == "pin" { (mark: (pin: <outlet>, side: top)) } else { auto })
#deixis-connect(from: (node: <a>), to: (node: <b>), connector: (
  ports: ports, layer: layer, render: paint, heads: (mark: head, body: head),
  via: if visits { ((pin: <via>),) } else { auto }))
#place(top + left, dx: 10pt, dy: 50pt, deixis-attach(id: <a>, pins: (outlet: (anchor: top)),
  [#live.update(n => n + 1)#rect(width: 30pt, height: 30pt)]))
#place(top + left, dx: 190pt, dy: 50pt, deixis-attach(id: <b>, rect(width: 30pt, height: 30pt)))
#if mode in ("source", "both", "sliding", "pin") {
  place(top + left, dx: 40pt, dy: 55pt, deixis-attach(behavior: "avoid", rect(width: 20pt, height: 20pt)))
}
#if mode in ("target", "both") {
  place(top + left, dx: 170pt, dy: 55pt, deixis-attach(behavior: "avoid", rect(width: 20pt, height: 20pt)))
}
#place(top + left, dx: 120pt, dy: 65pt, deixis-pin(<via>, padding: 0pt))
#context {
  assert.eq(query(<group-ports-painted>).len(), 1)
  assert.eq(heads.final(), 2)
  assert.eq(live.final(), 1)
  let plan = query(<deixis-routing-plan>).first().value.plan
  assert.eq(plan.routes.first().status, "ok")
  assert(plan.stats.searches <= 64 and plan.stats.expanded <= 50000)
}
