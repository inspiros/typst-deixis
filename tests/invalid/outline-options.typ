#import "../../src/lib.typ": *
#show: deixis-setup-notes
#let option = sys.inputs.at("option", default: "group-by")
#let sample = sys.inputs.at("sample", default: "unknown")
#let value = (if sample == "callback" { note => 12 }
  else if sample == "array" { ("mark", "body") }
  else if sample == "none" { none }
  else if sample == "bool" { true }
  else { "unknown" })
#deixis-endnote[An indexed body.]
#deixis-note-outline(..((option): value))
