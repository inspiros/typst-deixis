#import "../../src/lib.typ": *
#set page(width: 460pt, height: 300pt, margin: (left: 30pt, right: 100pt, y: 30pt))
#set text(size: 12pt)
#show: deixis-setup-notes
#let layer = sys.inputs.at("layer", default: "foreground")
#let kind = sys.inputs.at("kind", default: "inset")
#let timing = sys.inputs.at("timing", default: "forward")
#let live = state("scene-bodies", 0)
#let draw() = context {
  let scene = deixis-routing-scene(nodes: (
    (id: <source>, pin: <start>),
    (id: <target>, body: <detail>, point: if kind in ("footnote", "endnote") { "start" } else { none }),
    (id: <obstacle>, pins: (<tl>, <br>), padding: (x: 1pt)),
    (id: <original>, mark: <detail>, behavior: "ignore"),
    (id: <inline>, mark: <detail>, occurrence: <again>, behavior: "ignore"),
    (id: <phantom>, mark: <detail>, occurrence: <point>, behavior: "ignore"),
    (id: <region>, mark: <detail>, occurrence: <area>, behavior: "cross"),
    (id: <body-point>, body: <detail>, point: "start"),
    // A literal caller-plane node stays independent of document page geometry.
    (id: <literal>, bounds: (left: 0pt, top: 0pt, right: 1pt, bottom: 1pt), page: none),
  ))
  let node(id) = scene.nodes.at(scene.ids.at(id))
  assert.eq(node("source").behavior, "ignore")
  assert.eq(node("body-point").behavior, "ignore")
  assert.eq(node("target").page, 1)
  assert.eq(node("obstacle").bounds.right - node("obstacle").bounds.left, 42pt)
  assert.eq(scene.planes.find(p => p.page == 1).bounds.right, 460)
  let route = deixis-route(scene: scene, from: <source>, to: <target>, route: "orthogonal")
  assert.eq(route.status, "ok")
  assert.eq(route.page, 1)
  [#metadata((origin: route.origin, end: route.end, segments: route.segments,
    nodes: scene.nodes.map(n => (id: n.id, bounds: n.bounds, page: n.page))))<document-scene>]
  place(top + left, dx: route.origin.first() - 30pt, dy: route.origin.last() - 30pt,
    deixis-render-connector(deixis-prepare-connector(route, stroke: blue + 1pt, heads: "triangle")))
}
#if timing == "forward" { draw() }
#deixis-mark(id: <detail>)[Original]
#let body = [#live.update(n => n + 1)Accepted Body.]
#if kind == "inset" {
  deixis-inset-note-body(of: <detail>, connector: none, layer: layer, width: 70pt,
    placement: body => place(top + left, dx: 280pt, dy: 50pt, body), body)
} else if kind == "margin" {
  deixis-margin-note-body(of: <detail>, connector: none, layer: layer, width: 70pt, side: right, body)
} else if kind == "inline" {
  deixis-inline-note-body(of: <detail>, breakable: false, inline: true, body)
} else if kind == "footnote" { deixis-footnote-body(of: <detail>, layer: layer, body) } else { deixis-endnote-body(of: <detail>, body) }
#deixis-mark(of: <detail>, occurrence: <again>)[Another Passage]
#deixis-mark(of: <detail>, occurrence: <point>, mark-type: "phantom")
#deixis-mark(of: <detail>, occurrence: <area>, mark-type: "region")[Region Passage]
#place(top + left, dx: 20pt, dy: 130pt, deixis-pin(<start>, padding: 20pt))
#place(top + left, dx: 130pt, dy: 75pt, deixis-attach(prefix: none,
  pins: ((<tl>, (anchor: top + left)), (<br>, (anchor: bottom + right))),
  rect(width: 40pt, height: 70pt)))
#if kind == "endnote" { deixis-print-endnotes() }
#if timing == "backward" { draw() }
#context { assert.eq(live.final(), 1) }
// Route evidence is inspected outside layout by the runner: an additional live
// observer would consume another native pass after immediate margin frames.
