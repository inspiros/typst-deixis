#import "../../src/lib.typ": *
#let forward = sys.inputs.at("direction", default: "backward") == "forward"
#set text(size: 10pt)
#set page(width: if forward { 600pt } else { 240pt }, height: 250pt, margin: (left: 30pt, right: 2em, y: 30pt))
#show: deixis-setup-notes
#let mode = sys.inputs.at("mode", default: "custom")
#let adapter = sys.inputs.at("adapter", default: "explicit")
#let marker(request) = {
  assert(not request.relay)
  assert.eq(request.frame, "continuation-local-x-right-y-down")
  assert(request.page != request.peer-page)
  assert.eq(request.direction, if (request.page == 1) == forward { "outgoing" } else { "incoming" })
  assert.eq(request.normal, if request.page == 1 { (0, 1) } else { (0, -1) })
  [#metadata((page: request.page, peer: request.peer-page, x: request.point.first()))<continuation>]
  place(center + horizon, text(size: 7pt, [→ #request.peer-page]))
}
#let painter(request) = {
  let c = request.route.document.continuation
  assert(c != none and c.page == request.route.document.page)
  let region = c.allocation.region
  assert(region.left <= c.point.first() and c.point.first() <= region.right)
  [#metadata((page: c.page, x: c.point.first()))<continuation-half>]
  deixis-render-connector(request)
}
#let options = (route: "polyline", heads: "triangle", render: painter,
  stroke: if mode == "disabled" { none } else { blue + 1pt },
  continuation: if mode == "custom" { marker } else if mode == "hidden" { none } else { auto })
#if adapter == "explicit" {
  deixis-connect(from: (pin: <a>), to: (pin: <b>), connector: options)
  if forward { place(top + left, dx: 510pt, deixis-pin(<a>)) } else { deixis-pin(<b>) }
} else if forward {
  place(top + left, dx: 510pt, deixis-mark(id: <a>)[Source])
} else {
  deixis-inset-note-body(of: <a>, width: 60pt, placement: x => place(top + left, x), connector: options)[Body]
}
Narrow Destination
#pagebreak()
Intervening Page
#pagebreak()
#set text(size: 20pt)
#set page(width: if forward { 240pt } else { 600pt }, height: 300pt)
// A source to the right of the narrow page's edge used to give off-page relays.
#if adapter == "explicit" {
  if forward { deixis-pin(<b>) } else { place(top + left, dx: 510pt, deixis-pin(<a>)) }
} else if forward {
  deixis-inset-note-body(of: <a>, width: 60pt, placement: x => place(top + left, x), connector: options)[Body]
} else {
  place(top + left, dx: 510pt, deixis-mark(id: <a>)[Source])
}
#context {
  let markers = query(<continuation>)
  assert.eq(markers.len(), if mode == "custom" { 2 } else { 0 })
  let halves = query(<continuation-half>).map(n => n.value)
  assert.eq(halves.len(), 2)
  assert.eq(halves.map(h => h.page).sorted(), (1, 3))
  assert.ne(halves.first().x, halves.last().x)
}
