#import "@preview/tidy:0.4.3"
#import "@preview/gentle-clues:1.3.1": *

#import "../src/lib.typ"
#import "../src/lib.typ": *
#show: deixis-setup-notes

#import "logo.typ": deixis-logo
#import "demo.typ": demo, show-demo
#show: show-demo

#let show-module(
  module,
  fn: none,
  ..args) = {
  if fn not in (none, auto) {
    module.functions = module.functions.filter(f => f.name == fn)
    module.variables = module.variables.filter(v => v.name == fn)
  }

  // scrubber
  module.functions = module.functions.map(f => {
    let desc = f.at("description", default: "")
    if desc != "" {
      desc = desc.replace(regex("(?m)^[ \t]*-[ \t]+[a-zA-Z0-9_.-]+[ \t]*\\(.*?\\):.*\\n?"), "")
      f.description = desc.trim()
    }
    f
  })

  import "deixis-style.typ"
  tidy.show-module(
    ..args,
    module,
    sort-functions: none,
    show-module-name: false,
    show-outline: false,
    first-heading-level: 3,
    style: deixis-style
  )
}

#set page(numbering: "1")
// #set text(font: "Linux Libertine", size: 11pt)
#set heading(numbering: (..numbers) => {
  let n = numbers.pos()
  if n.len() <= 3 {
    numbering("1.1.", ..n)
  }
})
#show heading: it => {
  if it.level == 5 {
    set text(fill: luma(100))
    it
  } else {
    it
  }
}

#let manifest = toml("../typst.toml")

#let version = manifest.package.version
#let pkg-name = manifest.package.name
#let description = manifest.package.description
#let repository = manifest.package.repository

#let titlecase(s) = {
  s.split(" ").map(w => if w.len() > 0 { upper(w.first()) + lower(w.slice(1)) } else { w }).join(" ")
}
#align(center)[
  #v(1fr)
  #text(size: 24pt, weight: "bold")[#titlecase(lower(pkg-name).replace("-", " "))] \
  #v(1em)
  #text(size: 14pt, style: "italic")[#description] \
  #v(2em)
  Version #version
  #v(1fr)
]

#outline(depth: 3)
#pagebreak()

#set par(justify: true)

= Introduction
`deixis` is a unified layout engine for footnotes, endnotes, margin notes, inset notes, inline highlights, and spatial annotations.

== Quick Start
To use `deixis`, you must initialize the state engine at the top of your document:

```source
#import "@preview/deixis:0.1.0": *
#show: deixis-setup-notes
```

== Core Concepts

Inspired by ```tex \footnotemark``` and ```tex \footnotetext``` in LaTeX, `deixis` decouples an annotation into distinct components:

- *The mark:*
  The visual indicator placed directly within your text flow.
  It increments counters and records its exact physical coordinates in the document.
```demo
#deixis-inline-mark(
  id: <anatomy>,
)[*Note mark*]
```

- *The body:*
  The actual content of your note.
  It can be rendered anywhere -- floating in the margin, at the bottom of the page, or at the end of a chapter -- while maintaining a bi-directional hyperlink to the mark if they share the same `id`.
```demo
#deixis-inset-note-body(
  id: <anatomy>,
  link: "right-angle",
  link-waypoints: ((200pt, "body"),),
  link-marks: "body",
  label: <anatomy>,
  backlink: true,
)[*Note body.*]
```

- *The link:*
  The optional connection that links the mark to the body.
  Semantically, it can be considered the third component, but programatically, it is treated as part of the body and set via the parameter `link`.

If given a `label`, notes can be referenced anywhere in the document.
The body is also aware of where it is referenced, allowing it to generate backlink buttons #super(emoji.arrow.l.hook).
```demo
See @anatomy.
```

#align(center, {
  deixis-logo
  quote[_Still unamused? There are way more to discover._ #emoji.face.smirk]
})

#pagebreak()

= API Reference

#let doc-scope = (
  ..dictionary(lib),
  demo: demo,
  info: info,
  notify: notify,
  warning: warning,
  danger: danger,
  success: success,
  error: error,
  tip: tip,
  experiment: experiment,
  conclusion: conclusion,
  memo: memo,
  code: code,
)

#let lib-docs = tidy.parse-module(read("../src/lib.typ"), scope: doc-scope)

#let inline-note-docs = tidy.parse-module(read("../src/inline-note.typ"), scope: doc-scope)
#let region-note-docs = tidy.parse-module(read("../src/region-note.typ"), scope: doc-scope)
#let footnote-docs = tidy.parse-module(read("../src/footnote.typ"), scope: doc-scope)
#let endnote-docs = tidy.parse-module(read("../src/endnote.typ"), scope: doc-scope)
#let margin-note-docs = tidy.parse-module(read("../src/margin-note.typ"), scope: doc-scope)
#let inset-note-docs = tidy.parse-module(read("../src/inset-note.typ"), scope: doc-scope)

