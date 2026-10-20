#import "../../src/lib.typ": *
#let mode = sys.inputs.at("mode", default: "behavior")
#let bounds = (left: 20pt, top: 20pt, right: 40pt, bottom: 40pt)
#let options = {
  let o = (nodes: ((id: <a>, bounds: bounds),))
  if mode == "nodes-type" { o.nodes = (:) }
  else if mode == "nodes-count" { o.nodes = o.nodes*129 }
  else if mode == "node-type" { o.nodes = (2,) }
  else if mode == "node-key" { o.nodes = ((bounds: bounds, bogus: true),) }
  else if mode == "node-missing" { o.nodes = ((id: <a>),) }
  else if mode == "behavior" { o.nodes = ((bounds: bounds, behavior: "jump"),) }
  else if mode == "id" { o.nodes = ((bounds: bounds, id: ""),) }
  else if mode == "duplicate" { o.nodes += ((id: "a", bounds: bounds),) }
  else if mode == "node-page" { o.nodes = ((bounds: bounds, page: 0),) }
  else if mode == "bounds-type" { o.bounds = () }
  else if mode == "bounds-key" { o.bounds = bounds + (x: 0pt) }
  else if mode == "bounds-reverse" { o.bounds = bounds + (right: 10pt) }
  else if mode == "bounds-font" { o.bounds = bounds + (right: 1em) }
  else if mode == "bounds-inf" { o.bounds = bounds + (right: calc.inf*1pt) }
  else if mode == "clearance" { o.clearance = -1pt }
  else if mode == "escape" { o.escape = 0pt }
  else if mode == "cost" { o.bend-cost = 1em }
  else if mode == "limit" { o.max-expansions = true }
  else if mode == "pages-type" { o.pages = (:) }
  else if mode == "pages-missing" { o.pages = ((page: 1),) }
  else if mode == "pages-key" { o.pages = ((page: 1, bounds: bounds, x: 1),) }
  else if mode == "pages-id" { o.pages = ((page: -1, bounds: bounds),) }
  else if mode == "pages-duplicate" { o.pages = ((page: 1, bounds: bounds),)*2 }
  o
}
#let scene = deixis-routing-scene(..options)
#let route-options = {
  let o = (scene: scene, from: (0pt, 0pt), to: (100pt, 100pt), route: "orthogonal")
  if mode == "scene-tag" { o.scene = (:) }
  else if mode == "missing-id" { o.from = <missing> }
  else if mode == "endpoint-key" { o.from = (node: <a>, x: 2) }
  else if mode == "side" { o.from = (node: <a>, side: center) }
  else if mode == "at" { o.from = (node: <a>, at: 101%) }
  else if mode == "owner-normal" { o.from = (point: (40pt, 30pt), owner: <a>) }
  else if mode == "owner-boundary" { o.from = (point: (35pt, 30pt), normal: right, owner: <a>) }
  else if mode == "normal" { o.from = (point: (0pt, 0pt), normal: (1, 1)) }
  else if mode == "page-type" { o.page = true }
  else if mode == "page-missing" { o.page = 3 }
  else if mode == "page-conflict" { o.from = <a>; o.page = 1 }
  else if mode == "page-cross" {
    o.scene = deixis-routing-scene(nodes: ((id: <a>, bounds: bounds, page: 1), (id: <b>, bounds: bounds, page: 2)))
    o.from = <a>; o.to = <b>
  }
  else if mode == "route" { o.route = "curve" }
  else if mode == "radius" { o.radius = 5pt }
  else if mode == "via-switch" { o.via = ("curve",) }
  else if mode == "sections" { o.segments = ((route: "orthogonal"),) }
  o
}
#let route = deixis-route(..route-options)
#if mode == "prepare-failure" {
  let bad = deixis-route(scene: scene, from: (30pt, 30pt), to: (100pt, 100pt), route: "orthogonal")
  deixis-prepare-connector(bad)
}
