#import "../../src/lib.typ": *
#set text(size: 10pt)
#set page(width: 500pt, height: 260pt, margin: (x: 110pt, y: 30pt))
#show: deixis-setup-notes
#let kind = sys.inputs.at("kind", default: "margin")
#let policy = sys.inputs.at("policy", default: "native")
#let body-layer = sys.inputs.at("body", default: "foreground")
#let edge-layer = sys.inputs.at("layer", default: "foreground")
#let backwards = sys.inputs.at("direction", default: "forward") == "backward"
#show: body => if policy == "native" { body } else { deixis-routing(policy: policy, body) }
#let live = state("counterpart-note-body", 0)
#let marker(name, r) = {
  let other = (r.counterpart)()
  if other == none { return [] }
  assert.eq(other.page, r.peer-page)
  assert.ne(other.direction, r.direction)
  [#metadata((name: name, page: r.page, point: r.point,
    counterpart: other.point, destination: other.destination))<note-counterpart>]
  place(center + horizon, dy: -r.normal.last() * 8pt,
    link(other.destination, box(width: 25pt, height: 12pt, fill: white,
      text(size: 7pt, [#name ↔]))))
}
#let options(name) = (route: "orthogonal", radius: 0pt, layer: edge-layer, continuation: marker.with(name))
#let body() = deixis-inset-note-body(of: <note>, layer: body-layer, width: 65pt,
  placement: x => place(top + left, dx: 100pt, dy: 80pt, x), connector: options("inset"))[
  #live.update(n => n + 1)Body]
#if kind == "margin" {
  for i in range(5) {
    deixis-margin-note(id: "note" + str(i), layer: body-layer, width: 85pt, connector: options(str(i)),
      [Source #i], [#live.update(n => n + 1)#block(height: 85pt)[Body #i]])
  }
} else if backwards { body() } else {
  place(top + left, dy: 50pt, deixis-mark(id: <note>)[Source])
}
First Page
#pagebreak()
Middle Page
#pagebreak()
#set page(width: 440pt, height: 280pt, foreground: [Host Decoration])
#show: deixis-setup-notes
#if kind == "inset" {
  if backwards { place(top + left, dy: 50pt, deixis-mark(id: <note>)[Source]) } else { body() }
}
Last Page
#context {
  assert.eq(live.final(), if kind == "margin" { 5 } else { 1 })
}
#let verify() = {
  let records = query(<note-counterpart>).map(m => m.value)
  assert.eq(records.len(), if kind == "margin" { 6 } else { 2 })
  for r in records {
    let other = records.find(p => p.name == r.name and p.page != r.page)
    assert.eq(r.counterpart, other.point)
    assert.eq(r.destination.page, other.page)
    assert.eq((r.destination.x, r.destination.y), other.point)
  }
  (destinations: records.map(m => (page: m.destination.page, x: m.destination.x.pt(), y: m.destination.y.pt())))
}
