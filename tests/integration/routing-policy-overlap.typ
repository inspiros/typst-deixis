#import "@preview/deixis:0.2.0": *
#set page(width: 320pt, height: 220pt, margin: 20pt)
#show: deixis-setup-notes
#let policy = sys.inputs.at("policy", default: "avoid")
#show: deixis-routing.with(policy: policy)
#let painted = state("policy-overlap-paint", 0)
#let paint(r) = {
  let route = r.route
  // Both native and obstacle-only routing must preserve this literal shared
  // horizontal segment. Merely lowering a congestion penalty would not force it.
  assert(route.segments.any(s => {
    let start = route.origin.zip(s.start).map(((a, b)) => a + b)
    let end = route.origin.zip(s.end).map(((a, b)) => a + b)
    (s.kind == "line" and start.last() == 50pt and end.last() == 50pt
      and calc.min(start.first(), end.first()) <= 100pt
      and calc.max(start.first(), end.first()) >= 200pt)
  }))
  assert.eq(route.at("search", default: none) == none, policy == "manual")
  [#painted.update(n => n + 1)#deixis-render-connector(r)]
}
#let lane = ((pin: <lane-start>), (pin: <lane-end>))
#let path = if policy == "manual" { (segments: (
  (route: "orthogonal", via: (lane.first(),)),
  (route: "polyline", via: (lane.last(),)),
  (route: "orthogonal"),
)) } else { (via: lane) }
#deixis-connect(from: (node: <a>), to: (node: <b>), connector: (
  ports: (mark: top, body: top), render: paint, stroke: blue, heads: "triangle") + path)
#deixis-connect(from: (node: <a>), to: (node: <b>), connector: (
  ports: (mark: (pin: <outlet>, side: top), body: bottom), render: paint,
  stroke: orange, heads: "triangle") + path)
#place(top + left, dx: 10pt, dy: 80pt, deixis-attach(id: <a>, pins: (outlet: (anchor: top, offset: (8pt, 0pt))),
  rect(width: 45pt, height: 40pt)[A]))
#place(top + left, dx: 220pt, dy: 80pt, deixis-attach(id: <b>, rect(width: 45pt, height: 40pt)[B]))
#place(top + left, dx: 80pt, dy: 30pt, deixis-pin(<lane-start>, padding: 0pt))
#place(top + left, dx: 180pt, dy: 30pt, deixis-pin(<lane-end>, padding: 0pt))
#place(top + left, dx: 70pt, dy: 60pt, deixis-attach(behavior: "avoid", rect(width: 40pt, height: 80pt)))
#context {
  assert.eq(painted.final(), 2)
  let plans = query(<deixis-routing-plan>).map(m => m.value)
  assert.eq(plans.len(), if policy == "manual" { 0 } else { 1 })
  if policy == "avoid" {
    let p = plans.first().plan
    assert.eq(p.quality, none)
    assert.eq(p.stats.searches, 2)
    assert.eq(p.stats.rounds, 0)
  }
}
