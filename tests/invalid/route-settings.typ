#import "../../src/lib.typ": *
#show: deixis-setup-notes
#let mode = sys.inputs.at("mode", default: "missing")
#let form = sys.inputs.at("form", default: "explicit")
#let record = (
  missing: (tension: 2), empty: (:), unknown: (kind: "not-a-route"), kind: (kind: true),
  key: (kind: "curve", bogus: 2), radius: (kind: "orthogonal", radius: 4pt),
  inapplicable: (kind: "polyline", tension: 1), disabled: (kind: "none", tension: 2),
  policy: (kind: "curve", parameterization: "uniform"), alias: (kind: "ucr", parameterization: "uniform"),
  parameterization: (kind: "catmull-rom", parameterization: "chordal"),
  policy-type: (kind: "catmull-rom", parameterization: true),
  zero: (kind: "curve", tension: 0), negative: (kind: "curve", tension: -1),
  infinite: (kind: "curve", tension: calc.inf), nan: (kind: "curve", tension: float.nan),
  underflow: (kind: "curve", tension: 1e-320),
  length: (kind: "curve", tension: 2pt), ratio: (kind: "curve", tension: 50%),
  boolean: (kind: "curve", tension: true), "auto": (kind: "curve", tension: auto),
).at(mode)
#let options = {
  if form == "segments" { (segments: ((route: record),)) }
  else if form == "via" { (route: "curve", via: (record,)) } else { (route: record) }
}
#if form == "settings" { deixis-set(connector: options) }
#if form == "margin" {
  deixis-margin-note(connector: options)[Bad settings.]
} else if form == "inset" {
  deixis-inset-note(connector: options)[Source][Bad settings.]
} else {
  deixis-connect(from: (pin: "unprinted-a"), to: (pin: "unprinted-b"),
    connector: if form == "settings" { auto } else { options })
}
