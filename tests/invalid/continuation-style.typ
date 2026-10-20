#import "../../src/lib.typ": *
#let mode = sys.inputs.at("mode", default: "shape")
#show: deixis-setup-notes
#let spec = (if mode == "shape" { "unknown" }
  else if mode == "type" { true }
  else if mode == "key" { (shape: "portal", bogus: true) }
  else if mode == "zero" { (size: 0pt) }
  else if mode == "negative" { (size: -2pt) }
  else if mode == "ratio" { (size: 20%) }
  else if mode == "link" { (link: true) }
  else { "portal" })
// Validate even disabled declarations; legacy callbacks cannot expose a shaft
// for hollow-marker trimming and should use the existing renderer contract.
#deixis-connect(from: <missing>, to: <missing>, connector: (
  route: if mode == "legacy" { _ => [] } else { "none" }, continuation: spec))
