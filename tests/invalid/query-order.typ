#import "../../src/lib.typ": *
#show: deixis-setup-notes
#let sample = sys.inputs.at("sample", default: "unknown")
#let values = (unknown: "number", missing: none, boolean: true, array: ("body",),
  integer: 1, callback: n => n)
#context deixis-query-notes(order: values.at(sample))
