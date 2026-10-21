# Outlines And Custom Note Views

An annotation has one original mark, any number of reused marks, and at most one
body. An outline keeps **one entry per annotation**. Reuse contributes locations
to that entry instead of duplicating its explanation.

For a ready-made list:

<!-- deixis-example: {"id": "example-1", "prelude": "#deixis-endnote(id: <claim>)[The supporting evidence.]\n#deixis-mark(of: <claim>)[A related claim]\n#deixis-print-endnotes()\n"} -->
```typst
#deixis-note-outline()
```

Each entry shows its marker, a static excerpt, and linked mark destinations. The page
list includes original and reused marks, in mark source order, deduplicated by
physical page. Its links use painted return destinations where available,
including wrapped named inline marks and regions anchored elsewhere. Page labels
use the destination's native numbering and page counter, including resets,
Roman/letter patterns, and functions supported by native page references.
For a region spanning several pages, its return destination is the first painted
frame; continuation pages are not separate uses. These links describe navigation
points rather than complete highlighted glyph ranges.

The badge and excerpt link to the original mark. Each page link has its own mark
destination. A standalone body links to its printed destination, or its
declaration when still unprinted. Bodies shared by many marks keep the original
marker, one outline entry and one live execution.

## Repeated Headings

Native outlines repeat heading and figure-caption content. Annotations inside
that content are not created again there: the table of contents shows the
marked passage without its marker, note body or connector, and numbering
continues once in the document.

Other places that repeat a heading body, such as a running header, should use
`deixis-plain`. It shows the passages and leaves the annotations where they were
declared:

<!-- deixis-example: {"id": "example-2", "height": "180pt", "postlude": "= A Heading With A #deixis-inline-mark(id: <term>)[Marked Term]\n#deixis-endnote-body(of: <term>)[An explanation.]\n#deixis-print-endnotes()\n#pagebreak()\nThe running header repeats the plain heading."} -->
```typst
#set page(header: context {
  let previous = query(selector(heading).before(here()))
  if previous.len() > 0 { emph(deixis-plain(previous.last().body)) }
})
```

PDF bookmarks are plain text extracted by Typst. A marked passage inside a
heading is drawn by deferred layout, so its words can be missing from the
bookmark title; keep important bookmark text outside the mark.

## Inclusion, Selection, And Grouping

Paired annotations are included by default, even before an endnote is printed.
Use `include-unpaired` to add marks without bodies or standalone bodies:

<!-- deixis-example: {"id": "example-3", "prelude": "#deixis-endnote(id: <claim>)[The supporting evidence.]\n#deixis-mark(of: <claim>)[A related claim]\n#deixis-print-endnotes()\n"} -->
```typst
#deixis-note-outline(include-unpaired: true)
#deixis-note-outline(include-unpaired: "mark", group-by: "type")
#deixis-note-outline(include-unpaired: "body", group-by: "series")
```

`false` selects paired notes only; `true` adds both unpaired kinds. `"mark"` and
`"body"` add that kind alongside paired notes. There are no array/plural aliases.

`group-by` accepts `none`, `"type"`, `"series"`, or a callback returning a string.
Groups retain first-seen order; entries retain source order within each group.
For example, `group-by: note => str(note.marks.len())` groups by mark count.
Unsupported values and non-string callback results receive diagnostics.

Type/series filters, rendering scope, and exclusive `after`/`before` bounds follow
the [selection guide](queries.md). Bounds still select the original mark, or a
standalone body's declaration. An earlier reuse does not move its original into
a range. A selected annotation retains **all** its marks, including those outside
the range. Reference calls such as `@idea` are not marked passages and do not
become entries in `marks`.

## Structured Records For Other Layouts

`deixis-query-notes` returns the same semantic records without drawing an outline.
Its default catalogue is source-ordered; explicit page queries default to body
order and include standalone bodies. Use `order: "source"` to override.
Call it in a native `context`, after setup. It accepts the outline's selection
options and optional `page:` filtering over complete live body spans; presentation options such as `title` and `group-by` belong to the view.

<!-- deixis-example: {"id": "example-4", "prelude": "#deixis-endnote(id: <claim>)[The supporting evidence.]\n#deixis-mark(of: <claim>)[A related claim]\n#deixis-print-endnotes()\n"} -->
```typst
#context {
  let notes = deixis-query-notes(include-types: "endnote")
  table(columns: (auto, 1fr, auto),
    table.header([Note], [Explanation], [Uses]),
    ..notes.map(note => (note.marker, note.summary, str(note.marks.len()))).flatten(),
  )
}
```

