#import "../../src/lib.typ": *
#show: deixis-setup-notes
#let mode = sys.inputs.at("mode", default: "type")
#let form = sys.inputs.at("form", default: "explicit")
#let spec = (type: true, item: (1,), unknown: (at: 50%, length: 10pt, width: 2pt),
  missing: (at: 50%), mixed: (at: 50%, length: 10pt, from: 0pt, to: 10pt),
  coordinate: (at: "middle", length: 10pt), relative: (at: 50% + 1pt, length: 10pt),
  negative: (from: -1pt, to: 20pt), zero: (at: 50%, length: 0pt),
  "negative-length": (at: 50%, length: -5%), empty: (:)).at(mode)
#let options = (route: "curve", cuts: spec)
#{
  if form == "explicit" { deixis-connect(from: <a>, to: <a>, connector: options) }
  else if form == "margin" { deixis-margin-note(connector: options)[Body] }
  else { deixis-inset-note(connector: options)[Body] }
}
