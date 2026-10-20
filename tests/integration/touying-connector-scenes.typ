#import ("@preview/touying:" + sys.inputs.at("touying-version", default: "0.8.0")): *
#import themes.simple: simple-theme, slide
#import "../../src/lib.typ": *
#show: simple-theme.with(aspect-ratio: "16-9", config-page(
  background: deixis-page-overlay(layer: "background"), foreground: deixis-page-overlay()))
#let annotations(body) = deixis-setup-notes(page-overlays: false, body)
#let drawing(self: none) = {
  let scope = "frame-" + str(self.subslide)
  let target(name) = (name: name, scope: scope)
  place(top + left, dx: 30pt, dy: 100pt, deixis-pin("a", scope: scope, padding: 0pt))
  place(top + left, dx: 330pt, dy: 100pt, deixis-pin("b", scope: scope, padding: 0pt))
  let obstacle = place(top + left, dx: 150pt, dy: 60pt,
    deixis-attach(scope: scope, prefix: none, pins: (tl: (anchor: top + left), br: (anchor: bottom + right)),
      rect(width: 50pt, height: 80pt, fill: luma(230))))
  if self.subslide == 1 { hide(obstacle) } else { obstacle }
  let scene(doc) = {
    assert.eq(doc.page, self.subslide)
    deixis-routing-scene(nodes: ((pins: (target("tl"), target("br"))),))
  }
  let paint(request) = {
    if self.subslide == 1 { assert.eq(request.route.length, 300pt) } else { assert(request.route.length > 300pt) }
    [#metadata(request.route.page)<host-scene-connector>]
    deixis-render-connector(request)
  }
  deixis-connect(from: (pin: target("a")), to: (pin: target("b")), connector: (
    route: "orthogonal", radius: 0pt, scene: scene, render: paint, heads: "triangle"))
}
#slide(setting: annotations)[
  #touying-fn-wrapper(drawing)
  #pause
]
#context { assert.eq(query(<host-scene-connector>).map(m => m.value), (1, 2)) }
