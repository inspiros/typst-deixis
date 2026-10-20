# Review Comments And Final Builds

`deixis-comment` writes an editorial comment in the `"review"` series. Choose
whether to include that series at the start of the document:

```typst
#import "@preview/deixis:0.2.0": *
#set page(margin: (right: 45mm))
#show: deixis-setup-notes
#let final = sys.inputs.at("final", default: "false") == "true"
#deixis-set(omit: if final { (series: ("review",)) } else { none })

A #deixis-comment(author: "Ada", status: "open")[provisional claim][Check this wording.]
needs supporting evidence#deixis-footnote[A source retained in both builds.].
```

Compile normally for a draft; pass `--input final=true` to Typst for a final
copy. See the [editable example](../../examples/review-comments.typ).

A comment is a margin note with lettered markers, so its numbers stay apart from
source notes. `author` and `status` are stored in `note.data` (as `none` when
absent) and shown in bold above the comment; use `header: none` or a function of
the data to change that line. Other margin-note options pass through. Any
wrapper can carry comments instead: give it its own series, for example
`deixis-footnote(series: "todo")[...]`, and omit that series.

In the final copy, “provisional claim” remains ordinary text. Its decoration,
marker, body, and connections disappear. Omitted originals consume neither a
counter value nor a palette color. Their bodies do not run, including nested
annotations and contextual callbacks. Queries and note outlines exclude them.
Other annotations inside the *kept passage* remain independent and can still run.

## Shared Comments And Local Settings

Select omission where the original is created. Its attached body and every
reused mark follow that decision, including forward declarations and calls in
other scopes. Reused passages remain ordinary text; attached bodies disappear.
Standalone bodies use their own `series:`. Endnotes default to `"endnote"`;
other wrappers, marks, and standalone bodies default to `"default"`.

`deixis-set(omit: none)` includes all subsequent series. A `deixis-block` restores
its parent's policy when it ends; ordinary Typst brackets do not. `omit: auto`
leaves the policy unchanged. A series record replaces the previous record.

References (`@comment` or `deixis-ref(<comment>)`) to omitted IDs report an
omission error. Include the referenced series or conditionally remove those
references in the final build. Explicit connections touching an omitted
annotation disappear. Authored IDs remain unique even when omitted.

## Author And Status Index

Store static fields such as `author`, `status`, and `title` in the original's
`data` dictionary; `deixis-comment` fills `author` and `status` for you. The [review-index specimen](../examples/review-index.typ)
keeps all comments in the draft but shows only Ada's open comments in a custom
linked list:

```typst
#context {
  let pending = deixis-query-notes(series: "review")
    .filter(n => n.data.author == "Ada" and n.data.status == "open")
  for n in pending {
    block(link(n.dest)[#n.marker #n.data.title])
  }
}
```

These fields are document conventions; give every review original the same
fields, or use dictionary `at(..., default: ...)` for optional values. Filtering
the view leaves resolved comments in the document. To remove all review notes
in a final copy, omit the `"review"` series at creation as described above.

For all comments grouped by author, use `deixis-note-outline(series: "review",
group-by: n => n.data.author, summary: n => n.data.title)`. Arbitrary data
predicates belong in a query-based view; the built-in outline filters by
series/type/scope/range. See [annotation data](note-data.md).

## Omission And Reveals

This differs from [native hiding and Touying reveals](visibility.md): hidden
notes keep their identity, counter value, and layout footprint. Omission removes
the annotation while preserving the passage. Native outlines and `deixis-plain`
still replay only the passage; they do not create another annotation.

The same omission policy works inside a Touying slide setting. Use private
wrapper identities or the existing [frame-local identity recipe](touying-identities.md)
for shared named comments across repeated subslides.
