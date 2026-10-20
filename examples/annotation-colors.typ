#import "@preview/deixis:0.2.0": *
#set page(width: 560pt, height: 390pt, margin: (left: 35pt, right: 145pt, y: 30pt))
#set text(size: 11pt)
#show: deixis-setup-notes

// A recipe using existing options, not an automatic palette API. The authored
// index selects the color; native measurement/painting never advances a cycle.
#let colors = (rgb("3B6D9A"), rgb("387C69"), rgb("9A663F"))
#let accent(i) = colors.at(calc.rem(i, colors.len()))
#let annotation(i, kind, passage, body) = {
  let color = accent(i)
  let options = (
    stroke: 0.6pt + color,
    fill: (mark: color.transparentize(91%), body: none),
    marker-style: it => text(fill: color, super(it)),
    connector: (route: "orthogonal", radius: 3pt, stroke: color + 0.6pt),
  )
  if kind == "margin" {
    deixis-margin-note(id: "margin-" + str(i), width: 110pt, side: right,
      ..options, passage, body)
  } else {
    deixis-inset-note(id: "inset-" + str(i), width: 120pt, dx: 195pt, dy: 0pt,
      ..options, passage, body)
  }
}

= A Shared Accent Per Annotation

Color can pair a passage with its note. Text keeps the document's normal color;
markers, highlights and connectors carry the accent.

#for i in range(4) {
  v(20pt)
  annotation(i, "margin", [Passage #(i + 1)], [A margin explanation for passage #(i + 1).])
}

#v(15pt)
// Reuse the selected accent explicitly. A future identity-owned palette should
// do this without asking the caller to look up the index again.
#deixis-mark(of: "margin-0", stroke: 0.6pt + accent(0),
  fill: accent(0).transparentize(91%))[The first passage again]
keeps its marker and its authored accent.

#pagebreak()
= The Same Recipe For Inset Notes

The body border uses the same accent. After the third color, this recipe wraps
back to the first.

#for i in range(4) {
  v(25pt)
  annotation(i, "inset", [Passage #(i + 1)], [A compact inset explanation.])
}
