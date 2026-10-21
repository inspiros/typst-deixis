#import "@preview/deixis:0.2.0": *
#set page(width: 850pt, height: 330pt, margin: (x: 35pt, y: 30pt), fill: white)
#set text(font: "Libertinus Serif", size: 13pt, fill: rgb("263E48"))
#set heading(numbering: none)
#show heading: set text(font: "DejaVu Sans", size: 21pt)
#show: deixis-setup-notes
#deixis-set(palette: (rgb("32736D"), rgb("526F9B"), rgb("A86C3F")),
  body-style: it => text(size: 12pt, it))

= Make The Equation Readable

Bayes' rule connects an updated belief to the evidence and the starting belief.
#v(30pt)
#let term = deixis-inset-note.with(mark-type: "region", inline: true,
  padding: 6pt, radius: 4pt, width: 158pt,
  anchor: (mark: bottom + center, body: top + center), dx: 0pt, dy: 43pt,
  container-args: (inset: 10pt),
  layer: (mark: "background", body: "foreground"),
  connector: (route: "curve", heads: (body: "stealth")))
#align(center, text(size: 29pt)[
  #term[$P(H|D)$][*Posterior* \
    How plausible is the hypothesis after seeing the data?]
  #h(25pt) $=$ #h(25pt)
  #term(padding: (x: 9pt, top: 15pt, bottom: 10pt), dy: 37pt)[$frac(P(D|H), P(D))$][*Evidence Update* \
    The likelihood is normalized by the probability of the observed data.]
  #h(25pt) $times$ #h(25pt)
  #term[$P(H)$][*Prior* \
    The starting belief, before the new observations arrive.]
])
