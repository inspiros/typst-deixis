#import "../../src/lib.typ": *
#set page(width: 360pt, height: 250pt, margin: 30pt)
#set text(size: 10pt)
#show: deixis-setup-notes
#let policy = sys.inputs.at("policy", default: "native")
#let backwards = sys.inputs.at("direction", default: "forward") == "backward"
#let edge-layer = sys.inputs.at("layer", default: "foreground")
#let mode = sys.inputs.at("mode", default: "distinct")
#let where = sys.inputs.at("where", default: "marker")
#show: body => if policy == "native" { body } else { deixis-routing(policy: policy, body) }
#let heads = state("counterpart-heads", ())
#let head(r) = (body: [#heads.update(xs => xs + (r.endpoint,))#circle(radius: 1.5pt)],
  trim: 1.5pt, bounds: (left: -1.5pt, top: -1.5pt, right: 1.5pt, bottom: 1.5pt))
#let marker(index, r) = {
  let other = (r.counterpart)()
  if other == none { return [] }
  assert.eq(other.page, if r.page == 1 { 3 } else { 1 })
  assert.ne(other.direction, r.direction)
  assert.eq(other.normal, r.normal.map(v => -v))
  [#metadata((index: index, page: r.page, point: r.point,
    counterpart: other.point, destination: other.destination))<counterpart-painted>]
  place(center + horizon, dx: if index == 0 { -20pt } else { 20pt }, dy: -r.normal.last() * 9pt,
    link(other.destination, box(width: 34pt, height: 13pt, fill: white, stroke: blue + 0.5pt,
      align(center + horizon, text(size: 7pt, [#index ↔])))))
}
#let paint(index, r) = {
  assert.eq(r.route.document.continuation.point,
    if r.route.document.is-incoming { r.route.origin } else { r.route.origin.zip(r.route.end).map(((a, b)) => a + b) })
  deixis-render-connector(r)
  if where == "shaft" {
    let c = r.route.document.continuation
    place(top + left, dx: c.point.first() - r.route.origin.first(),
      dy: c.point.last() - r.route.origin.last(), marker(index, c))
  }
}
#let legacy(index, r) = {
  let c = r.continuation
  place(top + left, dx: c.point.first() - r.S-x, dy: c.point.last() - r.S-y, marker(index, c))
  line(end: (r.E-x - r.S-x, r.E-y - r.S-y), stroke: r.stroke)
}
#for i in range(2) {
  // Duplicate declarations can share both endpoints. The split distinguishes
  // the remote boundary; declarations, not endpoint names, own the pairing.
  let split = if mode == "shared" { 140pt } else { (100 + i * 90) * 1pt }
  deixis-connect(from: (pin: if backwards { <b> } else { <a> }),
    to: (pin: if backwards { <a> } else { <b> }), connector: (
      route: if where == "legacy" { legacy.with(i) } else { "orthogonal" }, radius: 0pt, layer: edge-layer,
      via: if mode == "allocated" { auto } else { ((relative-to: "page", offset: (split, 150pt)), ("split", 0pt)) },
      heads: (mark: head, body: head), render: if where == "legacy" { none } else { paint.with(i) },
      continuation: if where in ("shaft", "legacy") { none } else { marker.with(i) }))
}
#place(top + left, dx: 40pt, dy: 60pt, deixis-pin(<a>, padding: 0pt))
#if mode == "allocated" {
  let x = if backwards { 185pt } else { 70pt }
  place(top + left, dx: x - 50pt, dy: 170pt,
    deixis-attach(behavior: "avoid", rect(width: 40pt, height: 35pt)))
}
First Page
#pagebreak()
Middle Page
#pagebreak()
#set page(width: 280pt, height: 290pt, margin: 25pt, foreground: [Host Decoration])
#show: deixis-setup-notes
#place(top + left, dx: 160pt, dy: 70pt, deixis-pin(<b>, padding: 0pt))
#if mode == "allocated" {
  let x = if backwards { 185pt } else { 70pt }
  place(top + left, dx: x - 65pt, dy: -25pt,
    deixis-attach(behavior: "avoid", rect(width: 70pt, height: 45pt)))
}
Last Page
#context {
  let records = query(<counterpart-painted>).map(m => m.value)
  assert.eq(records.len(), 4)
  assert.eq(heads.final().sorted(), if where == "legacy" { () } else { ("body", "body", "mark", "mark") })
  assert.eq(query(<deixis-continuation-site>).len(), 4)
  for r in records {
    let other = records.find(p => p.index == r.index and p.page != r.page)
    assert.eq(r.counterpart, other.point)
    assert.eq((r.destination.x, r.destination.y), other.point)
  }
}
#let verify() = (destinations: query(<counterpart-painted>).map(m => {
  let d = m.value.destination
  (page: d.page, x: d.x.pt(), y: d.y.pt())
}))
