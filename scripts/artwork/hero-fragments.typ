// Independently compiled transparent specimens, not a simulated document.
// Preview with --input kind=text|equation|shared|diagram|editorial|footnote|outline|local.
#import "@preview/deixis:0.2.0": *
#let coral = rgb("EB596E")
#let teal = rgb("008E91")
#let violet = rgb("8852CA")
#let blue = rgb("426DE0")
#let amber = rgb("D49316")
#set page(fill: none)
#set text(font: "Libertinus Serif", size: 20pt, fill: rgb("24374D"))
#set par(leading: 0.65em, spacing: 1.1em)
#show: deixis-setup-notes
#deixis-set(body-style: it => text(size: 16pt, it), overflow: "error")
#let kind = sys.inputs.at("kind", default: "text")

#if kind == "text" [
  #set page(width: 520pt, height: 180pt, margin: 22pt)
  Give a #deixis-inline-mark(marker: none, stroke: none,
    fill: coral.lighten(82%), radius: 3pt)[clear idea] room to grow.

  Follow a #deixis-inline-mark(marker: none, inline-mode: "underline",
    stroke: 1.4pt + teal, fill: none)[different thread].

  Find a #deixis-inline-mark(marker: none, stroke: 1pt + blue,
    fill: blue.lighten(94%), radius: 4pt)[point of view].
] else if kind == "equation" [
  #set page(width: 540pt, height: 265pt, margin: (x: 25pt, top: 32pt, bottom: 20pt))
  #text(size: 33pt)[
    #deixis-inset-note(mark-type: "region", inline: true,
      marker: [★], padding: 5pt, radius: 12pt, layer: (mark: "background"),
      stroke: (mark: 1.3pt + violet, body: 1pt + violet, connector: 1.3pt + violet),
      fill: (mark: violet.lighten(91%), body: violet.lighten(94%)),
      width: 270pt, anchor: (mark: bottom + center, body: top + left),
      dx: -20pt, dy: 36pt, container-args: (inset: 13pt),
      connector: (route: "curve", heads: (body: "stealth")),
    )[#box(inset: (x: 16pt, y: 24pt))[$overline(x) = 1/n sum_(i=1)^n x_i$]][
      *Make Space For The Meaning* \
      Explain the whole expression, right where it matters.
    ]
  ]
] else if kind == "shared" [
  #set page(width: 550pt, height: 225pt, margin: (left: 20pt, right: 280pt, y: 28pt))
  #deixis-margin-note(id: <idea>, marker: [A], mark-type: "region", inline: true,
    padding: 4pt, layer: (mark: "background"), side: right, width: 245pt, dx: 18pt,
    stroke: (mark: 1pt + teal, body: 1pt + teal, connector: 1.3pt + teal),
    fill: (mark: teal.lighten(90%), body: teal.lighten(94%)), radius: 6pt,
    container-func: deixis-alert-container, container-args: (inset: 13pt),
    connector: (route: "curve", heads: (body: "triangle")),
  )[One useful idea][*One Note, Many Passages* \
    Keep one explanation. Return to it from anywhere.]
  #v(40pt)
  #deixis-mark(of: <idea>, occurrence: <again>, mark-type: "region", inline: true,
    padding: 4pt, layer: "background", radius: 6pt,
    stroke: 1.4pt + teal, fill: teal.lighten(90%))[Another connection]
  #deixis-connect(from: (mark: <idea>, occurrence: <again>), to: <idea>,
    connector: (route: "curve", stroke: 1.3pt + teal,
      ports: (mark: right, body: left), heads: (body: "stealth")))
] else if kind == "diagram" [
  #set page(width: 460pt, height: 240pt, margin: 25pt)
  #set text(font: "DejaVu Sans", size: 14pt)
  #let node(id, accent, body) = deixis-attach(id: id)[
    #rect(width: 120pt, height: 45pt, inset: 8pt, radius: 9pt,
      stroke: 1.4pt + accent, fill: accent.lighten(90%), align(center + horizon, body))
  ]
  #grid(columns: (120pt, 130pt, 120pt), rows: (60pt, 60pt, 60pt),
    [], [], node(<question>, blue, [A New Question]),
    node(<source>, amber, [An Observation]), [], [],
    [], [], node(<answer>, coral, [A Better Answer]),
  )
  #deixis-connect(from: (node: <source>), to: (node: <question>),
    connector: (route: "curve", stroke: 1.8pt + blue, heads: (body: "stealth")))
  #deixis-connect(from: (node: <source>), to: (node: <answer>),
    connector: (route: "right-angle", radius: 10pt,
      stroke: (paint: coral, thickness: 1.6pt, dash: "dashed"), heads: (body: "triangle")))
] else if kind == "editorial" [
  #set page(width: 450pt, height: 220pt, margin: 22pt)
  #let badge(it) = text(font: "DejaVu Sans", size: 16pt, fill: coral, it)
  A #deixis-inset-note(mark-type: "inline", inline-mode: "text-fill",
    marker: [❶], marker-style: badge,
    layer: (mark: "background", body: "foreground"),
    stroke: (mark: 1.2pt + coral, body: 1pt + coral, connector: 1.2pt + coral),
    fill: (mark: none, body: coral.lighten(91%)), radius: 12pt,
    width: 285pt, anchor: (mark: bottom + left, body: top + left),
    dy: 35pt, dx: -60pt, container-args: (inset: 13pt),
    data: (author: "Ada", status: "open"),
    connector: (route: "right-angle", radius: 6pt, ports: (mark: bottom, body: top),
      heads: (body: "circle")),
  )[bold claim][*Ada · Open* \
    What if we look at this another way?] deserves a closer look.
] else if kind == "local" [
  #set page(width: 390pt, height: 225pt, margin: 18pt)
  #set text(size: 16pt)
  #deixis-set(stroke: 0.8pt + amber,
    marker-style: it => super(text(fill: amber, it)))
  #deixis-block[
    #figure(kind: table, caption: [Measurements#deixis-footnote(
      id: <calibration>, numbering: "a")[One calibration for this table.].])[
      #table(columns: (1fr, 1fr), inset: 5pt,
        stroke: (x: none, y: 0.6pt + amber.lighten(60%)),
        fill: (x, y) => if y == 0 { amber.lighten(88%) } else { none },
        table.header([*Sample*], [*Result*]),
        [Control], [12.4],
        [Trial], [18.7#deixis-footnote(id: <trial>, numbering: "a")[Excludes one damaged sample.]],
      )
    ]
  ]
  // Native context keeps the rendered ownership contract inspectable.
  #context [#metadata((
    notes: query(<deixis-footnote>).map(n => (owner: n.value.inst-id, layer: n.value.layer)),
    owners: query(<deixis-block-start>).map(n => n.value.id),
    native: counter(footnote).final(),
    bodies: query(<deixis-body-destination>).len(),
  ))<hero-local-evidence>]
] else if kind == "outline" [
  #set page(width: 440pt, height: 240pt, margin: 22pt)
  #set text(size: 17pt)
  #show heading: set text(font: "DejaVu Sans", size: 18pt, weight: "bold")
  #deixis-set(palette: (amber, blue, teal))
  #text(size: 14pt)[
    #deixis-endnote[Questions][Clarify the central claim.],
    #deixis-endnote[details][Keep the useful details.],
    #deixis-endnote[sources][Return to the evidence.]
  ]
  #deixis-note-outline(title: [Every Note, In One Place], fill: repeat[·], gap: 12pt)
] else if kind == "footnote" [
  #set page(width: 400pt, height: 110pt, margin: (x: 18pt, y: 12pt))
  #set text(size: 17pt, fill: rgb("566781"))
  Even the smallest detail#deixis-footnote[has a place of its own.] belongs.
] else {
  panic("Unknown hero fragment: " + kind)
}
