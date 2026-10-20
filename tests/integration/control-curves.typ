#import "../../src/lib.typ": *
#set page(width: 470pt, height: 300pt, margin: (x: 95pt, y: 35pt))
#show: deixis-setup-notes
#let kind = sys.inputs.at("kind", default: "explicit")
#let layer = sys.inputs.at("layer", default: "foreground")
#let edge = sys.inputs.at("edge", default: "foreground")
#let form = sys.inputs.at("form", default: "local")
#let syntax = sys.inputs.at("syntax", default: "pins")
#let count = int(sys.inputs.at("count", default: "4"))
#let crossing = sys.inputs.at("crossings", default: "off") == "on"
#let cut = sys.inputs.at("cuts", default: "on") == "on"
#let live = state("control-curve-body", 0)
#let painted = state("control-curve-paint", 0)
#let head-live = state("control-curve-head", 0)
#let head(request) = (
  body: [#head-live.update(n => n + 1)#circle(radius: 2pt, fill: request.fill, stroke: none)],
  trim: 3pt, bounds: (left: -2pt, right: 2pt, top: -2pt, bottom: 2pt))
#let paint(request) = {
  [#painted.update(n => n + 1)#metadata((route: request.route, shaft: request.shaft, crossings: request.crossings,
    heads: (request.heads.mark != none, request.heads.body != none)))<control-curve>]
  deixis-render-connector(request)
}
#let points = ((40pt, 20pt), (90pt, 130pt), (160pt, 10pt), (200pt, 150pt)).slice(0, count)
#let pin(name) = (name: name, scope: <controls>)
#let controls = points.enumerate().map(((i, p)) => if syntax == "pins" { (pin: pin("c" + str(i))) }
  else { (relative-to: "page", offset: (95pt + p.first(), 35pt + p.last())) })
#let spec = (kind: "b-spline", controls: controls)
#let options = (route: spec, layer: edge, heads: (mark: "bar", body: head),
  stroke: blue + 0.8pt, render: paint, cuts: if cut { (at: 75%, length: 8pt) } else { none },
  crossings: if crossing { "gap" } else { none }, gap-marks: "slash")
#if kind == "cross-page" { options.via = ("split", spec) }
#if form in ("mixed", "via") {
  if form == "mixed" { options.segments = ((route: spec, via: ((pin: pin("joint")),)), (route: spec)) }
  else { options.via = ((pin: pin("joint")), spec) }
}
#if form == "settings" { deixis-set(connector: options) }
#if form == "flat" { deixis-set(connector: (route: spec)) }
#let selected = if form == "settings" { auto } else if form == "flat" {
  let value = options
  let _ = value.remove("route")
  value
} else { options }
#let place-controls() = {
  for (i, p) in points.enumerate() {
    place(top + left, dx: p.first(), dy: p.last(), deixis-pin("c" + str(i), scope: <controls>, padding: 0pt))
  }
}
#place-controls()
#place(top + left, dx: 130pt, dy: 75pt, deixis-pin("joint", scope: <controls>, padding: 0pt))
#if kind == "explicit" {
  deixis-connect(from: (pin: <a>), to: (pin: <b>), connector: selected)
  place(top + left, dx: 15pt, dy: 65pt, deixis-pin(<a>, padding: 0pt))
  place(top + left, dx: 250pt, dy: 140pt, deixis-pin(<b>, padding: 0pt))
} else if kind == "inset" {
  deixis-inset-note(id: <note>, layer: layer, width: 85pt, dx: 155pt, dy: 70pt,
    connector: selected)[Source][#live.update(n => n + 1)One body.]
} else if kind == "margin" {
  deixis-margin-note(id: <note>, layer: layer, side: right, width: 85pt,
    connector: selected)[Source][#live.update(n => n + 1)One body.]
} else {
  let body() = deixis-inset-note-body(of: <note>, layer: layer, width: 85pt, dx: 155pt, dy: 90pt,
    connector: selected)[#live.update(n => n + 1)One body.]
  if form in ("backward", "backward-zero") {
    body()
    pagebreak()
    place-controls()
    if form == "backward" { v(35pt) } // Separate the source from its top-page relay.
    deixis-mark(id: <note>)[Source]
  } else {
    deixis-mark(id: <note>)[Source]
    pagebreak()
    place-controls()
    body()
  }
}
#if crossing {
  assert.eq(kind, "explicit")
  place(top + left, dx: 50pt, dy: -10pt, deixis-pin(<top>, padding: 0pt))
  place(top + left, dx: 50pt, dy: 230pt, deixis-pin(<bottom>, padding: 0pt))
  deixis-connect(from: (pin: <top>), to: (pin: <bottom>),
    connector: (route: "polyline", layer: edge, z-index: 1, crossings: "gap", stroke: red + 1pt))
}
Text. #if kind != "explicit" { link(<note>)[Body] }
#let verify() = {
  assert.eq(live.final(), if kind == "explicit" { 0 } else { 1 })
  assert.eq(head-live.final(), 1)
  assert.eq(painted.final(), if kind == "cross-page" { 2 } else { 1 })
  let routes = query(<control-curve>).map(m => m.value)
  assert.eq(routes.len(), if kind == "cross-page" { 2 } else { 1 })
  assert(routes.all(r => r.route.document.layer == edge))
  if form == "backward-zero" {
    let outgoing = routes.find(r => r.route.document.is-outgoing)
    assert.eq(outgoing.route.segments, ())
    assert.eq(outgoing.heads, (false, false))
    assert.eq(outgoing.route.document.endpoints.mark.point, outgoing.route.document.endpoints.body.point)
    assert(routes.find(r => r.route.document.is-incoming).route.segments.len() > 0)
  } else { assert(routes.all(r => r.route.segments.len() > 0)) }
  if crossing { assert.eq(routes.first().crossings.hits.len(), 1) }
  (routes: routes, destinations: if kind == "explicit" { () } else {
    let p = query(<note>).first().location().position()
    ((page: p.page, x: p.x.pt(), y: p.y.pt()),)
  })
}
