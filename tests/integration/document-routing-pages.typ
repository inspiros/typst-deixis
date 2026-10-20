#import "@preview/deixis:0.2.0": *
#set page(width: 340pt, height: 230pt, margin: 20pt)
#show: deixis-setup-notes
#show: deixis-routing
#let heads = state("collected-page-heads", ())
#let head(request) = (body: [#heads.update(xs => xs + (request.endpoint,))#circle(radius: 2pt)],
  trim: 2pt, bounds: (left: -2pt, top: -2pt, right: 2pt, bottom: 2pt))
#let paint(request) = {
  let doc = request.route.document
  assert.eq(request.route.page, doc.page)
  [#metadata((page: doc.page, incoming: doc.is-incoming, outgoing: doc.is-outgoing,
    peer: if doc.continuation == none { none } else { doc.continuation.peer-page },
    source: request.route.origin, target: request.route.origin.zip(request.route.end).map(((a, b)) => a + b)))<collected-page>]
  deixis-render-connector(request)
}
#deixis-connect(from: (node: <from>), to: (node: <to>), connector: (
  heads: (mark: head, body: head), render: paint))
#place(top + left, dx: 200pt, dy: 60pt)[#deixis-attach(id: <from>)[#rect(width: 40pt, height: 20pt)]]
First Page
#pagebreak()
Middle Page
#pagebreak()
#set page(width: 200pt, height: 180pt)
#place(top + left, dx: 90pt, dy: 80pt)[#deixis-attach(id: <to>)[#rect(width: 30pt, height: 20pt)]]
Last Page
#context {
  let plans = query(<deixis-routing-plan>).map(m => m.value)
  assert.eq(plans.map(p => p.page).sorted(), (1, 3))
  let paints = query(<collected-page>).map(m => m.value).sorted(key: p => p.page)
  assert.eq(paints.map(p => p.peer), (3, 1))
  assert.eq(paints.map(p => (p.incoming, p.outgoing)), ((false, true), (true, false)))
  assert.eq(heads.final().sorted(), ("body", "mark"))
  assert(paints.last().source.first() <= 200pt)
  assert(paints.last().target.first() <= 200pt)
}
