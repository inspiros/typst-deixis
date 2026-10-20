#import "../../src/lib.typ": *
#set page(width: 320pt, height: 240pt, margin: 20pt)
#show: deixis-setup-notes
#show: deixis-routing.with(weight: 0)
#let paint(request) = {
  let doc = request.route.document
  assert.eq(request.crossings.order.first(), doc.z-index)
  [#metadata((z: doc.z-index, cuts: request.crossings.cuts.len()))<collected-crossing>]
  deixis-render-connector(request)
}
#let node(id, x, y) = place(top + left, dx: x, dy: y,
  deixis-attach(id: id, behavior: "ignore", rect(width: 20pt, height: 20pt)))
#node(<a>, 0pt, 90pt)
#node(<b>, 240pt, 90pt)
#node(<c>, 120pt, 0pt)
#node(<d>, 120pt, 180pt)
#deixis-connect(from: (node: <a>), to: (node: <b>), connector: (
  crossings: "gap", render: paint, z-index: 0))
#deixis-connect(from: (node: <c>), to: (node: <d>), connector: (
  crossings: "gap", render: paint, z-index: 2))
#context {
  let paints = query(<collected-crossing>).map(m => m.value).sorted(key: p => p.z)
  assert.eq(paints, ((z: 0, cuts: 1), (z: 2, cuts: 0)))
}
