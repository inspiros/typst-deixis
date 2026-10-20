#import "../../src/lib.typ": *
#show: deixis-setup-notes
#let kind = sys.inputs.at("kind", default: "mark")
#let sample = sys.inputs.at("sample", default: "float")
#let value = if sample == "float" { 1.5 } else if sample == "bool" { true }
  else if sample == "none" { none } else { "front" }
#{
  if kind == "mark" { deixis-mark(id: "invalid", z-index: value)[Passage] }
  else if kind == "inline-mark" { deixis-inline-mark(id: "invalid", z-index: value)[Passage] }
  else if kind == "region-mark" { deixis-region-mark(id: "invalid", z-index: value)[Passage] }
  else if kind == "phantom-mark" { deixis-phantom-mark(id: "invalid", z-index: value) }
  else if kind == "inline" { deixis-inline-note-body(id: "invalid", z-index: value)[Body] }
  else if kind == "endnote-body" { deixis-endnote-body(id: "invalid", z-index: value)[Body] }
  else if kind == "footnote-body" { [Footnote#deixis-footnote-body(id: "invalid", z-index: value)[Body].] }
  else if kind == "margin-body" { deixis-margin-note-body(id: "invalid", z-index: value)[Body] }
  else if kind == "inset-body" { deixis-inset-note-body(id: "invalid", z-index: value)[Body] }
  else if kind == "endnote" { deixis-endnote(id: "invalid", z-index: value)[Body] }
  else if kind == "footnote" { [Footnote#deixis-footnote(id: "invalid", z-index: value)[Body].] }
  else if kind == "margin" { deixis-margin-note(id: "invalid", z-index: value)[Body] }
  else if kind == "sidenote" { deixis-sidenote(id: "invalid", z-index: value)[Body] }
  else if kind == "inset" { deixis-inset-note(id: "invalid", z-index: value)[Body] }
  else if kind == "config" {
    deixis-set(z-index: (inset-note: (body: value)))
    deixis-inset-note-body(id: "invalid", layer: "foreground")[Body]
  } else {
    [#deixis-pin("a")Start. #deixis-pin("b")End.]
    deixis-connect(from: (pin: "a"), to: (pin: "b"), connector: (z-index: value))
  }
}
