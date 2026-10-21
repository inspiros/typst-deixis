# Block names, threads, and targets

Examples use the [standard import and setup](getting-started.md#1-start-with-native-footnotes).
Excerpts with existing IDs or callback variables extend the surrounding example.

Most calls need no scope options. Notes outside a `deixis-block` use the document
scope; notes inside one use its local scope. `deixis-minipage` is an alias for the
same block engine. Give a block a name only when another call needs to select it.

```typst
#deixis-block(id: <chapter>)[
  A local note#deixis-footnote[Collected at this block's end.].
]
```

Block names accept nonempty strings or labels. `"chapter"` and `<chapter>` name
the same block. Names must be unique throughout the document, including nested
blocks and repeated presentation frames. `"page"` and `<page>` are reserved for
the document scope. Omit `id:` for a private automatic instance.

A block name is separate from an annotation's `id:` and does not publish a native
Typst label. Naming a block `<chapter>` alone does not make `@chapter` a reference
to it. Pin scopes are also independent; see [pins](pins.md) and
[annotation identities](identities.md).

## Share a thread or just its counters

The [small scoped-note example](../../examples/scoped-notes.typ) uses two blocks
in one thread:

```typst
#deixis-block(id: <first>, thread: <reading>)[
  One#deixis-footnote[First entry.].
]
#deixis-block(id: "last", thread: "reading")[
  Two#deixis-footnote[Second entry.].
]
```

| Option | Purpose |
| --- | --- |
| `id:` | Names one exact block instance |
| `thread:` | Shares a rendering domain and, by default, numbering between distinct blocks |
| `sync-counters-with:` | Shares numbering with a target, while keeping this block's rendering domain |
| `target:` on a note/body | Selects rendering ownership; an original mark also selects its counter owner |

Thread names accept nonempty strings or labels too. Matching names intentionally
repeat. A block name and a thread name may have the same spelling without sharing
ownership. Even `thread: "page"` names a separate thread; it does not select the
document. A block named `"thread-reading"` has no special connection to
`thread: "reading"`.

Thread members retain distinct instances. A block footnote still collects once
at the end of its own block. A margin body starts in its original instance and
can spill into another available thread frame. Sharing a thread alone does not
move every body into the last member.

An explicit `sync-counters-with:` overrides the default thread counter owner.
For example, `sync-counters-with: "page"` shares document numbering while keeping
the block's rendering domain. Series remain independent within that shared
owner. See [counters and resets](counters.md).

## Selecting a target

| Target | Meaning |
| --- | --- |
| `0` | Current enclosing block, or document outside a block |
| `-1`, `-2`, … | Successive enclosing ancestors; falling beyond the stack selects the document |
| `"page"` or `<page>` | Document scope, regardless of nesting |
| A nonempty string/label | A block declared with that public `id:` |

For `sync-counters-with:`, the current block has not entered the stack yet: `0`
selects its immediate enclosing parent, and `-1` selects that parent's parent.
An anonymous parent works with these relative targets.

Named targets support forward declarations and synchronization chains. A call
can select a block defined later, including one synchronized to a later block.
Cycles are diagnosed. Public targeting uses declared block names; generated
automatic IDs and synthesized names such as `"thread-reading"` do not select
private instances or threads. To target a thread, name one of its member blocks;
queries can also use `thread: <reading>` directly.

Note/body creation, counter updates, endnote printers, and synchronization require
their named targets to exist. Unknown names are diagnosed after layout so a
valid later declaration can be discovered. Passive reads keep ordinary empty
selection behavior: an unknown named counter reads as zero, and an unknown
query/outline target or thread filter selects no entries. Invalid target types
and empty names are errors in either case.

Attached bodies inherit their original mark's exact instance when `target:` is
omitted. An explicit target changes the body's rendering owner while retaining
the original's number, series, and counter owner. Declaration order does not
override the adapter's placement rules; see [body ownership](ownership.md).

## Layout limits

The [breakable-block guide](blocks.md) describes page frames, block-end footnotes,
and immediate-placement limits. Anonymous parents support counter sharing after
earlier local/threaded collections and forward attachments; they do not need a
public name for that layout.

Native context-dependent registration still has a finite layout-pass budget.
More deeply nested synchronized collections can exceed it, including when every
block is named. Naming alone is not a general remedy. Avoid unnecessary nesting
of context-dependent collections; sibling blocks can share a thread or named
counter owner when nesting is not needed for the layout.
