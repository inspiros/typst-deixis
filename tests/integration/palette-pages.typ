#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#set page(width: 440pt, height: 260pt, margin: 30pt)
#show: deixis-setup-notes
#let policy = sys.inputs.at("policy", default: "native")
#let layer = sys.inputs.at("layer", default: "foreground")
#show: body => if policy == "native" { body } else { deixis-routing(policy: policy, body) }
#let live = state("page-palette-live", 0)
#let paint(r) = {
 assert.eq(r.route.document.accent, blue)
 assert.eq(r.stroke.paint, blue)
 assert(r.route.document.page in (1,3))
 [#metadata(r.route.document.page)<page-palette-edge>]
 deixis-render-connector(r)
}
#deixis-set(palette: (orange,))
#deixis-inset-note-body(of: <future>, layer: layer, width: 90pt,
 placement: body => place(top + left, dx: 200pt, dy: 100pt, body),
 connector: (route: "orthogonal", radius: 0pt, render: paint,
  continuation: (shape: "portal", link: "counterpart")))[#live.update(n=>n+1)Forward Body]
First Page
#pagebreak()
Middle Page
#pagebreak()
#set page(width: 380pt, height: 290pt)
#deixis-set(palette: (blue, teal))
#deixis-mark(id: <future>)[Future Source]
#deixis-mark(id: <next>)[Next Source]
#let verify() = {
 let registry = deixis-system.final()
 assert.eq(live.final(), 1)
 assert.eq(registry.registry.value.notes.at("id-future").accent, blue)
 assert.eq(registry.registry.value.notes.at("id-next").accent, teal)
 assert.eq(query(<deixis-inset-note>).first().value.accent, blue)
 assert.eq(query(<page-palette-edge>).map(m=>m.value).sorted(), (1,3))
 assert.eq(query(<deixis-continuation-site>).len(), 2)
 true
}
