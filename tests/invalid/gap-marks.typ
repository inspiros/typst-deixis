#import "../../src/lib.typ": *
#show: deixis-setup-notes
#let mode = sys.inputs.at("mode", default: "shape")
#let form = sys.inputs.at("form", default: "explicit")
#let spec = (shape: "circle", type: true, key: (padding: 2pt),
  size: (size: 50%), zero: (size: 0pt), negative: (size: -2pt)).at(mode)
#let options = (route: "curve", gap-marks: spec)
#{
  if form == "explicit" { deixis-connect(from: <a>, to: <a>, connector: options) }
  else if form == "margin" { deixis-margin-note(connector: options)[Body] }
  else { deixis-inset-note(connector: options)[Body] }
}
