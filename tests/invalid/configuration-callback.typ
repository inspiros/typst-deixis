#import "../../src/lib.typ": *
#show: deixis-setup-notes
#let option = sys.inputs.at("option", default: "render-single")
#let sample = sys.inputs.at("sample", default: "number")
#let value = if sample == "number" { 12 } else if sample == "dictionary" { (unknown: 12,) } else { none }
#deixis-set(..((option): ((if option == "region-shape" { "mark" } else { "body" }): value)))
#if option == "region-shape" {
  deixis-region-mark(inline: true)[Region]
} else if sys.inputs.at("body", default: "footnote") == "inline" {
  deixis-mark(id: <configured>)[Source]
  deixis-inline-note-body(of: <configured>)[Body]
} else {
  [Anchor#deixis-footnote[Body] following text.]
}
