#import "../../src/lib.typ": *
#set page(width: 400pt, height: 260pt, margin: 25pt)
#set text(size: 10pt)
#show: deixis-setup-notes
#let adapter = sys.inputs.at("adapter", default: "explicit")
#let mode = sys.inputs.at("mode", default: "both")
#let layer = sys.inputs.at("layer", default: "foreground")
#let direction = sys.inputs.at("direction", default: "same")
#let inline = sys.inputs.at("mark", default: "region") == "inline"
#let visits = sys.inputs.at("visits", default: "off") == "on"
#let delegated = sys.inputs.at("painter", default: "delegate") == "delegate"
#let ticks = state("selected-port-bodies", 0)
#let heads = state("selected-port-heads", ())
#let head(request) = (body: [#heads.update(xs => xs + (request.endpoint,))#circle(radius: 1pt)],
  trim: 1pt, bounds: (left: -1pt, right: 1pt, top: -1pt, bottom: 1pt))
#let scene(doc) = {
  let blocks(role, active) = if not active { () } else {
    let p = doc.endpoints.at(role).point
    ((page: doc.page, bounds: (left: p.first() - 1pt, right: p.first() + 1pt,
      top: p.last() - 1pt, bottom: p.last() + 1pt)),)
  }
  deixis-routing-scene(clearance: 1pt, escape: 3pt, nodes: ((mark: <note>), (body: <note>))
    + blocks("mark", not doc.is-incoming and mode in ("source", "both"))
    + blocks("body", not doc.is-outgoing and mode in ("target", "both")),
    pages: ((page: doc.page, bounds: (left: 0pt, right: 400pt, top: 0pt, bottom: 260pt)),))
}
#let paint(request) = {
  let r = request.route
  let doc = r.document
  assert.eq(r.origin, doc.endpoints.mark.point)
  assert.eq(r.origin.zip(r.end).map(((a, b)) => a + b), doc.endpoints.body.point)
  assert.eq(doc.fragment.source, doc.endpoints.mark)
  assert.eq(doc.fragment.target, doc.endpoints.body)
  assert.eq(r.start-tangent, doc.endpoints.mark.normal)
  assert.eq(r.end-tangent.map(v => -v), doc.endpoints.body.normal)
  let changed = if doc.is-incoming { mode in ("target", "both") } else if doc.is-outgoing { mode in ("source", "both") } else { mode != "clear" }
  assert.eq(r.search.at("attempts", default: 1), if changed { 2 } else { 1 })
  if visits {
    let points = r.segments.map(s => s.end.zip(r.origin).map(((v, o)) => v + o))
    let expected = if doc.is-incoming { (230pt, 170pt) } else { (150pt, 170pt) }
    assert(expected in points)
  }
  [#metadata((document: doc, origin: r.origin, end: r.end, search: r.search))<selected-port>]
  deixis-render-connector(request)
}
#let options = (route: "orthogonal", radius: 0pt, layer: layer, stroke: blue + 0.6pt, heads: (mark: head, body: head),
  scene: scene, render: if delegated { paint } else { none }, continuation: none,
  via: if not visits { auto } else if direction == "same" { ((relative-to: "page", offset: (150pt, 170pt)),) }
    else { ((relative-to: "page", offset: (150pt, 170pt)), "split", (relative-to: "page", offset: (230pt, 170pt))) })
#let source() = place(top + left, dx: 30pt, dy: 80pt,
  if inline { deixis-mark(id: <note>)[Source] } else {
    deixis-mark(id: <note>, mark-type: "region", inline: true)[#box(width: 50pt, height: 30pt)[Source]]
  })
#let target() = deixis-inset-note-body(of: <note>, width: 65pt, layer: layer,
  connector: if adapter == "inset" { options } else { none },
  placement: x => place(top + left, dx: 270pt, dy: 80pt, x))[#ticks.update(n => n + 1)One Body]
#if adapter == "explicit" { deixis-connect(from: <note>, to: <note>, connector: options) }
#if direction == "backward" { target() } else { source() }
First Page
#if direction != "same" { pagebreak(); [Second Page]; pagebreak(); [Third Page] }
#if direction == "backward" { source() } else { target() }
#let verify() = {
  assert.eq(ticks.final(), 1)
  assert.eq(heads.final().sorted(), ("body", "mark"))
  let records = query(<selected-port>).map(m => m.value)
  assert.eq(records.len(), if not delegated { 0 } else if direction == "same" { 1 } else { 2 })
  assert.eq(query(<deixis-scene-route>).len(), if direction == "same" { 1 } else { 2 })
  records
}
