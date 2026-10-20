# Rendering paths and layers

Deixis keeps annotation identity independent of placement. A mark chooses its
counter scope; a body chooses its rendering scope. Both can be declared in either
order: `id:` declares the original and `of:` attaches its body. A standalone
body instead uses its own `id:` and has no original mark. Use
[repeated marks](shared-notes.md) for another annotated passage, or
`deixis-ref` / `@label` for prose references. The
[reference guide](references.md) covers public IDs, ranges, and backlink policies.
See [body ownership](ownership.md) for the distinction between a declaration's
location, the placement anchor, and native page allocation.

## Choosing a rendering path

| Component | `flow` | `foreground` / `background` |
| --- | --- | --- |
| Inline mark / phantom mark | At its call site | Not independent page objects |
| Region mark | Drawn on the current page; one-page regions | May span several pages |
| Inline body | Native document flow | Use an inset body for absolute placement |
| Page footnote | Native pagination, including long bodies | Native space reservation with a complete body painted over its reserved area |
| Block/minipage footnote | Collected at the block's end | Uses the block's flow rather than an independent page overlay |
| Endnote | Collected by `deixis-print-endnotes` | The printer owns layout and pagination |
| Margin body | Immediate exact placement on its declaration page | Document-wide collision/spillover layout in existing pages/blocks |
| Inset body | Immediate placement on its declaration page | Deferred placement in the chosen page layer |

Immediate placement knows where the containing block actually begins. Page-space
anchors are converted relative to that origin; the vertical call position is not
necessarily the origin of native `place`.

The `"flow"` body layer and `margin-layout: "flow"` select different things.
The first chooses when/where to paint a margin note. The second chooses an overlay
packing algorithm that distributes vertical space toward the marks. Immediate
margin bodies use exact placement without collision avoidance or spillover.

Margin bodies optionally accept `overflow: "error"` to check their final assigned
frame after packing/spillover; the default `"allow"` preserves existing placement.
This checks bounds, independently of collision handling. See
[margin overflow](margin-overflow.md) for supported layouts and limits.

## Independent component settings

```typst
#show: deixis-setup-notes
#deixis-footnote(
  mark-type: "region",
  layer: (mark: "background", body: "flow"),
)[A highlighted region][A native footnote body.]
```

Set defaults with `deixis-set(layer: (footnote: "foreground", margin-note: "background"))`.
Inset bodies and page footnotes default to `flow`; margin bodies default to
`foreground`. With `override-page-footnotes: true`, an unspecified page-footnote
layer defaults to the foreground overlay. An explicit layer, including one from
`deixis-set`, still selects that layer.

