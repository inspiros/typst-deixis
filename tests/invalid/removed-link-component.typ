#import "../../src/lib.typ": *
#show: deixis-setup-notes
// 0.2 renamed the connector style component from link to connector.
#let form = sys.inputs.at("form", default: "note")
#if form == "settings" { deixis-set(stroke: (inset-note: (body: teal, link: gray))) }
#deixis-inset-note(dx: 40pt, dy: 20pt, connector: "curve",
  ..if form == "note" { (stroke: (body: teal, link: gray)) } else if form == "z-index" { (z-index: (link: 2)) } else { (:) })[A][B]
