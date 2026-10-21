# References And Backlinks

The usual entry point is a public annotation ID and Typst's `@id` syntax:

<!-- deixis-example: {"id": "example-1"} -->
```typst
#show: deixis-setup-notes
Text#deixis-endnote(id: <claim>)[The explanation.]
See @claim.
#deixis-print-endnotes()
```

`deixis-ref(<claim>)` provides the same reference with optional formatting.
The [small reference example](../../examples/references.typ) shows ordinary
references, a numeric range, and return links.

## Identity And Destinations

An explicit `id:` declares the annotation. A separate body attaches with `of:`.
The same identity names the painted body for native links and queries:

<!-- deixis-example: {"id": "example-2"} -->
```typst
#deixis-inline-mark(id: <claim>)[A claim]
#deixis-endnote-body(of: <claim>)[The explanation.]
See @claim or #link(<claim>)[the explanation].
#deixis-print-endnotes()
```

Both forms select the painted body. If its body has not been printed,
a reference to a registered mark selects the mark instead. A standalone body
has no numbered mark: its reference displays `?`, configurable with
`celibate-marker`. It becomes clickable when the body is actually rendered.
An unprinted standalone body has no link destination.

Internal mark/body labels still select their specific component, but ordinary
code should use public IDs. Several targets selecting the same note
in one `deixis-ref` call display that note once. Non-Deixis targets retain native
Typst reference behavior; arbitrary labelled metadata is not treated as a note.

## Lists And Ranges

These calls assume originals named `<first>`, `<second>` and `<third>`:

<!-- deixis-example: {"id": "example-3", "prelude": "#deixis-endnote(id: <first>)[Evidence for first.]\n#deixis-endnote(id: <second>)[Evidence for second.]\n#deixis-endnote(id: <third>)[Evidence for third.]\n#deixis-endnote(id: <claim>)[Evidence for claim.]\n#deixis-print-endnotes()"} -->
```typst
#deixis-ref(<first>, <second>, <third>)[Notes]
#deixis-ref(<first>, supplement: [Comment], marker-style: it => strong(it))
```

A list of ordinary automatic decimal markers is sorted and runs of three or more become
ranges only when every target shares its counter owner, series, numbering rule,
and marker style. Synchronized scopes can therefore share a range. Independent
scopes, mixed series/styles, literal markers, and nonnumeric markers retain the
caller's order and display each distinct note separately. A range links its two
visible endpoints; all targets still register that reference site for backlinks.

[Page-local display markers](counters.md#restart-footnote-markers-on-each-page)
retain the input order and individual links, even when different originals
share a displayed value. They are not compressed into ranges.

References inherit the mark's style as configured when the mark was declared,
including scoped settings. An explicit `marker-style` on the reference overrides
it. Mixed-style lists use plain separators. Empty calls, including a lone trailing
supplement, produce no output.

## Page References And Show Rules

Typst's native page form selects the same painted body, with a fallback to the
mark when the body has not been printed:

<!-- deixis-example: {"id": "example-4", "postlude": "#deixis-endnote(id: <first>)[Evidence for first.]\n#deixis-endnote(id: <second>)[Evidence for second.]\n#deixis-endnote(id: <third>)[Evidence for third.]\n#deixis-endnote(id: <claim>)[Evidence for claim.]\n#deixis-print-endnotes()"} -->
```typst
#set page(numbering: "1")
#ref(<claim>, form: "page")
#deixis-ref(<first>, <second>, form: "page", supplement: [Pages])
```

Page references use the destination page's numbering and native localized
supplement, including after page-counter resets or changes to `page.numbering`.
As with native page references, the destination page needs enabled numbering.
Lists retain caller order and deduplicate annotations; their supplement appears
once. An unprinted standalone body has no page destination and displays the
`celibate-marker` instead.

A functional supplement receives the selected note's metadata element; its
`value` contains the note record. A painted destination also has a native
`location()`. An unprinted standalone note supplies unlocated metadata. The same
callback can be supplied through `set ref(supplement: ...)` for `@label` calls.
An empty result omits the prefix and its joining space:

<!-- deixis-example: {"id": "example-5", "prelude": "#deixis-endnote(id: <first>)[Evidence for first.]\n#deixis-endnote(id: <second>)[Evidence for second.]\n#deixis-endnote(id: <third>)[Evidence for third.]\n#deixis-endnote(id: <claim>)[Evidence for claim.]\n#deixis-print-endnotes()"} -->
```typst
#deixis-ref(<claim>, supplement: element => [Note])
```

Non-Deixis headings, figures, equations, footnotes, and bibliography references
keep their native behavior and existing show rules. A later show rule can wrap
the original reference to decorate both native and Deixis output:

```typst fragment
#show: deixis-setup-notes
#show ref: it => text(fill: blue, it)
```

Returning replacement text from a later rule replaces that reference, as in
ordinary Typst. Keep `it` in a decorating rule when the note bridge should still
format and link it.

## Return Links

`backlink` controls the extra return-link hooks after a body:

| Value | Behavior |
| --- | --- |
| `false`, `"none"`, `"never"` | No hooks |
| `true`, `"always"` | Links to every available origin |
| `"multiple"` | Hooks only when there are at least two origins |

An origin is the original mark or a distinct `deixis-ref` / `@label` call.
Each `deixis-mark(of: ...)` call is also an origin; see [shared notes](shared-notes.md)
for multiple annotated passages using one body.
Repeated targets in one call count as one origin for that
note. Standalone bodies can link back to their references too; with `"multiple"`,
they need at least two reference calls. The body's numbered marker continues to
link to its mark independently of the extra-hook policy.

Custom renderers should emit `deixis-generate-body-marker(data)` or
`deixis-generate-body-meta(data)` once at the real painted body. These helpers
publish its destination; `disable-links: true` suppresses it during measurement.
Use one of them once; duplicate destinations on an annotation receive a diagnostic.
`deixis-generate-body-content(data)` separately supplies live start/end locations.
Without a destination helper, package references fall back to the original mark;
a standalone reference remains unlinked. Raw native body links require a published
label. See [custom renderers](custom-renderers.md) for partial-output behavior.
`deixis-generate-backlinks(data)` can provide the return-link content.
