#import "../../src/lib.typ": *
#show: deixis-setup-notes
#let consumer = sys.inputs.at("consumer", default: "printer")
#let option = sys.inputs.at("option", default: "series")
#let sample = sys.inputs.at("sample", default: "scalar")
#let value = if sample == "array" { ("notes", 12) } else if sample == "auto" { auto } else { 12 }
#if consumer == "printer" {
  deixis-print-endnotes(..((option): value))
} else if consumer == "outline" {
  deixis-note-outline(..((option): value))
} else { context deixis-query-notes(..((option): value)) }
