#import ("@preview/touying:" + sys.inputs.at("touying-version", default: "0.8.0")): *
#import themes.simple: simple-theme, slide
#import "../../src/lib.typ": *
#show: simple-theme.with(aspect-ratio: "16-9", config-page(
  background: deixis-page-overlay(layer: "background"), foreground: deixis-page-overlay()))
#let annotations(body) = deixis-setup-notes(page-overlays: false, body)
#let policy = sys.inputs.at("policy", default: "separate")
#let drawing(self: none) = {
  let id = "node-frame-" + str(self.subslide)
  let paint(r) = {
    [#metadata((page: r.route.document.page, length: r.route.length))<host-node-route>]
    deixis-render-connector(r)
  }
  deixis-routing(policy: policy, nodes: ((body: id),))[
    #place(top + left, dx: 30pt, dy: 100pt, deixis-pin(id + "a", padding: 0pt))
    #place(top + left, dx: 330pt, dy: 100pt, deixis-pin(id + "b", padding: 0pt))
    #deixis-connect(from: (pin: id + "a"), to: (pin: id + "b"), connector: (render: paint))
    #let obstacle = deixis-inset-note-body(id: id, connector: none, width: 50pt,
      placement: x => place(top + left, dx: 150pt, dy: 60pt, x))[
        #block(height: 80pt)[A Note Body]
      ]
    #if self.subslide == 1 { hide(obstacle) } else { obstacle }
  ]
}
#slide(setting: annotations)[
  #touying-fn-wrapper(drawing)
  #pause
]
#let verify() = {
  let routes = query(<host-node-route>).map(m => m.value).sorted(key: r => r.page)
  assert.eq(routes.map(r => r.page), (1, 2))
  assert.eq(routes.first().length, 300pt)
  if policy != "manual" { assert(routes.last().length > 300pt) }
}
