#import "../../src/lib.typ": *
#set page(width: 440pt, height: 280pt, margin: 20pt)
#show: deixis-setup-notes
#let family = sys.inputs.at("route", default: "curve")
#let painter = sys.inputs.at("painter", default: "delegate")
#let crossing = sys.inputs.at("crossing", default: "off") == "on"
#let enabled = sys.inputs.at("scene", default: "on") == "on"
#let live = state("scene-cut-heads", ())
#let head(request) = (body: [#live.update(xs => xs + (request.endpoint,))#circle(radius: 2pt)],
  trim: 2pt, bounds: (left: -2pt, right: 2pt, top: -2pt, bottom: 2pt))
#let paint(request) = {
  if enabled {
    assert.eq(request.route.status, "ok")
    assert.eq(request.route.search, none)
    assert.eq(request.route.interactions.map(e => e.behavior), ("cross", "cut"))
    assert.eq(request.cuts.len(), 2)
    assert.eq(request.route.scene-cuts.len(), 1)
    assert(request.gaps.len() >= 2)
  }
  if crossing {
    assert(request.crossings != none)
    assert(request.crossings.cuts.len() > 0)
  }
  [#metadata((route: request.route.segments, cuts: request.cuts, shaft: request.shaft))<scene-cut>]
  deixis-render-connector(request)
}
#let scene = deixis-routing-scene(nodes: (
  (page: 1, bounds: (left: 150pt, top: 0pt, right: 170pt, bottom: 280pt), behavior: "cross"),
  (page: 1, bounds: (left: 190pt, top: 0pt, right: 210pt, bottom: 280pt), behavior: "cut"),
))
#let options = (route: family, radius: if sys.inputs.at("radius", default: "fixed") == "auto" { auto } else { 6pt },
  scene: if enabled { scene } else { none }, heads: (mark: head, body: head),
  via: ((relative-to: "page", offset: (120pt, 60pt)), (relative-to: "page", offset: (270pt, 60pt))),
  cuts: (at: 80%, length: 8pt), gap-marks: "slash",
  render: if painter == "native" { none } else { paint },
  crossings: if crossing { (group: <scene-cuts>) } else { none })
#if family == "b-spline" {
  options.route = (kind: "b-spline", controls: options.via)
  options.via = none
}
#if sys.inputs.at("sections", default: "off") == "on" {
  options.segments = ((route: "curve", via: (options.via.first(),)), (route: "polyline", via: (options.via.last(),)))
  let _ = options.remove("via")
}
#deixis-connect(from: (pin: <a>), to: (pin: <b>), connector: options)
#place(top + left, dx: 20pt, dy: 120pt, deixis-pin(<a>, padding: 0pt))
#place(top + left, dx: 360pt, dy: 120pt, deixis-pin(<b>, padding: 0pt))
#if crossing {
  deixis-connect(from: (pin: <c>), to: (pin: <d>), connector: (
    route: "polyline", z-index: 1, crossings: (group: <scene-cuts>)))
  place(top + left, dx: 230pt, dy: 10pt, deixis-pin(<c>, padding: 0pt))
  place(top + left, dx: 230pt, dy: 220pt, deixis-pin(<d>, padding: 0pt))
}
#let verify() = {
  assert.eq(live.final().sorted(), ("body", "mark"))
  let records = query(<scene-cut>).map(m => m.value)
  assert.eq(records.len(), if painter == "native" { 0 } else { 1 })
  records
}
