# Notes in breakable blocks

`deixis-block` gives notes a local rendering scope and, by default, independent
counters. `deixis-minipage` uses the same engine, mapping `margin:` to internal
`inset:` padding and fixing `outset: 0pt`, as in 0.1.1. A block can span physical pages;
its notes do not need to be restricted to one page.

See [scope names and targets](scopes.md) for unique string/label block names,
shared threads, relative targets, and forward synchronization.
Blocks can also give a note body local numbering; see
[scopes inside notes](deferred-scopes.md) for supported inline explanations and
the additional native-pass boundary for nested footnote collections.

The [small two-page example](../../examples/breakable-block.typ) shows margin
notes beside their passages and footnotes collected after the block's content.

| Component | Behavior across pages |
| --- | --- |
| Foreground/background margin body | Uses the block's left/right inset on each page. Exact placement follows its mark; adaptive/flow packing can move it into an existing later fragment |
| Immediate `layer: "flow"` margin body | Stays on its declaration page, with exact placement and native placement limitations |
| Block footnote | Collects after all main content of its owning block. The collection, including a single long body, can continue onto later pages |
| Footnote explicitly targeting `"page"` | Uses a native page-footer reservation at the body declaration, with the ordinary page-footnote layer rules |

## Tables And Figures

Use the block as the local note owner around a complete nonfloating figure,
including its caption. For a float, put that whole block inside native
`place(..., float: true)` so the figure and collection move together. Long
tables use one breakable owner and one collection after all table fragments;
repeated headers reuse marks rather than declaring notes again. See
[table and figure notes](local-notes.md) and the
[editable example](../../examples/local-notes.typ).

## Margin notes

Reserve enough horizontal inset for the note width and its offset. Both overlay
layers use the same frame geometry. Continuation frames repeat the block's and
ancestors' vertical insets; horizontal offsets follow duplex page margins.

`layer: "flow"` and `margin-layout: "flow"` have different purposes:

- `layer` chooses immediate placement or a page overlay.
- `margin-layout` chooses how an overlay packs its margin bodies. `"exact"`
  preserves alignment and permits overlap; `"adaptive"` and `"flow"` pack notes
  and can spill into existing later frames. `spillover: false` keeps a body in its
  initial frame, subject to terminal overflow.

A `thread` makes later blocks available to margin spillover and shares numbering
by default. The original mark still owns the initial block instance; another
block in the thread does not relocate its note merely by sharing a page/top.
Overlay painting cannot create another page. If there is no available frame, a
final body can extend beyond its frame. Immediate margins do not participate in
collision packing or checks against overlay layers.

## Footnotes belong to the whole block

A block footnote is an end collection for that block, even when its mark appears
on an earlier page. It is not repeated at the bottom of every fragment. Each
block owns its collection independently, including blocks sharing a thread.
Nested blocks finish their own collections before the enclosing flow continues.
Native, aligned, and grid group renderers retain native collection pagination.

All valid `layer` requests on a block-targeted footnote resolve to `"flow"`.
Invalid values receive an error. Choosing `"foreground"` does not turn a block
collection into a page overlay. A fixed `height` uses native block layout and can
add free space before the collection or split it across pages; it is not a
per-page footer policy. Prefer automatic height for ordinary flowing content.

To use an actual page footer, keep the mark local and explicitly target its body:

```typst
#deixis-block(breakable: true, inset: 12pt)[
  A passage#deixis-mark(id: <source>).
  #deixis-footnote-body(of: <source>, target: "page", layer: "flow")[
    This entry belongs to the physical page footer.
  ]
  More main content.
]
```

The mark keeps the block's counter owner. The explicit body target changes
rendering ownership, and the body declaration allocates the native footer slot.
For per-page footnotes, use this existing mechanism. A separate per-fragment
block-footer mode would need a different allocation engine and is not provided.
See [body ownership](ownership.md) and [rendering](rendering.md) for forward
attachments, native allocation boundaries, and page overlays.

## Boundaries to account for

- The continuation-frame model covers page breaks in one column. Same-page
  column fragments need additional geometry; use separate blocks per column.
- Block margins occupy part of the page's text width. Their continuation frames
  do not subtract native page-footer reservations. Dense packed scoped margins
  can overlap a native footer on a continuation page. Use the block's end
  collection, reduce the margin content, or keep these layouts separate.
- Ordinary immediate margins on continuation pages are covered, but a larger
  nested layout with multiple breakable blocks can exceed Typst's layout-pass
  limit. Overlay margins are the recommended path for multi-page blocks.
  Native `place` may also affect flow spacing. There is no general immediate
  placement/convergence workaround.
- Overlay notes are separate page drawings. Native block clipping does not
  automatically clip them. Neither native footers nor other overlay layers are
  general collision obstacles.

Context-generated note IDs inside successive/nested blocks are supported by the
scope-state fix. This does not remove Typst's finite pass limit for arbitrary
context-generated registration/geometry chains. Prefer pre-layout host callbacks
for [frame identities](touying-identities.md) when available.
The anonymous-parent serial dependency found by the scope audit is now fixed:
one synchronized child or several siblings no longer require a named parent
after earlier collections. More deeply nested synchronized collections still
retain a pass limit; see [scope limits](scopes.md#layout-limits).
