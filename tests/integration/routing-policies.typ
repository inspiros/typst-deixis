#import "@preview/deixis:0.2.0": *
#set page(width: 320pt, height: 240pt, margin: 20pt)
#show: deixis-setup-notes
#let edge(name, searched) = {
  let paint(r) = {
    assert.eq(r.route.at("search", default: none) != none, searched)
    [#metadata(name)<policy-painted>]
    deixis-render-connector(r)
  }
  deixis-connect(from: (node: <a>), to: (node: <b>), connector: (render: paint, heads: "triangle"))
}
#place(top + left, dx: 10pt, dy: 60pt, deixis-attach(id: <a>, rect(width: 30pt, height: 20pt)))
#place(top + left, dx: 230pt, dy: 60pt, deixis-attach(id: <b>, rect(width: 30pt, height: 20pt)))
// Native scope nesting and restoration, followed by sequential show-rule policy
// changes in one lexical scope. Declarations capture their policy immediately.
#deixis-routing[
  #edge("outer-one", true)
  #deixis-routing(policy: "avoid")[
    #edge("avoid-one", true)
    #deixis-routing(policy: "manual")[#edge("manual-one", false)]
    #edge("avoid-two", true)
  ]
  #edge("outer-two", true)
]
#hide[#deixis-routing(policy: "avoid")[#edge("covered", true)]]
#edge("outside", false)
#block[
  #show: deixis-routing.with(policy: "avoid")
  #edge("show-avoid", true)
  #show: deixis-routing.with(policy: "manual")
  #edge("show-manual", false)
  #show: deixis-routing.with(policy: "separate")
  #edge("show-separate", true)
]
#context {
  let plans = query(<deixis-routing-plan>).map(m => m.value)
  assert.eq(plans.len(), 4)
  assert.eq(plans.map(p => p.policy).sorted(), ("avoid", "avoid", "separate", "separate"))
  assert.eq(plans.filter(p => p.policy == "avoid").map(p => p.plan.stats.searches).sorted(), (1, 2))
  assert(plans.filter(p => p.policy == "avoid").all(p => p.plan.quality == none and p.plan.stats.rounds == 0))
  assert(plans.filter(p => p.policy == "separate").all(p => p.plan.quality != none))
  assert.eq(query(<policy-painted>).map(m => m.value).sorted(), (
    "avoid-one", "avoid-two", "manual-one", "outer-one", "outer-two", "outside",
    "show-avoid", "show-manual", "show-separate"))
}