#let minipage-docs = tidy.parse-module(read("../src/minipage.typ"), scope: doc-scope)

#let pin-docs = tidy.parse-module(read("../src/pin.typ"), scope: doc-scope)
#let counter-docs = tidy.parse-module(read("../src/counter.typ"), scope: doc-scope)
#let ref-docs = tidy.parse-module(read("../src/reference.typ"), scope: doc-scope)
#let outline-docs = tidy.parse-module(read("../src/outline.typ"), scope: doc-scope)


#let layout-docs = tidy.parse-module(read("../src/layout.typ"), scope: doc-scope)
#let render-docs = tidy.parse-module(read("../src/render.typ"), scope: doc-scope)

#let extra-docs = tidy.parse-module(read("extra.typ"), scope: doc-scope)

== Setup & Configuration
#show-module(lib-docs, fn: "deixis-setup-notes")
#pagebreak()
#show-module(lib-docs, fn: "deixis-set")

== Common Mechanics
#show-module(extra-docs, fn: "deixis-common-note-args")
#pagebreak()

== Marks

=== Inline Mark
#show-module(inline-note-docs, fn: "deixis-inline-mark")
#pagebreak()

=== Phantom Mark
#show-module(inline-note-docs, fn: "deixis-phantom-mark")
#pagebreak()

=== Region Mark
#place(left, deixis-pin("region-mark-chapter-start"))
#show-module(region-note-docs, fn: "deixis-region-mark")
#place(right, deixis-pin("region-mark-chapter-end"))
#pagebreak()

== Notes

=== Inline Note
#show-module(inline-note-docs, fn: "deixis-inline-note-body")
#pagebreak()

=== Footnote
#show-module(footnote-docs, fn: "deixis-footnote-body")
#show-module(footnote-docs, fn: "deixis-footnote")
#pagebreak()

=== Endnote
#show-module(endnote-docs, fn: "deixis-endnote-body")
#show-module(endnote-docs, fn: "deixis-endnote")
#show-module(endnote-docs, fn: "deixis-print-endnotes")
#pagebreak()

=== Margin Note
#show-module(margin-note-docs, fn: "deixis-margin-note-body")
#show-module(margin-note-docs, fn: "deixis-margin-note")
#pagebreak()

=== Inset Note
#show-module(inset-note-docs, fn: "deixis-inset-note-body")
#show-module(inset-note-docs, fn: "deixis-inset-note")
#pagebreak()

== Renderers

=== Note Renderer
#show-module(render-docs, fn: "deixis-native-render-single")
#show-module(render-docs, fn: "deixis-default-render-single")

=== Group Renderer
#show-module(render-docs, fn: "deixis-native-render-group")
#show-module(render-docs, fn: "deixis-default-render-group")
#show-module(render-docs, fn: "deixis-grid-render-group")

=== Helpers

These helper functions can be useful for implementing a custom render function.

#show-module(render-docs, fn: "deixis-generate-backlinks")
#show-module(render-docs, fn: "deixis-generate-body-meta")
#show-module(render-docs, fn: "deixis-generate-body-marker")
#pagebreak()

== Minipage
#show-module(minipage-docs)
#pagebreak()

== Utilities
=== Pin
#show-module(pin-docs)
#pagebreak()

=== Counter
#show-module(counter-docs)
#pagebreak()

=== Cross-reference
#show-module(ref-docs)
#pagebreak()

=== Note Outline
#show-module(outline-docs)
#pagebreak()

=== Others
#show-module(lib-docs, fn: "deixis-page-notes")
#show-module(layout-docs, fn: "deixis-place-anchored")
#show-module(layout-docs, fn: "deixis-absolute-place")
#pagebreak()

= Limitations and Conclusion

== Known Issues

If you encounter any bug, please report at #link(repository).

This is just a non-exhaustive list of known limitations that might not have a fix.

- Page-level footnotes are currently dependent on `std.footnote` internally, limiting their customizability.
- Occasionally, if put inside a `std.measure`-ed container, foreground overlayed notes like footnotes and margin notes may have their mark $arrow.r$ body link broken, pointing to the beginning of the document when clicked. 
- Similarly, a relative-placed `#deixis-inset-note` inside a `std.measure`-ed container will have wrongly calculated body coordinates, resulting in a link connecting to the border of the page.
  ```demo
  #deixis-inset-note(
    stroke: red,
    fill: red.transparentize(95%),
    link: "straight-line",
    link-marks: "both",
    dx: 4em, dy: 3em,
  )[Note mark.][Note body.]
  ```

#error[
  We suspect both these issues stem from the underlying interaction between `std.measure` and content `std.label`.
]

== Conclusion

#conclusion[
  The whole package is experimental, a proof of concept.
  Do not expect much, as there are always limits to what a hacky Typst package can do.

  Plus, having a strong opinion on using native features whenever possible, I hope future Typst versions will provide a more powerful noting mechanism.
]
