#import ("@preview/touying:" + sys.inputs.at("touying-version", default: "0.8.0")): *
#import themes.simple: simple-theme, slide
#import "../../src/lib.typ": *
#show: simple-theme.with(aspect-ratio: "16-9", config-page(
  background: deixis-page-overlay(layer: "background"), foreground: deixis-page-overlay()))
#let annotations(body) = deixis-setup-notes(page-overlays: false, body)
#let drawing(self: none) = deixis-routing({
  // Same public IDs in both subslides; physical page owns each live instance.
  deixis-connect(from: (node: <a>), to: (node: <b>), connector: (heads: "triangle"))
  place(top + left, dx: 30pt, dy: 100pt, deixis-attach(id: <a>, rect(width: 40pt, height: 20pt)))
  place(top + left, dx: 330pt, dy: 100pt, deixis-attach(id: <b>, rect(width: 40pt, height: 20pt)))
  let obstacle = place(top + left, dx: 150pt, dy: 60pt,
    deixis-attach(behavior: "avoid", rect(width: 50pt, height: 100pt, fill: luma(230))))
  if self.subslide == 1 { hide(obstacle) } else { obstacle }
})
#slide(setting: annotations)[
  #touying-fn-wrapper(drawing)
  #pause
]
#context {
  let plans = query(<deixis-routing-plan>).map(m => m.value).sorted(key: p => p.page)
  assert.eq(plans.map(p => p.page), (1, 2))
  assert.eq(plans.first().plan.routes.first().length, 260pt)
  assert(plans.last().plan.routes.first().length > 260pt)
}
