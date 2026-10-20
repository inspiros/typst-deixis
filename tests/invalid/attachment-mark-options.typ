#import "../../src/lib.typ": *
#show: deixis-setup-notes
#let kind = sys.inputs.at("kind", default: "footnote")
#let option = sys.inputs.at("option", default: "numbering")
#let call = (footnote: deixis-footnote, endnote: deixis-endnote,
  margin: deixis-margin-note, inset: deixis-inset-note, sidenote: deixis-sidenote,
  inline: deixis-inline-note).at(kind)
#let value = (numbering: "*", series: "owned", marker: [X], mark-type: "region",
  marker-position: top, inline-mode: "underline", pins: ("discarded",), padding: 5pt,
  region-shape: rect, inline: true, layer: "background").at(option)
#deixis-mark(id: <original>, series: "owned")[Original]
#call(of: <original>, ..((option): value))[Body.]
