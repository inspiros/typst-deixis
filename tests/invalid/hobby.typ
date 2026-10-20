#import "../../src/lib.typ": *
#show: deixis-setup-notes
#let mode = sys.inputs.at("mode", default: "low")
#let form = sys.inputs.at("form", default: "explicit")
#let records = (
  low: (tension: 0.5), zero: (tension: 0), negative: (tension: -1),
  infinite: (tension: calc.inf), nan: (tension: float.nan), length: (tension: 1pt),
  ratio: (tension: 50%), boolean: (tension: true), string: (tension: "1"),
  tension-auto: (tension: auto), curl-negative: (curl: -1), curl-infinite: (curl: calc.inf),
  curl-nan: (curl: float.nan), curl-type: (curl: "1"), curl-boolean: (curl: false),
  curl-length: (curl: 2pt), curl-ratio: (curl: 50%), curl-auto: (curl: auto),
  curl-array: (curl: (1, 1)), curl-key: (curl: (source: 0)),
  curl-mark: (curl: (mark: auto)), curl-body: (curl: (body: -1)),
  controls: (controls: ((20pt, 30pt),)), parameterization: (parameterization: "uniform"),
  close: (close: true), degree: (degree: 3),
)
#let record = (kind: "hobby") + records.at(mode, default: (:))
#if mode == "wrong-family" { record = (kind: "curve", curl: 1) }
#if mode == "numeric" { record = (kind: "hobby", tension: 1e308, curl: 1e308) }
#let options = {
  if form == "segments" { (segments: ((route: record),)) }
  else if form == "via" { (route: "hobby", via: (record,)) } else { (route: record) }
}
#if mode == "numeric" { options.ports = (mark: left) }
#if form == "settings" { deixis-set(connector: options) }
#if form == "margin" {
  deixis-margin-note(connector: options)[Source][Invalid settings.]
} else if form == "inset" {
  deixis-inset-note(connector: options)[Source][Invalid settings.]
} else {
  deixis-connect(from: (pin: "a"), to: (pin: "b"),
    connector: if form == "settings" { auto } else { options })
}
#place(top + left, dx: 10pt, dy: 20pt, deixis-pin("a", padding: 0pt))
#place(top + left, dx: 200pt, dy: 120pt, deixis-pin("b", padding: 0pt))
Text.
