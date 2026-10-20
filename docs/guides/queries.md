# Selecting and querying notes

Start with the view that matches the task:

| Function | What it selects | Default scope and order |
| --- | --- | --- |
| `deixis-print-endnotes` | Endnote body declarations eligible for printing | Current rendering scope; first-seen series order, then body declaration order within each series |
| `deixis-note-outline` | One entry per original annotation, plus optional unpaired marks/bodies | Whole document; original mark order, or body declaration order for a standalone body |
| `deixis-query-notes` | Safe annotation records, including all original/reused marks and an optional body description | Source-ordered catalogue, or native body order for an explicit physical page |

Reused marks and references do not create extra collection or query entries.
An outline can include an unprinted body. A page query includes only live rendered
spans, including continuation pages. These operations read metadata without
executing note bodies again.
Semantic queries retain reused marks inside each annotation's `marks` array.
See [outlines and custom views](outlines.md) for the record schema and a passage
index with one row per mark. The default outline links to all distinct marked
pages, while keeping one entry per annotation.

## One Query For Catalogues And Page Headers

Call `deixis-query-notes` in context after setup. Without `page:`, it preserves the
catalogue defaults: paired annotations in original source order, including
unprinted explanations. A physical-page selection instead includes standalone
bodies and follows their native rendered order:

```typst
#context {
  let notes = deixis-query-notes(
    page: here().page(), include-types: "endnote")
  notes.map(n => if n.marker == none { [unnumbered] } else { n.marker }).join([, ])
}
```

Use it in a header to follow the printed collection. The
[small query example](../../examples/note-queries.typ) reports `8, 1, unnumbered`
after a counter reset. Continuations remain before bodies starting later. Native
body order does not promise sorting by visual coordinates or z-order.

| Call | Selection And Order |
| --- | --- |
| `deixis-query-notes()` | Paired annotation catalogue, source order, including unprinted declarations |
| `deixis-query-notes(page: here().page())` | Bodies on the current physical page, including standalone bodies, native body order |
| `deixis-query-notes(page: 3, series: "editor")` | Printed bodies on physical page three in that series |
| `deixis-query-notes(page: 3, order: "source")` | Same page selection, ordered by original declarations |
| `deixis-query-notes(order: "body", include-unpaired: true)` | Catalogue in live body-start order; missing/ambiguous starts last in source order |

`order: auto` chooses body order for page selections and source order otherwise.
`include-unpaired: auto` includes standalone bodies for page selections and only
paired annotations otherwise. Explicit `order: "source"` / `"body"` and
`include-unpaired: false` / `true` / `"mark"` / `"body"` override those defaults.
The same stable record schema is returned in every mode: `marker`, `type`, safe
summaries, author data, all shared `marks`, and optional body location metadata.
Queries never return executable body content or raw renderer records.

### Physical Pages And Accepted Spans

`page:` accepts a positive physical page integer; `auto` does not filter. Counter
resets or Roman/letter numbering do not change physical page selection. Unknown
pages select nothing; zero, negative, fractional and non-integer values fail.

Page selection requires one complete, unique live body span and includes its
continuation pages. Metadata-only, unprinted or incomplete/duplicated/reversed custom
spans cannot match. Such annotations remain available in the unfiltered catalogue,
with absent `body.start`/`body.end`. An annotation's full `marks` array remains
intact even when those passages are elsewhere. Type/series/scope/source-boundary
filters still intersect with page selection.

`body.order` is the body declaration's source ordinal. `body.render-order` is its
unique live start's native ordinal, or `none` when missing/ambiguous. These are
transient sorting values, not IDs. No body position is guessed from a marker or
an arbitrary detached metadata element. Use `deixis-generate-body-content` in
custom renderers to publish the real span.

### Adaptive Source-Page Headers

The [worked adaptive header](../examples/adaptive-header.typ) gathers original
and reused mark pages for the explanations printed on the current physical page,
without private-label lookup or body replay. For traditional original-only
headings, filter `note.marks` with `mark => mark.original`.

The illustrated header uses physical source page numbers. For a linked native
page label, standard Typst provides:

```typst
#let page-link(dest) = link(dest, numbering(
  if dest.page-numbering() == none { "1" } else { dest.page-numbering() },
  ..counter(page).at(dest),
))
```

