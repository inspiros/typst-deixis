#import "@preview/deixis:0.2.0": *
#set page(width: 340pt, height: 230pt, margin: 20pt)
#show: deixis-setup-notes
#let policy = sys.inputs.at("policy", default: "avoid")
#show: deixis-routing.with(policy: policy)
#let heads = state("policy-pages-heads", ())
#let head(r) = (body: [#heads.update(xs => xs + (r.endpoint,))#circle(radius: 2pt)], trim: 2pt,
  bounds: (left: -2pt, right: 2pt, top: -2pt, bottom: 2pt))
#let paint(r) = {
  let d = r.route.document
  assert.eq(r.route.at("search", default: none) != none, policy != "manual")
  assert.eq(d.source-page, 1)
  assert.eq(d.target-page, 2)
  assert.eq(d.continuation.peer-page, if d.page == 1 { 2 } else { 1 })
  assert.eq(d.endpoints.mark.point, r.route.origin)
  [#metadata(d.page)<policy-page-painted>]
  deixis-render-connector(r)
}
#deixis-connect(from: (node: <a>), to: (node: <b>), connector: (
  render: paint, heads: (mark: head, body: head)))
#place(top + left, dx: 220pt, dy: 60pt, deixis-attach(id: <a>, rect(width: 30pt, height: 20pt)))
First Page
#pagebreak()
#set page(width: 200pt, height: 180pt, foreground: [Host Decoration])
#show: deixis-setup-notes
#place(top + left, dx: 70pt, dy: 80pt, deixis-attach(id: <b>, rect(width: 30pt, height: 20pt)))
Second Page
#context {
  assert.eq(query(<policy-page-painted>).map(m => m.value).sorted(), (1, 2))
  assert.eq(heads.final().sorted(), ("body", "mark"))
  let plans = query(<deixis-routing-plan>).map(m => m.value)
  assert.eq(plans.len(), if policy == "manual" { 0 } else { 2 })
  if policy == "avoid" {
    assert(plans.all(p => p.plan.stats.searches == 1 and p.plan.quality == none))
  }
}
