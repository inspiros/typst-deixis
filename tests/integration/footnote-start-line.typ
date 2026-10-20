// A source indentation space used to force the body onto a new line when
// marker + body fitted exactly. Native weak spacing must work through styles.
#import "../../src/lib.typ": *
#set page(width: 98pt, height: 180pt, margin: 30pt)
#set text(size: 11pt)
#show: deixis-setup-notes
#let mode = sys.inputs.at("mode", default: "flow")
#if sys.inputs.at("gap", default: "default") == "zero" { deixis-set(marker-gap: 0pt) }
#let note(body) = if mode == "native" { std.footnote(body) } else { deixis-footnote(layer: mode, body) }
Word#note[Alpha.]
#pagebreak()
Word#note(text(fill: teal)[
  Alpha.
])
