#import "@preview/deixis:0.2.0": *
#set page(width: 300pt, height: 200pt, margin: 20pt)
#show: deixis-setup-notes
#let painted = state("route-group-painted", 0)
#let head(request) = (body: [#painted.update(n => n + 1)#circle(radius: 2pt, fill: request.fill)],
  trim: 2pt, bounds: (left: -2pt, top: -2pt, right: 2pt, bottom: 2pt))

// Accepted pin frames can be declared after planning. Shared pin identity is a
// point junction; no extra note ID, junction name or live-body execution.
#context {
  let scene = deixis-routing-scene(nodes: (
    (id: <hub>, pin: <hub-pin>),
    (id: <upper>, pin: <upper-pin>),
    (id: <lower>, pin: <lower-pin>),
    (id: <covered>, pin: <covered-pin>)))
  let plan = deixis-route-group(scene: scene, (
    (from: <hub>, to: <upper>),
    (from: "hub", to: <lower>),
    (from: <covered>, to: <upper>)))
  assert.eq(plan.routes.map(r => r.status), ("ok", "ok", "endpoint-hidden"))
  assert.eq(plan.quality.after.missing, 1)
  assert.eq(plan.quality.after.contacts, 0)
  assert.eq(plan.quality.after.shared, 0pt)
  assert(plan.routes.slice(0, 2).all(r => r.page == 1 and r.origin == (40pt, 90pt)))
  for path in plan.routes.filter(r => r.status == "ok") {
    let request = deixis-prepare-connector(path, heads: (body: head))
    place(top + left, dx: path.origin.first() - 20pt, dy: path.origin.last() - 20pt,
      deixis-render-connector(request))
  }
}
#place(top + left, dx: 20pt, dy: 70pt, deixis-pin(<hub-pin>))
#place(top + left, dx: 220pt, dy: 30pt, deixis-pin(<upper-pin>))
#place(top + left, dx: 220pt, dy: 110pt, deixis-pin(<lower-pin>))
#hide[#deixis-pin(<covered-pin>)]
#context assert.eq(painted.final(), 2)
