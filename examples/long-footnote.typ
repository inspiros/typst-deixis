#import "@preview/deixis:0.2.0": *
#set page(width: 420pt, height: 430pt, margin: 35pt, numbering: "1")
#set text(size: 11pt)
#show: deixis-setup-notes
#deixis-set(layer: (footnote: "flow"))

= Long Footnotes

A long explanation#deixis-footnote(
  id: <long>,
  container-func: block,
  container-args: (breakable: true, inset: 5pt),
  stroke: (body: teal + 0.5pt),
)[
  This explanation uses a breakable native block. The border and content
  continue across pages; an unbreakable rectangle would keep them together.

  #for i in range(1, 9) {
    [*Part #i.* #lorem(35)]
    parbreak()
  }
] can continue across several pages while the paragraph remains ordinary prose.

Source indentation does not force a break#deixis-footnote[
  This note starts beside its marker.
], and the following space is preserved.

#for i in range(3) { lorem(35); parbreak() }
