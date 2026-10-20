#import "@preview/deixis:0.2.0": *
#set page(width: 300pt, height: 230pt, margin: 20pt)
#show: deixis-setup-notes
#let pair(scope) = {
  place(top + left, dx: 10pt, dy: 40pt, deixis-attach(id: <a>, scope: scope, rect(width: 40pt, height: 20pt)))
  place(top + left, dx: 200pt, dy: 100pt, deixis-attach(id: <b>, scope: scope, rect(width: 40pt, height: 20pt)))
}
#let edge(scope, layer: "foreground") = deixis-connect(from: (node: <a>, scope: scope), to: (node: <b>, scope: scope),
  connector: (layer: layer, heads: "triangle"))
#deixis-routing[
  #edge(<first>)
  #deixis-routing[
    #edge("first", layer: "background")
    #edge("first")
  ]
  #edge("first")
  #pair("first")
]
#pagebreak()
// Repeated unscoped IDs on different pages pick the declaration's local page.
#deixis-routing[
  #edge(none)
  #pair(none)
]
#pagebreak()
#deixis-routing[
  #pair(none)
  #edge(none)
]
#context {
  let plans = query(<deixis-routing-plan>).map(m => m.value)
  assert.eq(plans.len(), 5)
  assert.eq(plans.filter(p => p.page == 1).map(p => p.plan.routes.len()).sorted(), (1, 1, 2))
  assert.eq(plans.filter(p => p.page == 1 and p.layer == "background").len(), 1)
  assert.eq(plans.filter(p => p.page in (2, 3)).map(p => p.plan.routes.len()), (1, 1))
  assert(plans.all(p => p.plan.routes.all(r => r.status == "ok")))
}
