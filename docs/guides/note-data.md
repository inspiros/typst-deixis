# Annotation data

Use the optional `data: (...)` dictionary to describe an annotation for custom
views. Fields can be titles, tags, review status, or values specific to your
document. Deixis does not prescribe their names or types:

```typst
#deixis-endnote(id: <method>, data: (
  title: [Explain the method], tags: ("method", "review"), status: "open",
))[Why this method suits the problem.]

#deixis-mark(of: <method>)[Another use]
```

`deixis-query-notes()` returns the dictionary unchanged as `note.data`. The
[small review example](../../examples/note-data.typ) uses it for titles, a
filtered table, and usage counts. An annotation without custom data has `(:)`.

## Ownership and forward declarations

| Declaration | Where `data` belongs |
| --- | --- |
| Original `deixis-mark(id: ...)` or specialized mark | On that original declaration |
| A creating footnote/endnote/margin/inset/sidenote wrapper | On the wrapper, even without a public ID |
| A standalone `-body` call | On that body, with or without an ID |
| An attached `-body(of: ...)` or wrapper | Inherited from the original; omit `data` |
| A reused mark with `of:` | Shared annotation data is available on the parent query record; omit `data` |

All six original/body/reuse orders retain the same dictionary. Neither an early
attachment nor an early reuse reserves or overrides data. Nonempty `data` with
`of:` is diagnosed rather than merged; the default empty dictionary means
omission. Each annotation has one owner, independently of its body rendering
scope and counter series. To attach an explanation with data, declare it on the
original:

```typst
#deixis-endnote-body(of: <method>)[Why the method works.]
#deixis-mark(id: <method>, data: (title: "Method",))[The method]
```

Anonymous inline/region decoration can also carry data, visible with
`include-unpaired: "mark"`. An anonymous phantom call has no record; supplying
nonempty data to it requires an original `id`. There is no per-occurrence data
option or mutable metadata setter. Custom body renderers receive the same
dictionary under their existing record's `data` field; physical page-body records
also retain it.

## Titles, grouping, and filtering

Data has no automatic rendering or selection semantics. The default outline
continues to show safe static body excerpts. Choose a title explicitly:

```typst
#deixis-note-outline(
  summary: note => note.data.at("title", default: note.summary),
)
```

For status headings, use `group-by: note => note.data.at("status", default:
"Unsorted")`. A group callback must return a string. Filter tags/status or sort
custom fields with ordinary array operations:

```typst
#context {
  let pending = deixis-query-notes().filter(note =>
    note.data.at("status", default: none) == "open")
  for note in pending {
    [#link(note.dest, note.data.at("title", default: note.summary)) #linebreak()]
  }
}
```

IDs, counts, locations, marks, body descriptors, and styles remain runtime fields.
Custom names stay nested: `data: (id: "my value",)` changes `note.data.id` and
cannot change `note.id`. Deixis never merges custom fields into its records or
style cascade, so there is no list of reserved custom keys.

Data is opaque. Queries, default outlines, registration discovery, and static
summary extraction never traverse it or invoke its callbacks. A title containing
`context`, state updates, or other executable content runs only when a caller
explicitly renders that value. Rendering a custom title in several views can
therefore execute it several times; use static titles for reusable presentation.
Safe body/passage summaries remain separate from this explicit user payload.
