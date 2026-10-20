#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-setup-state, deixis-system
// Configuration can precede setup. Numeric geometry/painting has no registry
// or page-compositor dependency, including scenes built from resolved bounds.
#deixis-set(stroke: blue + 1pt)
#let scene = deixis-routing-scene(nodes: ((bounds: (left: 30pt, right: 50pt, top: 10pt, bottom: 30pt)),))
#let route = deixis-route(scene: scene, from: (0pt, 20pt), to: (100pt, 20pt), route: "orthogonal")
#assert.eq(route.status, "ok")
#context {
  assert(not deixis-setup-state.final())
  assert.eq(deixis-system.final().registry.value.notes.len(), 0)
  let request = deixis-prepare-connector(route, stroke: blue + 1pt, heads: "triangle")
  place(top + left, dx: 20pt, dy: 30pt, deixis-render-connector(request))
}
