#import "../../src/lib.typ": *
#let mode = sys.inputs.at("mode", default: "edges-type")
#let edge = (from: (0pt, 0pt), to: (100pt, 0pt))
#let edges = {
  if mode == "edges-type" { (:) }
  else if mode == "edges-count" { (edge,) * 17 }
  else if mode == "edge-type" { (1,) }
  else if mode == "edge-missing" { ((from: (0pt, 0pt)),) }
  else if mode == "edge-key" { (edge + (route: "hobby"),) }
  else if mode == "id-type" { (edge + (id: 1),) }
  else if mode == "id-empty" { (edge + (id: ""),) }
  else if mode == "duplicate" { (edge + (id: <x>), edge + (id: "x")) }
  else if mode == "via-type" { (edge + (via: (:)),) }
  else if mode == "via-switch" { (edge + (via: ("hobby",)),) }
  else if mode == "via-font" { (edge + (via: ((1em, 10pt),)),) }
  else if mode == "normal" { (edge + (from: (point: edge.from, normal: (1, 1))),) }
  else if mode == "owner-boundary" { (edge + (from: (point: (35pt, 30pt), normal: right, owner: <owner>)),) }
  else if mode == "endpoint-junction" { (edge + (from: (point: edge.from, junction: <x>)),) }
  else if mode == "page-cross" { ((from: <a>, to: <b>),) }
  else if mode == "page-conflict" { ((from: <a>, to: (100pt, 0pt), page: 2),) }
  else if mode == "page-missing" { (edge + (page: 3),) }
  else if mode in ("overflow", "weight-nan") { (edge, edge + (from: (0pt, 1pt), to: (100pt, 1pt))) }
  else { (edge,) }
}
#let options = {
  let o = (:)
  if mode == "spacing-zero" { o.spacing = 0pt }
  else if mode == "spacing-font" { o.spacing = 1em }
  else if mode == "spacing-percent" { o.spacing = 2% }
  else if mode == "spacing-inf" { o.spacing = calc.inf * 1pt }
  else if mode == "weight-negative" { o.weight = -1 }
  else if mode == "weight-bool" { o.weight = true }
  else if mode == "weight-inf" { o.weight = calc.inf }
  else if mode == "weight-nan" { o.weight = float.nan }
  else if mode == "overflow" { o.weight = 1e308 }
  else if mode == "detour-negative" { o.max-detour = -1% }
  else if mode == "detour-type" { o.max-detour = 1 }
  else if mode == "detour-inf" { o.max-detour = calc.inf * 1% }
  else if mode == "rounds-type" { o.rounds = 1.5 }
  else if mode == "rounds-range" { o.rounds = 5 }
  else if mode == "searches" { o.max-searches = 0 }
  else if mode == "expansions" { o.max-expansions = true }
  else if mode == "scene" { o.scene = (:) }
  else if mode == "owner-boundary" {
    o.scene = deixis-routing-scene(nodes: ((id: <owner>,
      bounds: (left: 20pt, top: 20pt, right: 40pt, bottom: 40pt)),))
  }
  else if mode in ("page-cross", "page-conflict") {
    o.scene = deixis-routing-scene(nodes: (
      (id: <a>, page: 1, bounds: (left: 0pt, top: 0pt, right: 10pt, bottom: 10pt)),
      (id: <b>, page: 2, bounds: (left: 0pt, top: 0pt, right: 10pt, bottom: 10pt))))
  }
  o
}
#let plan = deixis-route-group(edges, ..options)
