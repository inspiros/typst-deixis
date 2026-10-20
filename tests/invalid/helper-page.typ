#import "../../src/lib.typ": *
#show: deixis-setup-notes
#let sample = sys.inputs.at("sample", default: "zero")
#let invalid = (zero: 0, negative: -1, fractional: 1.5, boolean: true,
  string: "2", missing: none, array: (2,), label: <second>, infinite: calc.inf)
#context {
  deixis-query-notes(page: invalid.at(sample))
}
