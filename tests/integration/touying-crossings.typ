#import ("@preview/touying:" + sys.inputs.at("touying-version", default: "0.8.0")): *
#import themes.simple: simple-theme, slide
#import "../../src/lib.typ": *
#show: simple-theme.with(aspect-ratio: "16-9", config-page(
  background: deixis-page-overlay(layer: "background"), foreground: deixis-page-overlay(),
))
#let annotations(body) = deixis-setup-notes(page-overlays: false, body)
#let route-kind = sys.inputs.at("route", default: "polyline")
#if sys.inputs.at("route-settings", default: "off") == "on" {
  route-kind = (kind: route-kind, tension: 2)
}
#let paint(frame, name, request) = {
  [#metadata((frame: frame, name: name, page: request.route.document.page,
    plan: request.crossings))<touying-crossing>]
  deixis-render-connector(request)
}
#let drawing(name, self: none) = {
  let frame = self.subslide
  let scope = "frame-" + str(frame)
  if name == "lower" {
    let pins = (("left", 20pt, 100pt), ("right", 350pt, 100pt),
      ("top", 180pt, 30pt), ("bottom", 180pt, 170pt))
    if route-kind == "b-spline" {
      pins += (("lower-c1", 90pt, 70pt), ("lower-c2", 260pt, 130pt),
        ("upper-c1", 160pt, 60pt), ("upper-c2", 200pt, 140pt))
    }
    for (pin, x, y) in pins {
      place(top + left, dx: x, dy: y, deixis-pin(pin, scope: scope, padding: 0pt))
    }
  }
  let a = if name == "lower" { "left" } else { "top" }
  let b = if name == "lower" { "right" } else { "bottom" }
  let route = if route-kind == "b-spline" { (kind: route-kind, controls: (
    (pin: (name: name + "-c1", scope: scope)), (pin: (name: name + "-c2", scope: scope)),
  )) } else { route-kind }
  let edge = deixis-connect(from: (pin: (name: a, scope: scope)), to: (pin: (name: b, scope: scope)),
    connector: (route: route, crossings: (group: scope), z-index: if name == "lower" { 0 } else { 1 },
      stroke: if name == "lower" { blue + 1pt } else { red + 1pt }, render: paint.with(frame, name)))
  // Touying callbacks own their generated content's visibility.
  if name == "upper" and frame == 1 { hide(edge) } else { edge }
}
#slide(setting: annotations)[
  #touying-fn-wrapper(drawing.with("lower"))
  #pause
  #touying-fn-wrapper(drawing.with("upper"))
]
#let verify() = {
  let routes = query(<touying-crossing>).map(m=>m.value)
  assert.eq(routes.len(), 3)
  for frame in (1, 2) {
    let lower = routes.find(r=>r.frame == frame and r.name == "lower")
    assert.eq(lower.plan.hits.len(), if frame == 1 { 0 } else { 1 })
    assert.eq(lower.page, frame)
  }
  assert.eq(query(<deixis-crossing-route>).len(), 3)
  routes
}
