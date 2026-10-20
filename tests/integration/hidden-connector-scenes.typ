#import "../../src/lib.typ": *
#set page(width: 400pt, height: 240pt, margin: 20pt)
#show: deixis-setup-notes
#let mode = sys.inputs.at("mode", default: "obstacle")
#let inactive = mode != "obstacle"
#let scene(doc) = {
  assert(not inactive, message: "Inactive edge evaluated its scene callback")
  let s = deixis-routing-scene(nodes: ((pins: (<tl>, <br>)),))
  assert(s.nodes.first().hidden)
  s
}
#let paint(request) = {
  assert.eq(request.route.length, 300pt)
  assert.eq(request.route.search, none)
  [#metadata(request.route.page)<hidden-scene-edge>]
  deixis-render-connector(request)
}
#let edge = deixis-connect(from: (pin: <a>), to: (pin: <b>), connector: (
  route: if mode == "disabled" { none } else { "orthogonal" }, radius: 0pt, scene: scene, render: paint))
#if mode == "declaration" { hide(edge) } else { edge }
#let source = place(top + left, dx: 20pt, dy: 80pt, deixis-pin(<a>, padding: 0pt))
#let target = place(top + left, dx: 320pt, dy: 80pt, deixis-pin(<b>, padding: 0pt))
#if mode == "source" { hide(source) } else { source }
#if mode == "target" { hide(target) } else { target }
#hide(place(top + left, dx: 130pt, dy: 40pt, deixis-attach(prefix: none,
  pins: (tl: (anchor: top + left), br: (anchor: bottom + right)), rect(width: 60pt, height: 90pt))))
#let verify() = {
  assert.eq(query(<hidden-scene-edge>).len(), if inactive { 0 } else { 1 })
  assert.eq(query(<deixis-scene-route>).len(), if inactive { 0 } else { 1 })
}
