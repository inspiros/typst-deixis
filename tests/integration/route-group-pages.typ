#import "@preview/deixis:0.2.0": *
#set page(width: 320pt, height: 160pt, margin: 20pt)
#show: deixis-setup-notes

#let draw(page) = context {
  let scene = deixis-routing-scene(nodes: (
    (id: <a>, pin: <a-pin>), (id: <b>, pin: <b-pin>),
    (id: <c>, pin: <c-pin>), (id: <d>, pin: <d-pin>),
    (id: <covered-one>, pin: <covered-one-pin>), (id: <covered-two>, pin: <covered-two-pin>)))
  let plan = deixis-route-group(scene: scene, (
    (id: <edge>, from: <a>, to: <b>),
    (id: "edge", from: <c>, to: <d>),
    (id: <covered>, page: 1, from: <covered-one>, to: <a>),
    (id: "covered", page: 2, from: <covered-two>, to: <c>)))
  assert.eq(plan.routes.slice(0, 2).map(r => (r.id, r.page, r.status, r.length)),
    (("edge", 1, "ok", 200pt), ("edge", 2, "ok", 100pt)))
  assert.eq(plan.routes.slice(2).map(r => (r.id, r.page, r.status)),
    (("covered", 1, "endpoint-hidden"), ("covered", 2, "endpoint-hidden")))
  assert.eq(plan.quality.after.missing, 2)
  assert.eq(plan.quality.after.contacts, 0)
  assert.eq(scene.planes.find(p => p.page == 1).bounds.right, 320)
  assert.eq(scene.planes.find(p => p.page == 2).bounds.right, 200)
  let path = plan.routes.find(r => r.page == page)
  let request = deixis-prepare-connector(path, heads: "triangle")
  place(top + left, dx: path.origin.first() - 20pt, dy: path.origin.last() - 20pt,
    deixis-render-connector(request))
}

#draw(1)
#place(top + left, dx: 20pt, dy: 30pt, deixis-pin(<a-pin>))
#place(top + left, dx: 220pt, dy: 30pt, deixis-pin(<b-pin>))
#hide[#deixis-pin(<covered-one-pin>)]
#pagebreak()
#set page(width: 200pt)
#draw(2)
#place(top + left, dx: 20pt, dy: 30pt, deixis-pin(<c-pin>))
#place(top + left, dx: 120pt, dy: 30pt, deixis-pin(<d-pin>))
#hide[#deixis-pin(<covered-two-pin>)]
