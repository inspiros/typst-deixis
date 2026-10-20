#import "../../src/lib.typ": *
#set page(width: 460pt, height: 280pt, margin: (x: 95pt, y: 35pt))
#show: deixis-setup-notes
#let kind = sys.inputs.at("kind", default: "explicit")
#let layer = sys.inputs.at("layer", default: "foreground")
#let edge-layer = sys.inputs.at("edge-layer", default: "foreground")
#let mode = sys.inputs.at("mode", default: "gap")
#let reversed = sys.inputs.at("declarations", default: "normal") == "reverse"
#let enabled = sys.inputs.at("crossings", default: "on") == "on" and mode != "disabled"
#let inherited = sys.inputs.at("inherit", default: "off") == "on"
#let route-kind = sys.inputs.at("route", default: "polyline")
#let restore = sys.inputs.at("restore", default: "off") == "on"
#let live = state("crossing-live", ())
#let painted = state("crossing-painted", ())
#let paint(name, request) = {
  [#painted.update(xs => xs + (name,))#metadata((name: name,
    plan: request.crossings, manual: request.manual-shaft, final: request.shaft,
    original: request.route.segments, page: request.route.document.page))<automatic-route>]
  deixis-render-connector(request + if restore { (shaft: request.manual-shaft) } else { (:) })
}
#let lower-options = (route: route-kind, radius: if route-kind == "orthogonal" { 12pt } else { 0pt },
  stroke: blue + 1pt, heads: (mark: "circle", body: "triangle"),
  layer: edge-layer, z-index: if mode == "priority" { 2 } else { 0 },
  crossings: if enabled { (group: <diagram>, gap: 10pt) } else { none }, render: paint.with("lower"),
  cuts: if mode == "manual-lower" { (from: 110pt, to: 130pt) } else { none })
#let upper-options = (route: "polyline", stroke: if mode == "zero" { none } else { red + 1pt },
  heads: "triangle", layer: if mode == "layers" { "background" } else { edge-layer },
  z-index: if mode == "tie" { 0 } else { 1 },
  crossings: if not enabled or mode == "unselected" { none } else {
    (group: if mode == "groups" { "other" } else { "diagram" }, gap: 10pt)
  }, render: paint.with("upper"),
  cuts: if mode == "manual" { (at: 50%, length: 40pt) } else { none })
#if inherited { deixis-set(connector: lower-options) }
#let lower() = {
  let options = if inherited { auto } else { lower-options }
  if kind == "inset" {
    deixis-inset-note(id: <note>, layer: layer, dx: 155pt, dy: 70pt, width: 80pt,
      connector: options)[Source][#live.update(xs=>xs+("body",))One body.]
  } else if kind == "margin" {
    deixis-margin-note(id: <note>, layer: layer, side: right, width: 80pt,
      connector: options)[Source][#live.update(xs=>xs+("body",))One body.]
  } else {
    deixis-connect(from: (pin: "left"), to: (pin: "right"), connector: options)
  }
}
#let upper() = deixis-connect(from: (pin: "top"), to: (pin: "bottom"), connector: upper-options)
#place(top + left, dx: 10pt, dy: 90pt, deixis-pin("left", padding: 0pt))
#place(top + left, dx: 330pt, dy: if route-kind == "polyline" { 90pt } else { 140pt }, deixis-pin("right", padding: 0pt))
#place(top + left, dx: if mode == "clearance" { 20pt } else { 130pt }, dy: -25pt, deixis-pin("top", padding: 0pt))
#place(top + left, dx: if mode == "clearance" { 20pt } else { 130pt }, dy: 220pt, deixis-pin("bottom", padding: 0pt))
#{
  if reversed { if mode == "hidden" { hide(upper()) } else { upper() }; lower() }
  else { lower(); if mode == "hidden" { hide(upper()) } else { upper() } }
}
Text.
#if kind != "explicit" { link(<note>)[Body] }
#let verify() = {
  let routes = query(<automatic-route>).map(m => m.value)
  assert.eq(live.final(), if kind == "explicit" { () } else { ("body",) })
  assert.eq(painted.final().sorted(), if mode == "hidden" { ("lower",) } else { ("lower", "upper") })
  assert.eq(routes.len(), if mode == "hidden" { 1 } else { 2 })
  let expected = enabled and mode in ("gap", "tie", "priority")
  let hits = routes.filter(r => r.plan != none).map(r => r.plan.hits.len()).fold(0, (a, b) => a + b)
  assert.eq(hits, if expected { 1 } else { 0 })
  if expected {
    let cut = routes.find(r => r.plan != none and r.plan.cuts.len() > 0)
    let lower-wins = mode == "priority" or (mode == "tie" and reversed and kind == "explicit")
    assert.eq(cut.name, if lower-wins { "upper" } else { "lower" })
  }
  (routes: routes, destinations: if kind == "explicit" { () } else {
    let pos = query(<note>).first().location().position()
    ((page: pos.page, x: pos.x.pt(), y: pos.y.pt()),)
  })
}
