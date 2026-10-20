#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#import "../../src/routing/geometry.typ": _deixis-distance, _deixis-unit
#set page(width: 350pt, height: 180pt, margin: 25pt)
#show: deixis-setup-notes
#let kind = sys.inputs.at("route", default: "curve")
#let mode = sys.inputs.at("mode", default: "return")
#let layer = sys.inputs.at("layer", default: "foreground")
#let bodies = state("curve-edge-heads", 0)
#let paints = state("curve-edge-paints", 0)
#let head(request) = (
  body: [#bodies.update(n => n + 1)#curve(fill: request.fill, stroke: none,
    curve.move((0pt, 0pt)), curve.line((-5pt, -3pt)), curve.line((-5pt, 3pt)), curve.close())],
  trim: 5pt, bounds: (left: -5pt, right: 0pt, top: -3pt, bottom: 3pt))
#let paint(request) = {
  [#paints.update(n => n + 1)#metadata((route: request.route, shaft: request.shaft))<curve-endpoints>]
  deixis-render-connector(request)
}
#deixis-connect(from: (pin: <a>), to: (pin: <b>), connector: (route: kind, layer: layer,
  stroke: blue + 1pt, heads: head, render: paint,
  ports: if mode == "forced" { (mark: left, body: left) } else { auto },
  via: if mode == "return" { ((pin: <b>), (pin: <bend>)) }
    else if mode == "duplicate" { ((pin: <bend>), (pin: <bend>), (pin: <b>)) } else { none }))
#place(top + left, dx: 40pt, dy: 35pt, deixis-pin(<a>, padding: 0pt))
#place(top + left, dx: 250pt, dy: 90pt, deixis-pin(<b>, padding: 0pt))
#place(top + left, dx: 120pt, dy: 65pt, deixis-pin(<bend>, padding: 0pt))
#let verify() = {
  assert.eq(deixis-system.final().registry.value.notes.len(), 0)
  assert.eq(bodies.final(), 1)
  assert.eq(paints.final(), 1)
  let items = query(<curve-endpoints>)
  assert.eq(items.len(), 1)
  let r = items.first().value.route
  assert(r.segments.all(s => s.kind == "cubic"))
  assert.eq((r.start, r.end), ((0pt, 0pt), (210pt, 55pt)))
  if mode == "return" {
    assert.eq(r.segments.filter(s => s.end == r.end).len(), 2)
  } else if mode == "duplicate" {
    assert.eq(r.segments.len(), 2)
    assert.eq(r.segments.filter(s => s.end == r.end).len(), 1)
  } else if mode == "forced" {
    assert.eq(r.start-tangent, (-1.0, 0.0))
    assert.eq(r.end-tangent, (1.0, 0.0))
  } else {
    let direction = _deixis-unit(r.end).map(v => v * 1pt)
    assert(_deixis-distance(r.start-tangent.map(v => v * 1pt), direction) < 0.000001pt)
    assert(_deixis-distance(r.end-tangent.map(v => v * 1pt), direction) < 0.000001pt)
  }
  r
}
