#import "../../src/lib.typ": *
#show: deixis-setup-notes
#let kind = sys.inputs.at("kind", default: "inline")
#let call = (inline: deixis-inline-note-body, footnote: deixis-footnote-body,
  endnote: deixis-endnote-body, margin: deixis-margin-note-body,
  inset: deixis-inset-note-body, sidenote: deixis-sidenote-body).at(kind)
#deixis-mark(id: <original>, series: "owned")[Original]
// Even a matching explicit series must live on the original, not its attachment.
#call(of: <original>, series: "owned")[Body.]
