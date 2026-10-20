#import "../../src/lib.typ": *
#show: deixis-setup-notes
#let consumer = sys.inputs.at("consumer", default: "printer")
#let option = sys.inputs.at("option", default: "after")
#let value = (integer: 1, boolean: false, array: (), content: [edge], fraction: 1fr,
  "auto": auto).at(sys.inputs.at("value", default: "integer"))
#{
  if consumer == "printer" { deixis-print-endnotes(..((option): value)) }
  else if consumer == "outline" { deixis-note-outline(..((option): value)) }
  else { context deixis-query-notes(..((option): value)) }
}
