#import "manual-style.typ": *
#let examples = json("examples/catalog.json")
#let source-code(item) = {
  let source = read(item.source)
  if item.at("excerpt", default: none) == "touying" {
    // Exact excerpt from the authored slide; theme/setup stay in its source.
    let begin = source.position("  #pause")
    let end = source.position("  #v(0.5em)")
    return source.slice(begin, end).trim()
  }
  source.split("// BEGIN EXAMPLE\n").at(1).split("// END EXAMPLE").first().trim()
}
#let worked-example(item) = block(breakable: false, above: 5pt, below: 9pt)[
  #metadata(item.id)<manual-example>
  #heading(level: 2, item.title)
  #setup-badge(item.setup)
  #h(0.5em)#text(size: 7.5pt, fill: muted)[EDITABLE SOURCE · #item.source]
  #v(4pt)
  #grid(columns: if item.at("full", default: false) { (0.9fr, 1.4fr) } else { (1.12fr, 1fr) }, column-gutter: 10pt,
    block[
      #show raw: set text(size: if item.at("full", default: false) { 8.3pt } else { 9pt })
      #text(font: "DejaVu Sans", size: 7pt, fill: muted)[SOURCE]
      #block(width: 100%, fill: pale, inset: 7pt, radius: 3pt,
        above: 4pt, below: 0pt,
        raw(source-code(item), lang: "typst", block: false))
    ],
    block[
      #text(font: "DejaVu Sans", size: 7pt, fill: muted)[RENDERED OUTPUT]
      #v(4pt)
      #for page in range(1, item.pages + 1) {
        if item.pages > 1 { text(size: 7pt, fill: muted)[#if item.id == "touying" { [Frame #page · #if page == 1 { [Before Pause] } else { [After Pause] }] } else { [Page #page] }] }
        block(width: 100%, stroke: 0.4pt + luma(215), inset: 3pt, above: 2pt, below: 5pt,
          image("assets/examples/" + item.id + "-" + str(page) + ".svg", width: 100%,
            alt: item.title + ", rendered " + str(page)))
      }
    ],
  )
  #v(4pt)
  #text(size: 9pt, item.caption)
]

= Worked Examples

Read the source on the left and compare the result on the right. Each example
is compiled as its own document, with independent labels, counters and page
geometry. The SVG previews show actual output; they do not execute notes inside
this manual. Open the named source for its full setup and working PDF links.

The specimens import Deixis and use a muted accent. “No Setup” drawings omit
the final show rule:

#code("#import \"@preview/deixis:0.2.0\": *\n#let teal = rgb(\"32736D\")\n#show: deixis-setup-notes")

Page size/margins and text size are chosen for the small specimen. Margin-note
examples reserve a wide right margin. The displayed source is the exact authored
body; page geometry and the common preamble are in the named editable file.
For Touying, its theme/overlay configuration is in the complete slide example.

The Touying comparison gives both frames the same scale in a wider output column.

The following pages progress from ordinary notes to shared identities and
styling, then custom content and drawings. Optional effects are shown explicitly;
they are not enabled by ordinary note calls.

#for (index, item) in examples.enumerate() {
  // Start on a fresh page after the legend. Pair ordinary small examples;
  // cross-page/host comparisons receive their own source/output page.
  if index == 0 or calc.rem(index, 2) == 0 or item.at("full", default: false) { pagebreak() }
  worked-example(item)
}
#pagebreak()
