#import "@preview/deixis:0.2.0": *
#set page(width: 360pt, height: 250pt, margin: 20pt)
#show: deixis-setup-notes
#let policy = sys.inputs.at("policy", default: "separate")
#let mode = sys.inputs.at("mode", default: "auto")
#let visits = sys.inputs.at("visits", default: "off") == "on"
#let layer = sys.inputs.at("layer", default: "foreground")
#show: deixis-routing.with(policy: policy, spacing: 28pt, clearance: 1pt, max-detour: 50%)
#let live = state("socket-live", 0)
#let heads = state("socket-heads", ())
#let head(r) = (body: [#heads.update(xs => xs + (r.endpoint,))#circle(radius: 1.5pt)],
  trim: 1.5pt, bounds: (left: -1.5pt, right: 1.5pt, top: -1.5pt, bottom: 1.5pt))
#let node(id, x, y) = place(top + left, dx: x, dy: y,
  deixis-attach(id: id, pins: ((str(id)): (anchor: horizon + right)),
    [#live.update(n => n + 1)#rect(width: 40pt, height: 18pt, fill: white)]))
#node("a", 20pt, 55pt)
#node("b", 250pt, 55pt)
#node("c", 20pt, 79pt)
#node("d", 250pt, 79pt)
#let paint(index, r) = {
  let doc = r.route.document
  let end = r.route.origin.zip(r.route.end).map(((a, b)) => a + b)
  assert.eq(doc.endpoints.mark.point, r.route.origin)
  assert.eq(doc.endpoints.body.point, end)
  assert.eq(doc.fragment.source, doc.endpoints.mark)
  assert.eq(doc.fragment.target, doc.endpoints.body)
  assert.eq(r.route.start-tangent, doc.endpoints.mark.normal)
  assert.eq(r.route.end-tangent, doc.endpoints.body.normal.map(n => -n))
  if mode in ("fixed", "pin", "source-fixed") {
    assert.eq(r.route.origin, (80pt, (84 + 24 * index) * 1pt))
  }
  if mode == "fixed" { assert.eq(end, (270pt, (84 + 24 * index) * 1pt)) }
  if mode == "sliding" {
    assert.eq(r.route.origin.first(), 80pt)
    assert.eq(doc.endpoints.mark.normal, (1, 0))
    assert((75 + 24 * index) * 1pt <= r.route.origin.last() and r.route.origin.last() <= (93 + 24 * index) * 1pt)
  }
  if visits {
    let point = (190pt, (150 + 20 * index) * 1pt).zip(r.route.origin).map(((p, o)) => p - o)
    assert(r.route.segments.any(s => s.start == point or s.end == point))
  }
  [#metadata(index)<socket-painted>]
  deixis-render-connector(r)
}
#for (i, ids) in (("a", "b"), ("c", "d")).enumerate() {
  let ports = (if mode == "fixed" { (mark: (side: right, at: 50%), body: (side: left, at: 50%)) }
    else if mode == "source-fixed" { (mark: (side: right, at: 50%)) }
    else if mode == "pin" { (mark: (pin: ids.first(), side: right)) }
    else if mode == "sliding" { (mark: right) } else { auto })
  deixis-connect(from: (node: ids.first()), to: (node: ids.last()), connector: (
    ports: ports, layer: layer, z-index: i, heads: (mark: head, body: head), render: paint.with(i),
    via: if visits { ((relative-to: "page", offset: (190pt, (150 + 20 * i) * 1pt)),) } else { auto }))
}
#context {
  assert.eq(live.final(), 4)
  assert.eq(heads.final().sorted(), ("body", "body", "mark", "mark"))
  assert.eq(query(<socket-painted>).map(m => m.value).sorted(), (0, 1))
  let plans = query(<deixis-routing-plan>).map(m => m.value.plan)
  assert.eq(plans.len(), if policy == "manual" { 0 } else { 1 })
  for plan in plans {
    assert(plan.stats.searches <= 64 and plan.stats.expanded <= 50000)
    if policy == "separate" and mode == "auto" and not visits {
      assert.eq(plan.quality.after.exposure, 0pt)
      assert(plan.routes.any(r => "selection" in r))
    }
    if policy == "avoid" { assert(plan.routes.all(r => "selection" not in r)) }
  }
}
