#import "@preview/deixis:0.2.0": *
#set page(width: 420pt, height: 300pt, margin: (left: 35pt, right: 130pt, y: 35pt))
#show: deixis-setup-notes
#let final = sys.inputs.at("final", default: "false") == "true"
#deixis-set(omit: if final { (series: ("review",)) } else { none })

= Review Comments

A #deixis-comment(author: "Ada", status: "open")[provisional claim][Check this wording.]
needs supporting evidence#deixis-footnote[A source retained in both builds.].

The final copy keeps the passage and the source, with no editorial marker or gap
in the source's numbering.
