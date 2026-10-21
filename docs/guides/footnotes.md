# Footnotes And Long Bodies

Examples use the [standard import and setup](getting-started.md#1-start-with-native-footnotes).
Excerpts with existing IDs or callback variables extend the surrounding example.

`deixis-footnote` places its body in the native page footer, just like
`std.footnote`. Typst allocates and splits the live content; Deixis supplies
the annotation identity, marker, styling and return links. Ordinary native
footnotes keep their own numbering. See [Long Footnotes](../../examples/long-footnote.typ).

```typst
#show: deixis-setup-notes
A passage#deixis-footnote[A long explanation.] continues here.
```

Paragraphs, one long paragraph, lists, breakable tables (including repeating
headers), columns and custom renderers can all paginate. A custom renderer must
return breakable content and retain the [live body hooks](custom-renderers.md)
if it needs continuation queries or navigation. `deixis-query-notes(page:
here().page())` includes the footnote on every page in its complete live span.

## Per-Page Markers

Use `deixis-footnote.with(numbering: (restart: "page", pattern: "1"))` to restart
printed markers on each original mark's physical page. `pattern: "*"` uses
symbols. Assigned counts and note identities stay stable; shared notes and split
bodies retain the original marker. See [counters](counters.md#restart-footnote-markers-on-each-page)
for series, scopes, manual updates and convergence limits.

## Native Footer Appearance

Page footnote bodies use the footer's typography, as native entries do. A
footnote declared in a heading, in bold text or in a large passage still
prints as an ordinary footnote. The separator, clearance and gap between entries
belong to the native footer; configure them once, at document level:

```typst
#set footnote.entry(separator: line(length: 40%, stroke: 0.5pt + gray), gap: 0.6em)
```

`deixis-set` controls the marker, body style, indentation, colors and container
of each note. Its `separator`, `clearance` and `gap` options apply to local block
collections and endnote printers, which Deixis lays out itself.

## Overlay Footnotes

Choose `layer: "foreground"` or `"background"` when a short footnote should be
painted rather than placed in flow, for example to group series with aligned
markers. Overlays reserve space for a **complete** body and paint it into that
reservation. They do not split; an oversized overlay footnote receives a
diagnostic directing you to flow. When a reservation no longer fits on its page,
the whole entry moves to the next page together with its marker line.

`deixis-setup-notes.with(override-page-footnotes: true)` makes the foreground
overlay the default for footnotes that do not choose a layer.

## Whitespace And Paragraphs

An ordinary inline footnote call keeps the surrounding paragraph. Its marker
attaches to the preceding word even if the call starts on the next source line;
the following space is preserved. A blank paragraph before the call starts a
new paragraph, as with native `std.footnote`.

```typst
This is not#deixis-footnote[Attached to “not”.] a long
#deixis-footnote[Attached to “long”.]
sentence.

#deixis-footnote[A new paragraph was explicitly requested.]
```

Body whitespace also follows native layout. These first two bodies start on the
marker's line; the third deliberately starts a new paragraph:

```typst
#deixis-footnote[No line break.]
#deixis-footnote[
  Also no line break.
]
#deixis-footnote[

  An explicit paragraph break.
]
```

The built-in single-note renderers use weak marker spacing. They do not
recursively trim or rewrite the supplied body, so styled and contextual content
works too. An explicit `linebreak()` or `parbreak()` is preserved. Custom
renderers decide their own whitespace policy.

A separate, isolated **body-only** declaration still needs a native inline
allocation marker and can create an empty paragraph. Immediate margin/inset
placement and non-inline flow region marks also keep native `place`'s paragraph
footprint. Overlay declarations add no flow space and diagnose lost native
allocations at unsupported footnote boundaries. See [rendering](rendering.md#footnote-ownership).

## Containers Must Be Breakable

The `"rect"`, `"alert"`, `"stripe"` and `"tinted"` containers use native `rect`
and keep the entire body together. A body taller than a page can overflow and
be clipped **without a warning**, just as with `std.footnote(rect[...])`.
Use a breakable native block for a long bordered note:

```typst
#deixis-footnote(
  container-func: block,
  container-args: (breakable: true, inset: 5pt),
  stroke: (body: teal),
)[A long explanation.]
```

An unbreakable image, box or table row inside an otherwise breakable body still
has to fit. On very short pages, native Typst can also place the beginning of a
long footnote before the page containing its source paragraph. Deixis follows
that allocation; it does not promise that the whole note, or its first fragment,
shares the marker's page.

## Headings, Outlines And Running Headers

A footnote in a heading or figure caption is counted once. Native outlines show
the heading or caption text without its notes. A running header that repeats a
heading body should do the same with [`deixis-plain`](outlines.md#repeated-headings).

## Page And Local Ownership

Inside `deixis-block` / `deixis-minipage`, footnotes normally collect **after the
whole block**, even when the block spans pages. That collection can split, and
all valid layer requests resolve to flow. Use `target: "page"` to request an
actual page-footer entry instead. See [breakable blocks](blocks.md) and [table/figure notes](local-notes.md).

Native parent-scope floats cannot allocate page footnotes in Typst 0.15. Keep
the mark in the float and declare the body in main flow, or choose a local
collection/endnote. Ordinary column-scope floats support native allocation.
The [figure example](../../examples/figure-footnote.typ) shows both cases.