Apply it in context to mark/body destinations. Deduplicate by `dest.page()`, not
formatted text: different physical pages can share a label after a reset.
<!-- Future API discussion: [helper review](../maintainers/user-helpers.md). -->

## Type And Series Filters

`include-types`, `exclude-types` and `series` accept strings or arrays of literal
strings. `auto`, where supported, means unrestricted. An empty inclusion selects
nothing; an empty exclusion excludes nothing. Duplicates never repeat entries.
Unknown names select nothing; invalid scalar/mixed-array values fail.

```typst
#deixis-print-endnotes(series: ("editor", "translation"))
#deixis-note-outline(include-types: "endnote", exclude-types: ())
#context deixis-query-notes(page: here().page(),
  include-types: ("footnote", "endnote"))
```

Canonical body types are `inline-note`, `footnote`, `endnote`, `margin-note`, and
`inset-note`; sidenotes use `margin-note`. Unpaired marks have `inline-mark`,
`region-mark`, or `phantom-mark` types. Include them in a catalogue with
`include-unpaired: "mark"` or `true`; a body-page filter naturally excludes marks
without a body.

## Source boundaries

Printer and outline `after:`/`before:` bounds are exclusive native source-order
boundaries, including within one line:

- A native location is used directly. A label or native selector uses its first
  matching document element.
- A string selects the first global pin with that literal name.
- A pin record selects a name, scope, occurrence, and optional physical page.
  It must select one occurrence. To use a label-valued pin name, write
  `(name: <anchor>)`; bare `<anchor>` retains its native-label meaning.
- Both kinds of boundary require a match and allow forward declarations.

The interval is exclusive at both ends. Equal bounds or a `before` boundary
earlier than `after` select nothing. An empty printer claims no bodies, so a later
printer can still emit them. Empty outline/query selections do not invoke entry,
grouping, or summary callbacks. Unsupported scalar/array boundary types receive a
collection-boundary diagnostic before native querying; a native function boundary
must be an element function accepted by Typst's selector system.

For example:

```typst
#deixis-print-endnotes(
  after: (name: <start>, scope: <chapter>),
  before: (name: <end>, scope: <chapter>),
)
```

A printer bounds **body declarations**. An outline bounds **original marks**, or
body declarations for standalone bodies. Moving an attached body across a bound
can therefore change printer selection without changing outline selection. Reuse
inside an interval does not move an original into it.

Without `before:`, a printer selects declarations preceding its own call; an
outline has no upper boundary. An explicit future `before:` can include bodies
declared after the printer. The first eligible printer owns each body; overlapping
or repeated printers do not print it again. An empty filter claims nothing.

## Rendering scope and counter ownership

Printers default to the calling rendering scope. An outline defaults to all
scopes; `target: 0` restricts it to the calling rendering scope. A named block
in a thread selects that thread's rendering domain.
Block names and thread filters accept equivalent nonempty strings/labels.
An unknown target/thread filter selects no entries for queries and outlines;
an endnote printer instead requires its named target to exist. To target a
thread in a printer, select a named member block. See [scopes](scopes.md).

An outline's `target:` and `thread:` filters combine: both must match when both
are supplied. For a paired note, these filters use its body's rendering scope;
for an unpaired mark, they use the original's scope. A body target override can
change its scope selection while leaving the original's source position, counter
owner, series, and number intact. Synchronizing counters also keeps rendering
scopes independent. See [body ownership](ownership.md).

## Unreleased 0.2 Changes

`deixis-page-notes` has been removed. Use
`deixis-query-notes(page: here().page())`; `note-type:` becomes `include-types:`,
`marker-str` becomes `marker`, and `body-type` becomes `type`. Series filtering
stays `series:`. Page queries include standalone bodies by default and preserve
native body order through resets and continuations. Use `order: "source"` for
original declaration order.

Every query now returns the safe semantic schema. Live custom renderers already
receive their renderer record directly; do not replay query results as body
content. The former incomplete/duplicate-span fallbacks and detached synthetic
span records are intentionally not retained. Use the content helper to provide a
complete registered annotation span instead of relying on guessed page coverage.

Outlines also no longer ignore `target:` when `thread:` is supplied: both filters
must match. Invalid type/series filters fail instead of silently selecting all or
no notes. Outline type filters support the single-string shorthand.
