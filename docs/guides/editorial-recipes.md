# Editorial Apparatus And Glossaries

Examples use the [standard import and setup](getting-started.md#1-start-with-native-footnotes).
Excerpts with existing IDs or callback variables extend the surrounding example.

Use `series` for independent numbering and collections, and `data` for the fields
your document needs. These recipes use the existing note and query APIs.

## Critical Apparatus

Keep source variants and editorial explanations in separate series. A shared
reading has one original ID and body; reuse its mark at the next passage with
`of:`. Each series starts at one independently, even when their declarations
alternate. Printing one series does not print the other.

The [apparatus specimen](../examples/editorial-apparatus.typ) uses lettered source
readings and numbered editorial notes. Its custom single-note renderer adds the
lemma from `data` before the explanation:

```typst
#let apparatus(n, ..args) = block[
  #deixis-generate-body-marker(n)
  #emph(n.data.lemma)#h(0.3em)
  #deixis-generate-body-content(n)
]
#deixis-print-endnotes(series: "sources",
  render-group: deixis-native-render-group)
```

Configure `render-single: apparatus` on the source notes. The native group
renderer delegates to each note's single renderer. Keep one marker helper and
one content helper per live body so destinations and spans remain available.
This is an annotation apparatus; it does not automatically collate manuscripts
or assign line numbers. See [custom renderers](custom-renderers.md).

## Glossary And First Use

Declare the original at the intended first use, with a stable ID and
`data: (term: "Lemma",)`. `marker: none` leaves the first-use text undecorated by
a number; bold or italic emphasis is an ordinary author choice. Attach a
definition with `deixis-endnote-body(of: <lemma>)`.

The [glossary specimen](../examples/glossary.typ) sorts query records by term and
shows their safe summaries. It deliberately does not call the endnote printer:
the catalogue is the only displayed definition list. Each term links back to its
first use. Later links use that query record's `dest`, which remains the original
return destination even if you later print the endnotes. A raw `link(<lemma>)`
requires a printed native destination; an unprinted endnote has none.

Use `deixis-mark(of: <lemma>, marker: none)[lemma]` when a later use should also
be counted in `note.marks`; use an ordinary link when navigation alone suffices.
Declaration order chooses the first use. The recipe does not discover terms or
choose a first occurrence automatically. Keep glossary data and definition text
static, since a query summary does not execute contextual definitions.

For a built-in catalogue, use `deixis-note-outline(series: "glossary",
summary: n => n.data.term)`. For a list filtered by author/status, see
[review comments](review-comments.md#author-and-status-index).
