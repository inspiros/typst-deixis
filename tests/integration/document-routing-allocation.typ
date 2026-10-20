#import "@preview/deixis:0.2.0": *
#set page(width: 300pt, height: 220pt, margin: 20pt)
#show: deixis-setup-notes
#show: deixis-routing.with(policy: sys.inputs.at("policy", default: "separate"))
#let backwards = sys.inputs.at("direction", default: "forward") == "backward"
#let layer = sys.inputs.at("layer", default: "foreground")
#let heads = state("allocated-group-heads", ())
#let head(r) = (body: [#heads.update(xs => xs + (r.endpoint,))#circle(radius: 2pt)], trim: 2pt,
  bounds: (left: -2pt, right: 2pt, top: -2pt, bottom: 2pt))
#let paint(r) = {
  let doc = r.route.document
  assert.eq(doc.source-page, if backwards { 2 } else { 1 })
  assert.eq(doc.target-page, if backwards { 1 } else { 2 })
  let point = if doc.is-incoming { r.route.origin } else { r.route.origin.zip(r.route.end).map(((a, b)) => a + b) }
  assert.eq(doc.continuation.point, point)
  assert(doc.continuation.allocation.automatic)
  assert(doc.continuation.allocation.shifted)
  assert.ne(point, doc.continuation.allocation.preferred)
  assert.eq(doc.endpoints.mark.point, r.route.origin)
  assert.eq(doc.fragment.source, doc.endpoints.mark)
  [#metadata((page: doc.page, point: point, peer: doc.continuation.peer-page))<group-allocated>]
  deixis-render-connector(r)
}
#let continuation(r) = {
  assert(r.allocation.shifted)
  [#metadata(r.page)<group-relay-painted>]
  circle(radius: 2pt)
}
#deixis-connect(from: (node: if backwards { <two> } else { <one> }),
  to: (node: if backwards { <one> } else { <two> }), connector: (
    layer: layer, heads: (mark: head, body: head), render: paint, continuation: continuation))
#place(top + left, dx: 40pt, dy: 70pt, deixis-attach(id: <one>, rect(width: 30pt, height: 20pt)))
#place(top + left, dx: 40pt, dy: 160pt, deixis-attach(behavior: "avoid", rect(width: 50pt, height: 25pt)))
First Page
#pagebreak()
#set page(width: 240pt, height: 200pt)
#place(top + left, dx: 40pt, dy: 100pt, deixis-attach(id: <two>, rect(width: 30pt, height: 20pt)))
#place(top + left, dx: 40pt, dy: -20pt, deixis-attach(behavior: "avoid", rect(width: 50pt, height: 45pt)))
Second Page
#context {
  let records = query(<group-allocated>).map(m => m.value).sorted(key: r => r.page)
  assert.eq(records.len(), 2)
  assert.eq(records.map(r => r.peer), (2, 1))
  assert.eq(query(<group-relay-painted>).map(m => m.value).sorted(), (1, 2))
  assert.eq(heads.final().sorted(), ("body", "mark"))
  let plans = query(<deixis-routing-plan>).map(m => m.value.plan)
  assert(plans.all(p => p.routes.first().status == "ok"))
}
