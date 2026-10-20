#import "@preview/deixis:0.2.0": *
#set page(width: 320pt, height: 220pt, margin: 20pt)
#show: deixis-setup-notes
#show: deixis-routing.with(policy: "manual")
#let painted = state("manual-paint", 0)
#let paint(r) = {
  assert.eq(r.route.at("search", default: none), none)
  assert.eq(r.route.at("interactions", default: none), none)
  [#painted.update(n => n + 1)#deixis-render-connector(r)]
}
#for kind in ("curve", "hobby", "b-spline", "orthogonal") {
  deixis-connect(from: (node: <a>), to: (node: <b>), connector: (
    route: if kind == "b-spline" { (kind: kind, controls: ((relative-to: "page", offset: (140pt, 50pt)),)) } else { kind },
    radius: if kind == "orthogonal" { 3pt } else { 0pt }, render: paint,
    via: if kind == "b-spline" { none } else { ((relative-to: "page", offset: (140pt, 50pt)),) }))
}
// An explicit scene remains the caller's deliberate opt-in to search. Manual
// only disables automatic discovery/planning of the registered attachments.
#let scene(d) = deixis-routing-scene(nodes: (
  (page: 1, bounds: (left: 100pt, top: 70pt, right: 130pt, bottom: 110pt)),))
#let explicit(r) = {
  assert(r.route.search != none)
  [#metadata(true)<manual-explicit-scene>]
  deixis-render-connector(r)
}
#deixis-connect(from: (node: <a>), to: (node: <b>), connector: (scene: scene, render: explicit))
#place(top + left, dx: 10pt, dy: 60pt, deixis-attach(id: <a>, rect(width: 30pt, height: 20pt)))
#place(top + left, dx: 230pt, dy: 60pt, deixis-attach(id: <b>, rect(width: 30pt, height: 20pt)))
// These deliberately impossible automatic obstacles must not affect manual
// paths; cuts/cross behavior is likewise automatic only under search policies.
#place(top + left, deixis-attach(behavior: "avoid", rect(width: 280pt, height: 180pt)))
#place(top + left, deixis-attach(behavior: "cut", rect(width: 280pt, height: 180pt)))
#context {
  assert.eq(painted.final(), 4)
  assert.eq(query(<manual-explicit-scene>).len(), 1)
  assert.eq(query(<deixis-routing-plan>).len(), 0)
}
