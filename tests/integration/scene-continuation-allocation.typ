#import "../../src/lib.typ": *
#let forward = sys.inputs.at("direction", default: "forward") == "forward"
#let font-page = sys.inputs.at("units", default: "pt") == "em"
#let mixed = sys.inputs.at("widths", default: "equal") == "mixed"
#let width-of-page(p) = if mixed and (if forward { p == 3 } else { p != 3 }) { 300pt } else { 400pt }
#set text(size: 10pt)
#set page(width: if font-page { 40em } else { width-of-page(1) }, height: if font-page { 26em } else { 260pt },
  margin: if font-page { 3em } else { 30pt })
#show: deixis-setup-notes
#let adapter = sys.inputs.at("adapter", default: "explicit")
#let mode = sys.inputs.at("mode", default: "blocked")
#let layer = sys.inputs.at("layer", default: "foreground")
#let visits = sys.inputs.at("visits", default: "off") == "on"
#let delegated = sys.inputs.at("painter", default: "delegate") == "delegate"
#let live = state("allocated-heads", ())
#let body-live = state("allocated-body", 0)
#let head(request) = (body: [#live.update(xs => xs + (request.endpoint,))#circle(radius: 2pt)],
  trim: 2pt, bounds: (left: -2pt, right: 2pt, top: -2pt, bottom: 2pt))
#let scene(doc) = {
  let c = doc.continuation
  assert.eq(c.point, c.allocation.preferred)
  assert(not c.allocation.shifted)
  let p = c.point
  let boxes = if mode == "blocked" {
    ((page: doc.page, bounds: (left: p.first() - 12pt, right: p.first() + 12pt,
      top: p.last() - 12pt, bottom: p.last() + 12pt)),)
  } else if mode == "unreachable" and doc.is-incoming {
    ((page: doc.page, bounds: (left: 170pt, right: 190pt, top: 0pt, bottom: 260pt)),)
  } else { () }
  deixis-routing-scene(nodes: boxes + if adapter == "inset" { ((mark: <note>), (body: <note>)) } else { () },
    pages: ((page: doc.page, bounds: (left: 0pt, top: 0pt, right: width-of-page(doc.page), bottom: 260pt)),))
}
#let marker(request) = {
  assert(0pt <= request.point.first() and request.point.first() <= width-of-page(request.page))
  assert(0pt <= request.point.last() and request.point.last() <= 260pt)
  assert.eq(request.allocation.shifted, mode == "blocked")
  assert(request.allocation.automatic)
  // Local destination projection already lies on the reachable side of the
  // full-height wall; the old source-derived incoming preference did not.
  let region = request.allocation.region
  assert(region.left <= request.point.first() and request.point.first() <= region.right)
  [#metadata((page: request.page, point: request.point, allocation: request.allocation))<allocated-marker>]
  [#metadata((page: request.peer.page, x: request.peer.point.first().pt(), y: request.peer.point.last().pt()))<allocation-destination>]
  place(center + horizon, link(request.peer.destination, [↗]))
}
#let paint(request) = {
  let doc = request.route.document
  assert.eq(request.route.origin, doc.endpoints.mark.point)
  assert.eq(request.route.origin.zip(request.route.end).map(((a, b)) => a + b), doc.endpoints.body.point)
  assert.eq(doc.fragment.source, doc.endpoints.mark)
  assert.eq(doc.fragment.target, doc.endpoints.body)
  assert.eq(doc.continuation.point, if doc.is-incoming { doc.endpoints.mark.point } else { doc.endpoints.body.point })
  assert.eq(request.heads.mark != none, doc.is-outgoing)
  assert.eq(request.heads.body != none, doc.is-incoming)
  if visits {
    let x = if doc.is-outgoing { 320pt } else { 80pt }
    let p = (x - request.route.origin.first(), 150pt - request.route.origin.last())
    assert(request.route.segments.any(s => s.start == p or s.end == p))
  }
  [#metadata((page: doc.page, search: request.route.search, point: doc.continuation.point))<allocated-route>]
  deixis-render-connector(request)
}
#let options = (route: "orthogonal", radius: 0pt, layer: layer, scene: scene, heads: (mark: head, body: head),
  render: if delegated { paint } else { none }, continuation: marker,
  via: if visits { ((pin: <vs>), "split", (pin: <vt>)) } else { auto })
#if adapter == "explicit" {
  text(size: 20pt, deixis-connect(from: (pin: <a>), to: (pin: <b>), connector: options))
}
#let source() = {
  if adapter == "explicit" { place(top + left, dx: 300pt, dy: 70pt, deixis-pin(<a>, padding: 0pt)) }
  else { place(top + left, dx: 270pt, dy: 70pt, deixis-mark(id: <note>)[Source]) }
  place(top + left, dx: 290pt, dy: 120pt, deixis-pin(<vs>, padding: 0pt))
}
#let target() = {
  if adapter == "explicit" { place(top + left, dx: 40pt, dy: 70pt, deixis-pin(<b>, padding: 0pt)) }
  else { deixis-inset-note-body(of: <note>, width: 60pt, layer: layer, connector: options,
    placement: x => place(top + left, dx: 40pt, dy: 70pt, x))[#body-live.update(n => n + 1)Body] }
  place(top + left, dx: 50pt, dy: 120pt, deixis-pin(<vt>, padding: 0pt))
}
#if forward { source() } else { target() }
First Page
#pagebreak()
Intervening Page
#pagebreak()
#set page(width: if font-page { 40em } else { width-of-page(3) })
#if forward { target() } else { source() }
Third Page
#let verify() = {
  let frames = query(<deixis-page-frame>).map(m => m.value)
  assert(frames.all(f => f.width == width-of-page(f.page) and f.height == 260pt and f.margins.left == 30pt and f.margins.top == 30pt))
  assert.eq(live.final().sorted(), ("body", "mark"))
  assert.eq(body-live.final(), if adapter == "inset" { 1 } else { 0 })
  assert.eq(query(<deixis-scene-route>).len(), 2)
  assert.eq(query(<allocated-route>).len(), if delegated { 2 } else { 0 })
  let markers = query(<allocated-marker>).map(m => m.value).sorted(key: m => m.page)
  assert.eq(markers.map(m => m.page), (1, 3))
  (markers: markers, destinations: query(<allocation-destination>).map(m => m.value))
}
