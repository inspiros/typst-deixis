#import "@preview/deixis:0.2.0": *
#let final = sys.inputs.at("final", default: "false") == "true"
#set page(width: 440pt, height: 265pt,
  margin: (left: 24pt, right: 134pt, top: 25pt, bottom: 24pt), fill: white)
#set text(font: "Libertinus Serif", size: 12pt, fill: rgb("263E48"))
#set par(leading: 0.7em)
#set heading(numbering: none)
#show heading: set text(font: "DejaVu Sans", size: 17pt)
#show: deixis-setup-notes
#deixis-set(omit: if final { (series: ("review",)) } else { none }, overflow: "error")

= Review A Claim

The #deixis-comment(author: "Ada", status: "open", side: right, width: 107pt, dx: 12pt,
  stroke: rgb("A86C3F"), fill: rgb("FFF4E8"),
  connector: (route: "right-angle", radius: 3pt),
)[proposed method][State the conditions under which this claim holds.]
preserves the structure of the original argument.

Supporting evidence#deixis-footnote[The cited source remains in both builds.]
belongs in the finished document.

The final copy keeps the passage and the source. Editorial marks, explanations,
and connectors disappear together.
