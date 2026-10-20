#import "../../src/lib.typ": *
#import "../../src/routing/document-policy.typ": _deixis-routing-policy
#set page(width: 360pt, height: 260pt, margin: 25pt)
#show: deixis-setup-notes
#let body() = deixis-inset-note-body(id: <obstacle>, connector: none, width: 65pt,
  placement: x => place(top + left, dx: 120pt, dy: 90pt, x))[
    #block(height: 70pt)[A Note Body]
]
#let paint(name, r) = [#metadata((name: name, route: r.route))<node-scope-painted>]
#let connection(name) = deixis-connect(from: (pin: <a>), to: (pin: <b>),
  connector: (render: paint.with(name)))
#place(top + left, dx: 10pt, dy: 110pt, deixis-pin(<a>, padding: 0pt))
#place(top + left, dx: 285pt, dy: 110pt, deixis-pin(<b>, padding: 0pt))
#body()
#{
  set text(size: 20pt)
  deixis-routing(policy: "avoid", nodes: ((body: <obstacle>, padding: 0.5em),))[
    #context assert.eq(_deixis-routing-policy().nodes.first().padding, 10pt)
    #connection("outer-before")
    #deixis-routing(policy: "avoid")[#connection("inner")]
    #connection("outer-after")
  ]
}
#deixis-routing(policy: "manual", nodes: ((body: <not-created>),))[
  #connection("manual")
]
// Unused selectors do not require layout or a printed body. Shape validation
// still runs even when policy is manual or the wrapper contains no edges.
#deixis-routing(nodes: ((body: <not-created>),))[No Connections]
#let verify() = {
  let records = query(<node-scope-painted>).map(m => m.value)
  assert.eq(records.len(), 4)
  let named(name) = records.find(r => r.name == name).route
  assert.eq(named("outer-before").segments, named("outer-after").segments)
  assert(named("outer-before").length > named("inner").length)
  assert.eq(named("manual").at("search", default: none), none)
  assert.eq(query(<deixis-routing-plan>).len(), 2)
}