Connections have a separate `connector.layer` setting. Both margin and inset
connections default to foreground and can explicitly use background, independently
of body placement/layer. Both use document-wide overlays for cross-page routing.
See [connection layers](connectors.md#connection-layer). Within a page overlay,
`z-index` orders regions, bodies, and connections across adapter types; higher
integers paint later. Native flow and host composition retain their boundaries.
See [paint order](paint-order.md) for simple calls, component controls, grouped
output, and native state-order semantics.

Configure native page foreground/background before applying `deixis-setup-notes`.
Setup composes those layers once. After replacing one later, reapply setup to
restore that layer's compositor; the unchanged layer is retained without
recursion or duplicate decoration. Registration and counters are not reset.
The background hook also publishes physical page geometry. See
[setup and page layers](setup.md) for the setup requirement matrix, retained
options, host-owned/scoped styles and a small example.

## Presentation frameworks

A theme that owns page settings can install the overlay content itself. This
avoids changing page styles halfway through a physical slide, which can create
extra pages. For Touying, configure page layers through the theme and initialize
annotations in the slide setting:

```typst
#import "@preview/touying:0.8.0": *
#import themes.simple: simple-theme, slide
#import "@preview/deixis:0.2.0": *
#show: simple-theme.with(aspect-ratio: "16-9", config-page(
  background: deixis-page-overlay(layer: "background"),
  foreground: deixis-page-overlay(),
))
#let annotations(body) = deixis-setup-notes(page-overlays: false, [
  #deixis-update-note-counter(0)
  #body
])
#slide(setting: annotations)[
  Text#deixis-footnote[A slide footnote.]
  #pause
  Revealed content.
]
```

This resets the default series for each rendered frame. Use wrapper-created IDs;
repeated explicit IDs across animation frames still denote duplicate definitions.
For shared marks or separate `id:`/`of:` components, use the
[frame-local label recipe](touying-identities.md) through Touying's pre-layout
callback. It also supports exact cross-frame references without changing the
document-wide default.
The integration fixtures cover Touying 0.6.3 and 0.8.0, including two pause frames
and a following slide with repeated numbering. Host themes
can compose additional content around the overlay hook in their own page layers.
See [counter resets](counters.md) for heading rules, stream/scope selection,
and the distinction between a frame boundary and natural pagination.

Default `pause`/`uncover` now hide deferred annotations together with their
declarations. Covered footnotes do not reserve footer space; region drawings,
overlay bodies, and connections stay covered in both page layers. Native flow
retains its footprint and execution. See [annotation visibility](visibility.md)
for component ownership, `only`, custom-cover limits, frame identity, and the
[small reveal example](../../examples/touying-reveals.typ). Counter resets and
visibility remain independent.

## Footnote ownership

See [footnotes and long bodies](footnotes.md) for whitespace, native controls and
a breakable-border recipe. Choose native flow for long notes or complex contextual content. Typst handles
splitting, column boundaries, and page allocation. Deixis adds markers, styles,
labels, and backlinks without advancing ordinary native footnote numbering.

Ordinary column-scope floating figures can allocate page footnotes, including
inside native columns. Parent-scope floats (`scope: "parent"`) do not allocate
entries in Typst 0.15. This applies to flow and overlay bodies alike; switching
layers does not repair that native limitation. Keep the mark in a parent-scope
figure and its body declaration in the surrounding main flow:

```typst
#figure(placement: top, scope: "parent")[
  Diagram#deixis-inline-mark(id: <diagram-note>).
]
#deixis-footnote-body(of: <diagram-note>)[A note about the diagram.]
The surrounding paragraph continues here.
```

The body declaration owns the native reservation page; a float can move to another
page independently. Use an endnote or a margin/inset body anchored to the mark
when that separate page ownership is unsuitable. Nonfloating tables and nested
quotes/boxes have representative native footnote coverage. The
[small figure example](../../examples/figure-footnote.typ) demonstrates both
float scopes. Visible page-footnote declarations with no native entry now receive
a diagnostic in every layer, including flow. Custom body renderers need not emit
standard live-span hooks for this allocation check.

An overlay reserves measured geometry without emitting a hidden live copy of its
content. The real body emits identities and nested annotations only in the painted
version. Overlay notes taller than the usable page produce a diagnostic directing
the author to native flow.

An empty native marker can lose its footer allocation at a paragraph boundary,
including a trailing declaration at the end of the document. Overlay declarations
stay strictly flow-neutral; Deixis diagnoses missing reservations instead of
silently omitting these bodies. Put the declaration before visible content in the
same paragraph, or use `layer: "flow"`:

```typst
#deixis-footnote-body(of: <term>)[The explanation.]
#deixis-inline-mark(id: <term>)[The term].
```

Flow footnotes retain a zero-size inline box as their native allocation marker,
preserving entries at paragraph/document ends without swallowing adjacent spaces. A standalone flow declaration may create an empty
paragraph. This boundary limitation is separate from a parent-scope float's lack
of native allocation; moving a declaration out of a parent-scope float is still
necessary. A wrapper's own visible mark can supply a following native anchor;
a separate body-only declaration has no such marker of its own.

Homogeneous overlay columns retain series grouping and the selected group renderer,
painted with the gap that native layout left between their reservations. When
native entries or different body layers share a column, each overlay body uses
its native reserved slot. Different group renderers or render contexts also
retain native slots so one note cannot impose its layout policy on another
reservation. The separator is always the native footer's own.
Custom group renderers should keep total dimensions consistent with the individual
reservation renderer. Arbitrary group reflow remains unsuitable for splittable
overlay footnotes.

The built-in aligned renderer reserves against a shared marker-width maximum,
so short markers cannot reserve less wrapping space than a neighboring long
marker requires. This conservative reservation can leave extra whitespace on a
page whose actual markers are all short.

Margin, inset, endnote and block-collected footnote bodies preserve the
declaration's font, size, weight, style, color, language/direction, and paragraph
leading/spacing/justification. Page footnotes instead use the native footer's
typography, like `std.footnote` entries, so a note declared in a heading is not
bold. Measurement and live rendering use the same context, including custom
single-note renderers. Renderer and body-style overrides can still apply local
settings inside it. This does not capture arbitrary surrounding show rules.
The built-in grid group renderer also restores each cell's captured context and
accepts an empty group. It lays out markers and bodies directly, bypassing
per-note `render-single` and container wrappers.

## Collected endnotes

`deixis-print-endnotes()` collects eligible bodies declared before that call.
Use `series`, `target`, and `after`/`before` to print a subset. String bounds refer
to pin names; labels and locations are also accepted. Bounds follow body
declarations, including when a body is declared before its associated mark.

The first matching printer owns a body. Overlapping ranges, repeated calls, and
later unfiltered calls therefore print each body once. Named scopes have their
own rendering ownership. Long endnotes use native document flow, and
`deixis-query-notes(page: here().page(), include-types: "endnote")` includes continuation pages.

Printer style and renderer overrides apply to its selected bodies.
`render-group` controls the collected layout. Stacked renderers invoke each
body's `render-single` and `container-func`; the default grid paints cells directly.
See [collected layouts](collected-notes.md) for callback, spacing, and pagination
contracts.
The [small grouped-endnotes example](../../examples/endnote-groups.typ) shows
series filtering and a later collection that prints only newly added bodies.

## Scope and page boundaries

`"page"` means document-level ownership; it does not reset a counter every physical
page. Named blocks, ancestor targets, threads, and counter synchronization remain
separate from rendering ownership.
Public block names are unique nonempty strings/labels; automatic, named, and
thread owners cannot collide. `"page"` is reserved as a block name. Named
placement/printer/update targets must resolve, while passive unknown queries
select nothing; see [scope names and targets](scopes.md).
See [counters and resets](counters.md) for current-value reads, strict updates,
series selection, and reset ordering.

A named target can precede or follow its block, including a threaded block or a
block synchronized with another counter. A body with an automatic target keeps
its mark's specific block instance. Circular counter synchronization is an error.

Physical pages have their own recorded dimensions and margins. Resetting printed
page numbers does not change spillover's page identity. Percentage margins and
inside/outside binding resolve in each page's context.

Breakable blocks have a margin frame on every physical page they occupy. Their
continuation frames repeat the block and ancestor vertical insets, and their
horizontal offsets follow duplex margins. Exact notes stay with their marks;
adaptive/flow packing can spill into later fragments or threaded blocks. Immediate
margin notes also recognize continuation fragments. Block footnotes remain
collected at the owning block's end, including when blocks share a thread.
Long collections paginate natively. An attached footnote body with explicit
`target: "page"` uses a physical-page footer instead, retaining the original's
counter owner. See [breakable blocks](blocks.md) for the complete contract,
fixed-height behavior, and a small two-page example.

Continuation frames do not subtract native page-footer reservations: dense
scoped-margin packing can overlap those footers. Larger nested immediate-margin
layouts can also exceed the native pass limit; prefer overlays for multi-page
margin bodies. These are separate from `margin-layout: "flow"`, which is an
overlay packing policy.

This fragment model covers page breaks in a single column. A block that breaks
between columns on the same physical page needs additional fragment probes;
use a separate block per column for scoped overlay margin notes. Native page
footnotes in multiple columns are covered independently.

`margin-layout: "exact"` preserves marker alignment and requested offsets. It
permits overlap and out-of-bounds bodies, and ignores collision packing and
spillover. Adaptive/flow layouts pack bodies; `spillover: false` keeps that body
in its original page/block even if an earlier body has already spilled.

Built-in overlay layouts prepare one measured plan for each accepted body:
side, width, offsets, height, and final position. Painting and connector bounds
use that plan. `margin-layout: "flow"` distributes free space toward the marks
and paints at the resulting coordinates; its connector targets use those exact
coordinates too. A note spilling to another frame is measured at that frame's
margin width. Custom `margin-layout` functions retain their existing arguments
and may delegate to a public built-in layout after changing the note data.

Overlay spillover does not create pages. If there is no further page/block, or a
margin note exceeds all available space, its final body can exceed the margin.
At page level, an oversized first body stays on that page to stop endless
cascading; block/thread packing can carry it onward to an existing later block.
Add a page, shorten the note, or choose an inline/endnote layout. Flow regions
cannot cross pages. The [region guide](regions.md) covers automatic page-spanning
wrappers, nested containers, and attached pins. Intrinsic pages use their final numeric dimensions; overlays still do not enlarge
the native page. See [intrinsic page geometry](collected-notes.md#pages-with-an-automatic-dimension).

## Safe note outlines

`deixis-note-outline()` reads static text from note bodies; it does not render
their bodies again. Formatting wrappers and raw text contribute plain text,
whitespace is normalized, and excerpts are limited to 160 grapheme clusters.
Contextual functions, state updates, labels, and note registration are not
executed. A body containing only contextual output gets `No static summary`.
Math, images, and other nontext content may need an explicit description.

Supply `summary: note => [A description.]` to control the excerpt. The callback
receives the structured semantic record (`id`, type/series, original/reused marks,
body description, locations, and safe summary) plus its `badge`. Return an
independent description or `note.summary`. `note.body` is a description with
locations and its own safe summary, not executable content. See the
[small example](../../examples/note-summaries.typ) and [custom views](outlines.md).

Outlines retain document order within groups, and `after`/`before` use strict
source boundaries, including marks on the same line. Scope and series filters
also apply to standalone marks. The [scoped-notes example](../../examples/scoped-notes.typ)
shows separate rendering ownership with shared thread numbering.

## Invisible declarations

Overlay body-only declarations emit registration and metadata without inserting
spaces, inline boxes, or empty paragraphs. This applies to standalone bodies,
forward/backward mark association, and wrappers used with an existing ID. The
regression suite compares actual labelled content positions in inline, block,
paragraph, and grid-cell contexts for both overlay layers. Collected endnote
declarations follow the same rule.

Explicit named targets, including blocks declared later, preserve the same
neutrality for overlay margin/inset and collected endnote declarations. A
block-targeted footnote becomes a native flow collection and follows its
collection rules.

Page footnotes intentionally reserve footer space and may therefore change page
allocation. Overlay declaration markers are empty and add no paragraph or inline
glue. The native paragraph-boundary allocation limitation above is diagnosed;
it is not worked around by inserting invisible whitespace.

Immediate margin/inset bodies with `layer: "flow"` use native placement. A native
`place` can interrupt paragraph layout; this remains a documented limitation of
that rendering path. Choose an overlay when the body declaration must be strictly
neutral to the current flow. Immediate collision avoidance and collision checks
between layers remain deferred.
