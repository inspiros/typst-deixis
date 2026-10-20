#import "../../src/lib.typ": *
#let mode = sys.inputs.at("mode", default: "missing")
#set page(width: 300pt, height: 210pt, margin: 20pt)
#let document(body) = if mode == "setup" { body } else { deixis-setup-notes(body) }
#show: document
#let policy = (if mode == "spacing" { (spacing: 0pt) }
  else if mode == "budget" { (max-searches: 1) } else { (:) })
#show: deixis-routing.with(..policy)
#let options = (if mode == "curve" { (route: "hobby") }
  else if mode == "radius" { (radius: 2pt) }
  else if mode == "mixed" { (via: ((80pt, 20pt), "straight-line")) }
  else if mode == "scene" { (scene: deixis-routing-scene()) } else { (:) })
#let target = (if mode == "node-page" { (node: <a>, page: -1) }
  else if mode == "node-field" { (node: <a>, side: right) } else { (node: <a>) })
#for _ in range(if mode == "count" { 17 } else if mode == "budget" { 2 } else { 1 }) {
  deixis-connect(from: target, to: (node: if mode == "missing" { <absent> } else { <b> }), connector: options)
}
#place(top + left, dx: 0pt, dy: 40pt)[#deixis-attach(
  id: if mode == "id" { 3 } else { <a> },
  behavior: if mode == "behavior" { "unknown" } else { auto },
  rect(width: if mode == "zero" { 0pt } else { 30pt }, height: 20pt))]
#place(top + left, dx: 200pt, dy: 80pt)[#deixis-attach(id: <b>)[#rect(width: 30pt, height: 20pt)]]
#if mode == "duplicate" {
  place(top + left, dx: 0pt, dy: 80pt, deixis-attach(id: "a", rect(width: 30pt, height: 20pt)))
}
