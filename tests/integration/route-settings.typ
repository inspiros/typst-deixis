#import "../../src/lib.typ": *
#set page(width: 470pt, height: 300pt, margin: (x: 95pt, y: 35pt))
#show: deixis-setup-notes
#let kind = sys.inputs.at("kind", default: "explicit")
#let layer = sys.inputs.at("layer", default: "foreground")
#let edge = sys.inputs.at("edge", default: "foreground")
#let family = sys.inputs.at("family", default: "curve")
#let form = sys.inputs.at("form", default: "local")
#let tension = float(sys.inputs.at("tension", default: "2"))
#let curl = if sys.inputs.at("curl", default: "1") == "mixed" { (mark: 0, body: 2) } else { float(sys.inputs.at("curl", default: "1")) }
#let spec = {
  if family == "curve" { (kind: "curve", tension: tension) }
  else if family == "hobby" { (kind: "hobby", tension: tension, curl: curl) }
  else { (kind: "catmull-rom", parameterization: family, tension: tension) }
}
#if sys.inputs.at("syntax", default: "record") == "string" {
  assert.eq(tension, 1)
  assert(family != "hobby" or curl == 1)
  spec = if family in ("curve", "hobby") { family } else if family == "uniform" { "ucr" } else { "ccr" }
}
#let live = state("route-settings-live", 0)
#let painted = state("route-settings-painted", 0)
#let head-live = state("route-settings-head", 0)
#let head(request) = (
  body: [#head-live.update(n => n + 1)#circle(radius: 2pt, fill: request.fill, stroke: none)],
  trim: 3pt, bounds: (left: -2pt, right: 2pt, top: -2pt, bottom: 2pt))
#let paint(request) = {
  let numeric = request.route.segments.map(s => (start: s.start.map(v => v.pt()), end: s.end.map(v => v.pt()),
    c1: s.c1.map(v => v.pt()), c2: s.c2.map(v => v.pt())))
  [#painted.update(n => n + 1)#metadata((route: request.route, shaft: request.shaft, numeric: numeric,
    heads: (request.heads.mark != none, request.heads.body != none), layer: request.route.document.layer))<route-settings>]
  deixis-render-connector(request)
}
#let via = ((relative-to: "mark", offset: (35pt, 25pt)),
  (relative-to: "body", offset: (-40pt, -20pt)))
#let options = (route: spec, via: via, layer: edge, heads: (mark: "bar", body: head),
  stroke: blue + 0.8pt, render: paint, cuts: (at: 55%, length: 8pt), gap-marks: "slash")
#if kind == "cross-page" { options.via += ("split",) }
#if form in ("mixed", "via", "equal", "equal-via") {
  let first = (route: spec, via: (via.first(),))
  let last = (route: if form in ("equal", "equal-via") { spec } else if family == "hobby" { "hobby" }
    else { (kind: "catmull-rom", parameterization: "uniform", tension: 0.75) }, via: (via.last(),))
  let _ = options.remove("via")
  if form in ("mixed", "equal") { options.segments = (first, last) }
  else { options.via = (first.route,) + first.via + (last.route,) + last.via }
}
#if form == "settings" { deixis-set(connector: options) }
#if form == "flat" {
  // Explicit edges have their own straight default; note link defaults are
  // intentionally separate. Select the connection type for this adapter.
  if kind == "explicit" { deixis-set(connector: (connection: options)) }
  else { deixis-set(connector: (route: spec)) }
}
#if form == "replace" {
  deixis-set(connector: options + (route: (kind: "catmull-rom", parameterization: "uniform", tension: 0.5)))
  deixis-set(connector: (route: spec))
}
#let selected = if form in ("settings", "replace") or (form == "flat" and kind == "explicit") { auto } else if form == "flat" {
  let value = options
  let _ = value.remove("route")
  value
} else { options }
#if kind == "explicit" {
  deixis-connect(from: (pin: <a>), to: (pin: <b>), connector: selected)
  place(top + left, dx: 15pt, dy: 65pt, deixis-pin(<a>, padding: 0pt))
  place(top + left, dx: 250pt, dy: 140pt, deixis-pin(<b>, padding: 0pt))
} else if kind == "inset" {
  deixis-inset-note(id: <note>, layer: layer, width: 85pt, dx: 155pt, dy: 70pt,
    connector: selected)[Source][#live.update(n => n + 1)One body.]
} else if kind == "margin" {
  // Auto waypoints deliberately exercise the adapter's native lane policy.
  if form == "auto" { selected.via = auto }
  deixis-margin-note(id: <note>, layer: layer, side: right, width: 85pt,
    connector: selected)[Source][#live.update(n => n + 1)One body.]
} else {
  let body() = deixis-inset-note-body(of: <note>, layer: layer, width: 85pt, dx: 155pt, dy: 90pt,
    connector: selected)[#live.update(n => n + 1)One body.]
  if form == "backward" {
    body()
    pagebreak()
    v(35pt)
    deixis-mark(id: <note>)[Source]
  } else {
    deixis-mark(id: <note>)[Source]
    pagebreak()
    body()
  }
}
Text. #if kind != "explicit" { link(<note>)[Body] }
#let verify() = {
  assert.eq(live.final(), if kind == "explicit" { 0 } else { 1 })
  assert.eq(painted.final(), if kind == "cross-page" { 2 } else { 1 })
  assert.eq(head-live.final(), 1)
  let routes = query(<route-settings>).map(m => m.value)
  assert.eq(routes.len(), if kind == "cross-page" { 2 } else { 1 })
  assert(routes.all(r => r.layer == edge and r.route.segments.all(s => s.kind == "cubic")))
  (routes: routes, destinations: if kind == "explicit" { () } else {
    let p = query(<note>).first().location().position()
    ((page: p.page, x: p.x.pt(), y: p.y.pt()),)
  })
}
