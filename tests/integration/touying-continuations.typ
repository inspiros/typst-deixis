#import ("@preview/touying:" + sys.inputs.at("touying-version", default: "0.8.0")): *
#import themes.simple: simple-theme, slide
#import "../../src/lib.typ": *
#show: simple-theme.with(aspect-ratio: "16-9", config-page(
  background: deixis-page-overlay(layer: "background"), foreground: deixis-page-overlay()))
#let annotations(body) = deixis-setup-notes(page-overlays: false, body)
#let scene(doc) = {
  let p = doc.continuation.point
  deixis-routing-scene(nodes: ((page: doc.page, bounds: (left: p.first() - 10pt, right: p.first() + 10pt,
    top: p.last() - 10pt, bottom: p.last() + 10pt)),))
}
#let marker(request) = {
  assert(request.allocation.shifted)
  assert.eq(request.peer-page, if request.page == 1 { 3 } else { 1 })
  [#metadata(request.page)<host-continuation>]
}
#slide(setting: annotations)[
  #deixis-pin(<a>, padding: 0pt)
  #deixis-connect(from: (pin: <a>), to: (pin: <b>), connector: (
    route: "orthogonal", radius: 0pt, scene: scene, continuation: marker, heads: "triangle"))
  Source
]
#slide(setting: annotations)[Intervening Slide]
#slide(setting: annotations)[
  #place(top + left, dx: 250pt, dy: 70pt, deixis-pin(<b>, padding: 0pt))
  Target
]
#context { assert.eq(query(<host-continuation>).map(m => m.value), (1, 3)) }
