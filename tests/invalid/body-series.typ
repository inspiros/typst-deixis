#import "../../src/lib.typ": *
#show: deixis-setup-notes
#let kind = sys.inputs.at("kind", default: "inline")
#let call = (inline: deixis-inline-note-body, footnote: deixis-footnote-body,
  endnote: deixis-endnote-body, margin: deixis-margin-note-body,
  inset: deixis-inset-note-body, sidenote: deixis-sidenote-body).at(kind)
#call(id: <standalone>, series: 12)[Body.]
