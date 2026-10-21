#import "manual-style.typ": *
#let manifest = toml("../typst.toml")
#let version = manifest.package.version
#show: manual.with(version: version, paper: sys.inputs.at("paper", default: "a4"),
  monochrome: sys.inputs.at("monochrome", default: "false") == "true")
#set document(title: "Deixis Manual", author: manifest.package.authors)

#align(left)[
  #v(1fr)
  #image("../assets/logos/deixis-logo-horizontal.svg", width: 260pt)
  #v(1.4em)
  #text(font: "DejaVu Sans", size: 31pt, weight: "bold", fill: accent)[The Deixis Manual]
  #v(0.5em)
  #text(size: 17pt)[Notes, Highlights, And Connections]
  #v(1em)
  Mark a passage. Share its explanation. Draw the relationship.
  #v(1fr)
  #line(length: 100%, stroke: 0.6pt + accent)
  #v(0.5em)
  #badge("DEVELOPMENT " + version) #badge("TYPST 0.15.0+")
  #v(0.7em)
  A visual guide with worked examples and a compact API reference.\
  Detailed recipes and complete record contracts live in `docs/guides`.
]
#pagebreak()
#outline(depth: 1)
#pagebreak()

#include "manual-introduction.typ"
#include "manual-examples.typ"
#include "manual-reference.typ"

#pagebreak()
= Integration Checklist

- Configure native page layers before setup; reapply setup after replacing them.
  Host-owned overlays still need initialization. Changing dimensions/margins alone
  does not need another setup call.
- Use flow for long footnotes. Overlays cannot create pages. Immediate margin
  placement has no collision packing and native placement may disturb paragraphs.
- A body declaration controls formatting and adapter-specific allocation, even
  with forward identity lookup. Collected bodies must be printed to be endpoints.
- Multi-page region highlights need overlays. Arbitrary native columns/fragments
  are not automatically discovered. Deep deferred contexts have a finite native
  layout-pass budget; do not replace missing geometry with guessed bounds.
- In custom renderers, emit destination/marker once and live body content once.
  Query summaries are safe; replaying raw executable body content is not.
- For Touying, use the frame identity/reveal recipes. For migration from 0.1.1,
  read `docs/guides/compatibility.md`.

Read the task-oriented index in `docs/README.md`. Source examples live in
`examples/` and `docs/examples/`; the worked pairs name their editable sources.
This checkout is unreleased: install its 0.2.0 preview override to compile the
examples. Build this source with `python3 scripts/render-manual.py`.

Bug reports and source: #link(manifest.package.repository).
