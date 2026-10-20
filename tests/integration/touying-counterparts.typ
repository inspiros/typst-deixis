#import ("@preview/touying:" + sys.inputs.at("touying-version", default: "0.8.0")): *
#import themes.simple: simple-theme, slide
#import "../../src/lib.typ": *
#let policy = sys.inputs.at("policy", default: "native")
#show: simple-theme.with(aspect-ratio: "16-9", config-page(
  background: deixis-page-overlay(layer: "background"), foreground: deixis-page-overlay()))
#let annotations(body) = deixis-setup-notes(page-overlays: false, body)
#let marker(r) = {
  let other = (r.counterpart)()
  if other == none { return [] }
  assert.eq(other.page, if r.page == 1 { 3 } else { 1 })
  [#metadata((page: r.page, point: r.point, other: other))<host-counterpart>]
  link(other.destination, box(width: 30pt, height: 12pt)[Other])
}
#let declaration(self: none) = {
  let edge = deixis-connect(from: (pin: (name: <a>, page: 1)), to: (pin: <b>), connector: (
    route: "orthogonal", radius: 0pt, continuation: marker))
  let edge = if policy == "native" { edge } else { deixis-routing(policy: policy, edge) }
  if self.subslide == 1 { edge } else { hide(edge) }
}
#slide(setting: annotations)[
  #deixis-pin(<a>, padding: 0pt)
  #touying-fn-wrapper(declaration)
  Source
  #pause
]
#slide(setting: annotations)[
  #place(top + left, dx: 250pt, dy: 70pt, deixis-pin(<b>, padding: 0pt))
  Target
]
#context {
  let records = query(<host-counterpart>).map(m => m.value)
  assert.eq(records.map(r => r.page).sorted(), (1, 3))
  assert.eq(query(<deixis-continuation-site>).len(), 2)
  for r in records {
    let other = records.find(p => p.page == r.other.page)
    assert.eq(r.other.point, other.point)
  }
}
