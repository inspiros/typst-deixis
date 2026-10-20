#import "../../src/lib.typ": *
#let mode = sys.inputs.at("mode", default: "type")
#show: deixis-setup-notes
#let spec = (if mode == "type" { true } else if mode == "name" { "margin" }
  else if mode == "key" { (left: 2pt, right: 9pt, extra: true) }
  else if mode == "missing" { (left: 2pt) }
  else if mode == "coordinate" { (left: "left", right: 90%) }
  else if mode == "infinite" { (left: calc.inf * 1pt, right: 90%) }
  else if mode == "reversed" { (left: 80%, right: 20%) }
  else if mode == "empty" { (left: 50%, right: 50%) }
  else { (left: -1pt, right: 90%) })
#if mode in ("reversed", "empty", "outside") {
  deixis-connect(from: (pin: <a>), to: (pin: <b>), connector: (spill: spec))
  deixis-pin(<a>)
  pagebreak()
  deixis-pin(<b>)
} else {
  deixis-connect(from: <missing>, to: <missing>, connector: (route: "none", spill: spec))
}
