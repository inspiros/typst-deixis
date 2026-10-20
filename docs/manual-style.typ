#let ink = rgb("243B48")
#let accent = rgb("496579")
#let teal = rgb("32736D")
#let pale = rgb("F3F6F7")
#let muted = rgb("5D6B74")
#let mono(body, size: 8.2pt) = text(font: "DejaVu Sans Mono", size: size, body)
#let badge(body, color: accent) = box(inset: (x: 5pt, y: 2.5pt), radius: 2pt,
  fill: color.lighten(92%), stroke: 0.4pt + color.lighten(70%),
  text(font: "DejaVu Sans", size: 6.8pt, weight: "bold", fill: color, body))
#let setup-badge(kind) = badge((setup: "SETUP REQUIRED", free: "NO SETUP", conditional: "CONDITIONAL", installs: "INSTALLS SETUP").at(kind),
  color: if kind == "free" { teal } else { accent })
#let code(source) = block(width: 100%, fill: pale, inset: 8pt, radius: 3pt,
  above: 6pt, below: 6pt, breakable: false, raw(source, lang: "typst", block: false))
#let manual(body, version: "0.2.0", paper: "a4", monochrome: false) = {
  set page(paper, margin: (x: 21mm, top: 19mm, bottom: 20mm), numbering: "1",
    header: context if here().page() > 1 {
      set text(font: "DejaVu Sans", size: 7pt, fill: muted)
      [DEIXIS #h(1fr) #version · API Guide]
    },
    footer: context {
      set text(font: "DejaVu Sans", size: 7.5pt, fill: muted)
      [#line(length: 100%, stroke: 0.4pt + luma(215))#v(3pt)Notes · Highlights · Connections #h(1fr) #counter(page).display()]
    })
  set text(size: 10pt, fill: ink)
  set par(leading: 0.65em, spacing: 0.7em, justify: false)
  set heading(numbering: none)
  show heading.where(level: 1): it => block(above: 0pt, below: 12pt)[
    #set text(font: "DejaVu Sans", size: 21pt, weight: "bold", fill: accent)
    #it.body
  ]
  show heading.where(level: 2): it => block(above: 13pt, below: 6pt)[
    #set text(font: "DejaVu Sans", size: 12pt, weight: "bold", fill: ink)
    #it.body
  ]
  show heading.where(level: 3): it => block(above: 8pt, below: 4pt)[
    #set text(font: "DejaVu Sans", size: 10pt, weight: "bold", fill: ink)
    #it.body
  ]
  show raw: set text(font: "DejaVu Sans Mono", size: 8pt)
  show raw.where(block: true): it => code(it.text)
  show link: it => text(fill: teal, it)
  show outline.entry: set text(size: 9pt)
  if monochrome {
    // Native black/gray override at the document boundary, including code.
    set text(fill: black)
    show text: it => text(fill: black, it)
  }
  body
}
