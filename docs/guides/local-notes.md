# Table And Figure Notes

Use **`deixis-block` as the local owner**. It already gives a table, figure or
other object independent numbering and an end collection. No new note type or
setup function is needed. See the [complete example](../../examples/local-notes.typ).

## Wrap The Whole Object

For a nonfloating figure, put its body **and caption** in the block. Notes from
both collect after the figure; the surrounding document's numbering resumes
when the block ends.

```typst
#deixis-block[
  #figure(caption: [Measured values.])[
    #table(columns: (1fr, 1fr),
      [Sample], [Result],
      [Trial], [18.7#deixis-footnote(numbering: "a")[A qualification.]],
    )
  ]
]
```

Wrapping only `figure.body` ends the local scope **before its caption**. Caption
notes then belong to the surrounding scope. Choose that boundary intentionally.
Block names are optional and must be unique when supplied; note IDs remain
document-wide, even when numbering is local.

## Keep Floating Notes With Their Figure

Float the entire local block, containing one ordinary native figure:

```typst
#place(top, float: true, scope: "parent")[
  #deixis-block[
    #figure(caption: [A diagram#deixis-footnote(numbering: "a")[Caption note.].])[
      #rect(width: 100%, height: 45pt)[
        Diagram#deixis-footnote(numbering: "a")[Diagram note.]
      ]
    ]
  ]
]
```

`place` owns floating, `figure` owns its caption/numbering/references, and
`deixis-block` owns the notes. Avoid a second outer figure just to float the
block: that creates another figure element/counter entry. Native `place` with
`float: true` participates in the document flow as a float; this is different
from the immediate note-placement path.

Putting a floating figure **inside an outer block** does not make that block's
following collection part of the float. The figure may move while its notes
remain in surrounding flow. Keep the collection inside the floated unit.

This recipe also works for parent-scope floats and native columns because the
notes are local collected content, not native page-footer entries. A float
still has to fit its available region. Large objects/collections should stay in
breakable document flow. An explicit `target: "page"` opts back into page-footer
allocation and its [native float limits](footnotes.md#page-and-local-ownership).

## Long Tables And Repeating Headers

For a long table inside a native figure, allow both wrappers to break:

```typst
#show figure: set block(breakable: true)
#deixis-block(breakable: true)[
  #figure(caption: [Values#deixis-mark(id: <units>, numbering: "a").])[
    #table(columns: (1fr, 1fr),
      table.header([Sample], [Value#deixis-mark(of: <units>)]),
      [Control], [12.4],
      // More rows…
    )
  ]
  #deixis-footnote-body(of: <units>, backlink: true)[All values use the same units.]
]
```

The caption creates one annotation. Every header reuses it, including before its
original declaration. Repeated headers should use **unnamed** reused marks:
`occurrence:` names must be unique within an annotation, and native header
repetition duplicates an explicit name. Each unnamed copy gets its own return
point. The body can link back to all header marks and the caption.

Use `deixis-ref(<units>)` instead if a repeated header should merely display the
marker/link without adding an annotation occurrence or another backlink.
Do not create original marks, note bodies or local blocks in repeated headers:
explicit identities are duplicated and diagnosed. Anonymous note wrappers create
a separate annotation/body for each header copy, usually not what you want.
Native repetition is real layout output, not a new shared-identity declaration.
The same principle applies to repeated table footers and other repeated content.

The collection appears **after the entire table and caption**, not at each
fragment's bottom. It may continue across pages. All valid footnote body layers
resolve to flow for this local collection; foreground does not make a local
footer repeat on each table page. See [breakable blocks](blocks.md).

## What We Are Keeping Separate

No automatic table/page-fragment footer mode is added. That needs allocation
rules beyond a block-end collection. Row-level notes, caption notes, shared
header marks and long collections already use the same public APIs.
A convenience wrapper would be useful only if it could remove substantial
boilerplate while preserving native figure options, captions and references;
the current examples do not justify another public function.
