#import ("@preview/touying:" + sys.inputs.at("touying-version", default: "0.8.0")): *
#import themes.simple: simple-theme, slide
#import "../../src/lib.typ": *
#let policy = sys.inputs.at("policy", default: "separate")
#let kind = sys.inputs.at("kind", default: "inset")
#show: simple-theme.with(aspect-ratio: "16-9", config-page(margin: (left: 50pt, right: 100pt, y: 30pt),
  background: deixis-page-overlay(layer: "background"), foreground: deixis-page-overlay()))
#let annotations(body) = deixis-setup-notes(page-overlays: false, body)
#let drawing(self: none) = deixis-routing(policy: policy, {
  let paint(name, r) = {
    assert.eq(r.route.at("search", default: none) != none, policy != "manual")
    [#metadata((name: name, page: r.route.document.page))<host-note-painted>]
    deixis-render-connector(r)
  }
  deixis-connect(from: (node: <a>), to: (node: <b>), connector: (render: paint.with("explicit")))
  place(top + left, dx: 30pt, dy: 100pt, deixis-attach(id: <a>, rect(width: 40pt, height: 20pt)))
  place(top + left, dx: 330pt, dy: 100pt, deixis-attach(id: <b>, rect(width: 40pt, height: 20pt)))
  let note = {
    let id = "note-" + str(self.subslide)
    let options = (route: "orthogonal", radius: 0pt, render: paint.with("shorthand"))
    place(top + left, dx: 30pt, dy: 200pt, deixis-mark(id: id)[Source])
    if kind == "margin" {
      deixis-margin-note-body(of: id, width: 65pt, connector: options)[Body]
    } else {
      deixis-inset-note-body(of: id, width: 65pt, layer: "foreground", connector: options,
        placement: x => place(top + left, dx: 300pt, dy: 200pt, x))[Body]
    }
  }
  if self.subslide == 1 { hide(note) } else { note }
})
#slide(setting: annotations)[
  #touying-fn-wrapper(drawing)
  #pause
]
#context {
  let paints = query(<host-note-painted>).map(m => m.value)
  assert.eq(paints.filter(p => p.name == "explicit").map(p => p.page).sorted(), (1, 2))
  assert.eq(paints.filter(p => p.name == "shorthand").map(p => p.page), (2,))
  let plans = query(<deixis-routing-plan>).map(m => m.value).sorted(key: p => p.page)
  assert.eq(plans.len(), if policy == "manual" { 0 } else { 2 })
  if policy != "manual" { assert.eq(plans.map(p => p.members.len()), (1, 2)) }
}
