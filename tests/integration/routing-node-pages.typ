#import "../../src/lib.typ": *
#set page(width: 360pt, height: 260pt, margin: 25pt)
#set text(size: 10pt)
#show: deixis-setup-notes
#let policy = sys.inputs.at("policy", default: "separate")
#let layer = sys.inputs.at("layer", default: "foreground")
#show: deixis-routing.with(policy: policy, nodes: ((body: <first>), (body: <last>)))
#let live = state("node-page-live", 0)
#let paint(name, r) = {
  [#metadata((name: name, page: r.route.document.page, route: r.route))<node-page-painted>]
  deixis-render-connector(r)
}
#let marker(r) = {
  let other = (r.counterpart)()
  if other == none { return [] }
  [#metadata((page: r.page, point: r.point, counterpart: other.point,
    destination: other.destination))<node-page-counterpart>]
  link(other.destination, circle(radius: 2pt))
}
#let drawing(name, wide: false) = {
  place(top + left, dx: 10pt, dy: 110pt, deixis-pin("a" + name, padding: 0pt))
  place(top + left, dx: if wide { 335pt } else { 295pt }, dy: 110pt,
    deixis-pin("b" + name, padding: 0pt))
  deixis-connect(from: (pin: "a" + name), to: (pin: "b" + name),
    connector: (layer: layer, render: paint.with(name)))
}
#drawing("one")
#deixis-connect(from: (pin: "aone"), to: (body: <last>), connector: (
  layer: layer, render: paint.with("cross"), continuation: marker))
#deixis-inset-note-body(id: <first>, connector: none, layer: "background", width: 65pt,
  placement: x => place(top + left, dx: 120pt, dy: 90pt, x))[
  #live.update(n => n + 1)#block(height: 70pt)[First Body]
]
First Page
#pagebreak()
#drawing("middle")
Empty Scene Page
#pagebreak()
#set page(width: 400pt, height: 280pt, foreground: [Host Decoration], numbering: "1")
#show: deixis-setup-notes
#drawing("three", wide: true)
#deixis-inset-note-body(id: <last>, connector: none, width: 65pt,
  placement: x => place(top + left, dx: 120pt, dy: 90pt, x))[
  #live.update(n => n + 1)#block(height: 70pt)[Last Body]
]
Last Page
#let verify() = {
  assert.eq(live.final(), 2)
  let routes = query(<node-page-painted>).map(m => m.value)
  assert.eq(routes.len(), 5)
  assert.eq(routes.filter(r => r.name == "cross").map(r => r.page).sorted(), (1, 3))
  if policy != "manual" {
    let by(name) = routes.find(r => r.name == name).route
    assert(by("one").length > 285pt)
    assert.eq(by("middle").length, 285pt)
    assert(by("three").length > 325pt)
  }
  let points = query(<node-page-counterpart>).map(m => m.value)
  assert.eq(points.len(), 2)
  assert.eq(points.first().counterpart, points.last().point)
  assert.eq(points.last().counterpart, points.first().point)
  (destinations: points.map(m => (page: m.destination.page,
    x: m.destination.x.pt(), y: m.destination.y.pt())))
}
