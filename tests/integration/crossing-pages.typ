#import "../../src/lib.typ": *
#set page(width: 460pt, height: 280pt, margin: (x: 95pt, y: 35pt))
#show: deixis-setup-notes
#let layer = sys.inputs.at("edge-layer", default: "foreground")
#let enabled = sys.inputs.at("crossings", default: "on") == "on"
#let live = state("crossing-pages-live", 0)
#let paint(name, request) = {
  [#metadata((name: name, page: request.route.document.page, plan: request.crossings,
    original: request.route.segments, manual: request.manual-shaft,
    heads: (request.heads.mark != none, request.heads.body != none)))<cross-page-route>]
  deixis-render-connector(request)
}
#let route-kind = sys.inputs.at("route", default: "polyline")
#if sys.inputs.at("route-settings", default: "off") == "on" {
  route-kind = (kind: route-kind, tension: 2)
}
#let options = (route: route-kind, layer: layer, crossings: if enabled { "gap" } else { none })
#let local(number) = {
  place(top + left, dx: 10pt, dy: 80pt, deixis-pin("left-" + str(number), padding: 0pt))
  place(top + left, dx: 330pt, dy: 80pt, deixis-pin("right-" + str(number), padding: 0pt))
  deixis-connect(from: (pin: "left-" + str(number)), to: (pin: "right-" + str(number)),
    connector: options + (z-index: 1, stroke: red + 1pt, render: paint.with("local")))
}
#deixis-mark(id: <shared>)[Source]
#local(1)
#pagebreak()
#deixis-inset-note-body(of: <shared>, layer: "foreground", dx: 155pt, dy: 130pt, width: 80pt,
  connector: options + (heads: (mark: "circle", body: "triangle"), stroke: blue + 1pt,
    render: paint.with("shared")))[#live.update(n=>n+1)One body.]
#local(2)
#link(<shared>)[Body]
#let verify() = {
  assert.eq(live.final(), 1)
  let routes = query(<cross-page-route>).map(m=>m.value)
  assert.eq(routes.len(), 4)
  for page in (1, 2) {
    let shared = routes.find(r => r.name == "shared" and r.page == page)
    assert.eq(shared.heads, if page == 1 { (true, false) } else { (false, true) })
    assert.eq(if shared.plan == none { 0 } else { shared.plan.hits.len() }, if enabled { 1 } else { 0 })
  }
  let pos = query(<shared>).first().location().position()
  (routes: routes, destinations: ((page: pos.page, x: pos.x.pt(), y: pos.y.pt()),))
}
