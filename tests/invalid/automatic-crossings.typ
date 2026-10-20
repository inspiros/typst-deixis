#import "../../src/lib.typ": *
#show: deixis-setup-notes
#let mode = sys.inputs.at("mode", default: "shape")
#let spec = (shape: "bridge", type: true, key: (jump: true), mode: (mode: "bridge"),
  group: (group: 1), empty: (group: ""), ratio: (gap: 10%), zero: (gap: 0pt),
  negative: (clearance: -1pt)).at(mode, default: "gap")
#deixis-pin("a", padding: 0pt)
#place(top + left, dx: 150pt, dy: if mode == "precision" { 1e10pt } else { 100pt }, deixis-pin("b", padding: 0pt))
#deixis-connect(from: (pin: "a"), to: (pin: "b"), connector: (
  crossings: spec, route: if mode == "precision" { "curve" } else if mode == "legacy" { request => [] } else { "orthogonal" },
  ports: if mode == "precision" { (mark: right, body: left) } else { auto },
  radius: if mode == "rounded" { 8pt } else { 0pt },
))
