#import "@preview/deixis:0.2.0": *
#set page(width: 320pt, height: 210pt, margin: 20pt)
#show: deixis-setup-notes
#show: deixis-routing.with(spacing: 8pt)
#let live = state("attached-live", 0)
#let heads = state("attached-heads", 0)
#let head(request) = (body: [#heads.update(n => n + 1)#circle(radius: 2pt)],
  trim: 2pt, bounds: (left: -2pt, top: -2pt, right: 2pt, bottom: 2pt))
#let paint(request) = {
  [#metadata((page: request.route.document.page, size: text.size,
    layer: request.route.document.layer))<collected-painted>]
  deixis-render-connector(request)
}
// A later edge influences the earlier edge despite separate declarations.
// Forward nodes, equivalent label/string names and one shared socket.
#{
  set text(size: 9pt)
  deixis-connect(from: (node: <a>), to: (node: <b>), connector: (
    ports: (mark: (side: right, at: 50%, gap: 2pt)), heads: (body: head), render: paint))
}
#deixis-connect(from: (node: "a"), to: (node: <c>), connector: (
  ports: (mark: (side: right, at: 50%, gap: 2pt)), heads: (body: head), render: paint, z-index: 3))
#place(top + left, dx: 10pt, dy: 50pt)[#deixis-attach(id: <a>, pins: (socket: (anchor: right)))[
  #live.update(n => n + 1)#rect(width: 40pt, height: 30pt)[A]]]
#place(top + left, dx: 200pt, dy: 10pt)[#deixis-attach(id: <b>)[#rect(width: 45pt, height: 30pt)[B]]]
#place(top + left, dx: 180pt, dy: 110pt)[#deixis-attach(id: <c>)[#rect(width: 45pt, height: 30pt)[C]]]
#place(top + left, dx: 90pt, dy: 20pt)[#deixis-attach(behavior: "avoid")[#rect(width: 40pt, height: 90pt)]]
// Both a covered obstacle and covered endpoints must stay out of the plan.
#hide[#place(top + left, dx: 0pt, dy: 0pt)[#deixis-attach(id: <covered>)[#rect(width: 280pt, height: 170pt)]]]
#deixis-connect(from: (node: <covered>), to: (node: <b>))
#hide[#deixis-connect(from: (node: <a>), to: (node: <b>))]
#context {
  let plans = query(<deixis-routing-plan>).map(m => m.value)
  assert.eq(plans.len(), 1)
  let p = plans.first().plan
  assert.eq(p.routes.len(), 2)
  assert(p.routes.all(r => r.status == "ok"))
  assert(p.quality.before.overlap > p.quality.after.overlap)
  assert.eq(p.quality.after.overlap, 0pt)
  assert.eq(p.quality.after.contacts, 0)
  assert.eq(p.quality.after.shared, 4pt)
  assert.eq(heads.final(), 2)
  assert.eq(live.final(), 1)
  assert.eq(query(<deixis-pin>).len(), 1)
  assert.eq(query(<collected-painted>).map(m => m.value.size), (9pt, 11pt))
}