See the [small catalogue example](../../examples/note-catalogue.typ). These records
can also drive cards, usage counts, body-location lists, or separate source/body
navigation. They contain static summaries and locations; queries do not execute
or return executable note bodies or marked passages.
The separate author-supplied `data` dictionary is opaque and returned unchanged;
explicit rendering of its values belongs to the caller. See
[annotation data](note-data.md).

| Record field | Meaning |
| --- | --- |
| `id` | Public string/label identity, or `none` for anonymous annotations |
| `data` | Original/standalone-owned custom dictionary, unchanged and opaque; defaults to `(:)` |
| `type`, `series` | Body type when present, otherwise original mark type; literal series |
| `count`, `marker` | Assigned number and resolved marker content; either can be `none`. A phantom can have a count without a visible marker |
| `summary` | Safe static excerpt, preferring the explanation, otherwise the original passage; opaque content gets a placeholder |
| `styles` | Resolved body styles, or mark styles for an unpaired mark |
| `loc`, `order` | Original source location/order, or standalone body declaration. Order is a transient sorting ordinal, not an identity |
| `dest` | Original return destination, or standalone body destination/declaration fallback |
| `marks` | All original/reused marks in source order; empty for standalone bodies |
| `body` | Body description below, or `none` for an unpaired mark |

With [page-local display numbering](counters.md#restart-footnote-markers-on-each-page),
`count` remains the assigned counter value and can differ from the printed
ordinal. Render `marker` when reproducing the annotation's label; do not format
`count` as a substitute. The default outline already uses the original marker.

Each mark has `loc`, `dest`, `order`, `type`, `original`, `occurrence`, and
`summary`. `loc` is the source record; `dest` is its painted return point when
available, otherwise the source location. `original` identifies the original
declaration (the counter owner when numbered), even if a forward reuse comes first.
`occurrence` is a normalized name or
`none`. Pin-based regions can have a destination on another page and no static
passage summary. A return point is not a fragment rectangle or complete glyph
range.

The body description has `loc`, `order`, `render-order`, `dest`, `start`, `end`, and `summary`.
`render-order` is its unique live start ordinal, or `none` without an unambiguous
start. It is distinct from the declaration ordinal and is never an identity.
`loc`/`order` select its declaration, independently of original source order;
`dest` is `none` until a destination is painted. A complete unique
live span supplies `start`/`end`, including paginated bodies. Incomplete or
duplicate custom spans leave those fields `none`. These locations describe live
content boundaries, independently of the original's counter or source position.
A custom renderer can supply a span without a destination, or a destination
without a span. `deixis-generate-body-content` publishes the span; the existing
body-meta/marker helpers publish the destination. See
[custom renderers](custom-renderers.md) for navigation and declaration fallbacks.

## One Row Per Marked Passage

Flatten the marks and sort their source ordinals. This interleaves annotations
correctly when their uses alternate, including reuse before the original:

<!-- deixis-example: {"id": "example-5", "prelude": "#deixis-endnote(id: <claim>)[The supporting evidence.]\n#deixis-mark(of: <claim>)[A related claim]\n#deixis-print-endnotes()\n"} -->
```typst
#context {
  let uses = deixis-query-notes().map(note =>
    note.marks.map(mark => (note: note, mark: mark))).flatten().sorted(key: use => use.mark.order)
  for use in uses {
    [#link(use.mark.dest, use.note.marker) #use.mark.summary #linebreak()]
  }
}
```

See the [editable passage index](../../examples/occurrence-index.typ). Each use
has its own destination and safe passage excerpt, while the explanation and
assigned number stay on the annotation. To restrict an occurrence index by
location, select its marks explicitly; note-level range filters select originals.

## Custom Excerpts And Migration

`summary: note => [A description.]` customizes the default outline excerpt. It
receives a query record plus the presentation's `badge`; use `note.summary` to
keep the safe default. A callback can describe an otherwise opaque contextual
body by its ID. For titles or tags supplied alongside creation, use
[annotation data](note-data.md); for example, `summary: note =>
note.data.at("title", default: note.summary)`. Data has no implicit effect on the
default excerpt. See also [safe summaries](../../examples/note-summaries.typ).

In 0.2:

- `include-celibates` is replaced by `include-unpaired`, with a focused migration
  diagnostic. Replace `"both"`/`"none"` with `true`/`false`; plural/array aliases
  are removed.
- Callback `note.body` is now a body **description**, not executable content.
  Use `note.summary` or `note.body.summary` for an excerpt, and `note.body.dest`
  for a printed body link. Public identity is `note.id`.
- The default page list includes all marked pages and uses native page labels.
  The original is still selected by `note.marks.find(mark => mark.original)`.
- The former `deixis-page-notes` is consolidated into `deixis-query-notes`.
  Page headers and custom catalogues share safe records; live renderer callbacks
  still receive their own complete renderer data. See [query migration](queries.md#02-changes).
