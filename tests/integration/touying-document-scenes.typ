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
    deixis-attach(scope: scope, prefix: none, pins: (("tl", (anchor: top + left)), ("br", (anchor: bottom + right))),
      rect(width: 50pt, height: 80pt, fill: luma(230))))
  if self.subslide == 1 { hide(obstacle) } else { obstacle }
  context {
    let scene = deixis-routing-scene(nodes: ((id: <a>, pin: target("a")), (id: <b>, pin: target("b")),
      (id: <obstacle>, pins: (target("tl"), target("br")))))
    let r = deixis-route(scene: scene, from: <a>, to: <b>, route: "orthogonal")
    assert.eq(r.status, "ok")
    assert.eq(r.page, self.subslide)
    if self.subslide == 1 { assert.eq(r.length, 300pt) } else { assert(r.length > 300pt) }
    [#metadata((page: r.page, length: r.length))<host-scene>]
    // Page-space geometry to the host's content-space overlay origin.
    place(top + left, dx: 30pt, dy: 100pt, deixis-render-connector(deixis-prepare-connector(r, stroke: blue + 1pt)))
  }
}
#slide(setting: annotations)[
  #touying-fn-wrapper(drawing)
  #pause
]
#context { assert.eq(query(<host-scene>).map(n => n.value.page), (1, 2)) }
