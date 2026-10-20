#import "../../src/lib.typ": *
#import "../../src/routing/path.typ": _deixis-render-waypoint-path
#import "../../src/routing/geometry.typ": _deixis-sub
#set page(width: 340pt, height: 220pt, margin: 20pt)
#set text(size: 13pt)
// No setup, note declarations, pins, or page overlay are needed.
#let family = sys.inputs.at("route", default: "hobby")
#let mode = sys.inputs.at("mode", default: "ordinary")
#let backend = sys.inputs.at("backend", default: "numeric")
#let live = state("numeric-routing-heads", 0)
#let custom(request) = (body: [#live.update(n => n + 1)#circle(radius: 2pt, fill: request.fill, stroke: none)],
  trim: if mode == "consumed" { 500pt } else { 5pt },
  bounds: (left: -2pt, top: -2pt, right: 2pt, bottom: 2pt))
#let start = (30pt, 50pt)
#let end = if mode == "loop" { start } else { (240pt, 120pt) }
#let knots = ((85pt, 15pt), (160pt, 130pt))
#let controls = ((100pt, -10pt), (190pt, 110pt))
#let policy = if family == "b-spline" { (kind: family, controls: controls) } else { family }
#let route = if mode == "empty" { "none" } else { policy }
#let via = {
  if mode == "empty" { () }
  else if mode == "gap" { (knots.first(), "none", knots.last(), policy) }
  else if mode == "sections" { (knots.first(), policy, knots.last(), policy) }
  else if family == "b-spline" { () } else { knots }
}
#let geometry = deixis-route(from: (point: start, normal: right), to: (point: end, normal: left),
  route: route, via: via, radius: 5pt)
#let line-style = if mode == "disabled" { none } else { stroke(paint: blue, thickness: 1.2pt, dash: "dashed", cap: "round") }
#let head-style = (mark: "bar", body: custom)
#let cut = (at: 55%, length: 0.7em)
#let paint(request) = {
  assert.eq(request.frame, "source-local-x-right-y-down")
  assert.eq(request.route.segments, geometry.segments)
  assert.eq(request.route.bounds, geometry.bounds)
  assert.eq(request.route.length, geometry.length)
  assert.eq(request.manual-shaft, request.shaft)
  assert.eq(request.crossings, none)
  if mode == "empty" { assert.eq(request.heads, (mark: none, body: none)) }
  if mode == "consumed" { assert.eq(request.shaft, ()) }
  if mode == "disabled" { assert.eq(request.stroke, none) }
  [#metadata((length: request.route.length.pt(), fragments: request.shaft.len()))<numeric-route>]
  deixis-render-connector(request)
}
#context {
  if backend == "numeric" {
    let request = deixis-prepare-connector(geometry, stroke: line-style, heads: head-style, cuts: cut, gap-marks: "slash")
    assert.eq(request.route.document, none)
    assert.eq(request.route + (document: none), geometry + (document: none))
    place(top + left, dx: geometry.origin.first(), dy: geometry.origin.last(), paint(request))
  } else {
    let local(value) = if type(value) == array { _deixis-sub(value, start) }
      else if type(value) == dictionary and "controls" in value {
        value + (controls: value.controls.map(p => _deixis-sub(p, start)))
      } else { value }
    _deixis-render-waypoint-path(..start, ..end, link-type: local(route), waypoints: via.map(local),
      fixed-waypoints: via.filter(v => type(v) == array).map(local),
      source-dir: "horizontal", target-dir: "horizontal", source-normal: (1, 0), target-normal: (-1, 0),
      link-radius: 5pt, link-stroke: line-style, link-heads: head-style,
      link-cuts: cut, link-gap-marks: "slash", link-render: paint).join()
  }
}
#let verify() = {
  assert.eq(live.final(), if mode == "empty" { 0 } else { 1 })
  let routes = query(<numeric-route>)
  assert.eq(routes.len(), 1)
  routes.first().value
}
