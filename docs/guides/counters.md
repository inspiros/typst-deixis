# Counters and resets

Examples use the [standard import and setup](getting-started.md#1-start-with-native-footnotes).
Excerpts with existing IDs or callback variables extend the surrounding example.

Each numbered original mark advances one counter, selected by its **counter owner
and series**. The first numbered original in an unused stream gets 1. Body
attachments, standalone bodies, references, repeated marks, pins, and explicit
connections do not advance it. Note identity is independent of its displayed
number, so resets do not create duplicate identities or change earlier notes.

An original whose resolved `numbering` is `none` takes no counter value and
has `count: none` in queries. This includes local options and shared defaults,
including note-family settings such as `numbering: (margin-note: none)`.
It shows no automatic marker; an explicit fixed `marker:` still displays.
With non-`none` numbering, fixed markers and `marker: none` still advance the
counter. References to a markerless note display `?` by default; outlines keep
the note with an empty badge.

Most note wrappers use series `"default"`; endnote wrappers use `"endnote"`.
Both counter functions default to `"default"`. Pass `series: "endnote"` when
reading or resetting that stream. Series names are literal strings, including
punctuation and empty strings, with no reserved edge/component words.

## Read, set, or update

After `#show: deixis-setup-notes`:

```typst
#context deixis-note-counter(series: "notes")
#deixis-update-note-counter(10, series: "notes")
#deixis-update-note-counter(n => n + 2, series: "notes")
#deixis-update-note-counter(0, series: "notes")
```

An unused stream reads as zero. The read returns an integer inside a native
`context`; it is the current numbering value, not a total of all notes ever
declared. Setting 10 makes the next numbered original 11. Resetting to 0 makes it 1.
Other series remain unchanged. A callback receives the current value and returns
the replacement integer; keep it a pure calculation of that value.

Direct values and callback results must be integers. Floats, booleans, strings,
`none`, and other results are rejected without coercion. Convert a value deliberately before passing it if appropriate.
Signed integers remain supported: setting -1 permits a next value of 0, while
negative displayed counts require a numbering callback that handles them.
The standard numbering patterns require nonnegative counts.

See the [small reset example](../../examples/counter-resets.typ), where a native
heading rule restarts one series for each section while another continues.
There is no separate reset function: updating to 0 supplies it. For independent
local collections, see [scoped notes](../../examples/scoped-notes.typ).

## Counter ownership

`target: 0` selects the current scope. Negative integers select ancestors;
going beyond the available stack falls back to the document. `target: "page"`
always selects the document owner. A named string/label can precede its block,
including forward synchronization chains. See [scoped notes](../../examples/scoped-notes.typ).
Named targets select public block IDs; private automatic IDs and synthesized
thread names are not target syntax. Select a thread through a named member.
Strings and labels normalize to the same public name. See [scopes](scopes.md).

A normal `deixis-block` has its own counter owner. Matching `thread:` values share
an owner by default. `sync-counters-with:` explicitly shares numbering while
retaining each block's rendering ownership. Reading, setting, or resetting through
any synchronized alias affects the same stream. Other owners remain independent.
Scope and series are separate keys: `(scope: "alpha", series: "beta:gamma")` and
`(scope: "alpha:beta", series: "gamma")` cannot alias each other.
Automatic blocks, named blocks, and threads also use separate private owner
namespaces. A block named `"1"` cannot share an automatic block's numbering.
Updates require a declared named target; passive reads of an unknown named
target return zero.

The original mark owns its series and assigned number. An attached body inherits
that series; omit `series:` on attached bodies and wrappers. An explicit series,
even the same value, is rejected. A body `target:` override changes its rendering
scope without moving the counter operation or changing the inherited series. A named
standalone body's series can organize a collection without creating a counter.
Use explicit series on original marks or creating wrappers to choose their stream.
Page-note queries retain native body order after resets, and outlines retain
original source order. Neither sorts entries by their displayed count; see
[selection and queries](queries.md).

## Ordering and placement

Place a reset in the main flow before the originals it should affect, usually
at a section boundary. A later reset does not renumber an earlier original, body,
reference, or reuse. Printing an endnote later keeps its original number.
`"page"` is a document scope, and does not imply a reset on each physical page.
For natural pagination, use the opt-in display policy below. Native rules and
explicit boundaries remain useful for resetting the assigned counter itself.

## Restart Footnote Markers On Each Page

Keep the simple wrapper and opt in through `numbering`:

```typst
#let note = deixis-footnote.with(
  numbering: (restart: "page", pattern: "1"),
)
Text#note[An explanation.]
```

`pattern` defaults to `"1"`; `"*"` gives native symbol numbering, and a pure
`n => ...` callback receives the page-local ordinal. For all subsequent originals,
use `#deixis-set(numbering: (restart: "page", pattern: "1"))`. Ordinary numbering
strings/functions retain the existing behavior. Set `numbering: "1"` to return
to the assigned counter. Explicit `marker:` content takes precedence.

See the [editable page-numbering example](../../examples/page-numbering.typ).

Native Typst also supports a per-page recipe: reset `counter(footnote)` in the
page header, as described in the [native footnote documentation](https://typst.app/docs/reference/model/footnote/#parameters-numbering).
That resets the native counter itself. This Deixis policy instead changes only
the displayed ordinal; assigned counts and counter updates remain independent.
Native footnotes still allocate page-footer bodies, while Deixis coordinates
the original marker across separate bodies, reuse, references and outlines.
Native labelled footnotes already support reuse and links too; the distinction
is the assigned/displayed split and its integration across Deixis adapters.

Despite this section's footnote example, the policy applies to every original
Deixis mark and note adapter. Margin, inset and inline notes can use it too.
Endnotes retain their original page's marker when collected later, so repeated
numbers can make that list ambiguous; choose independent series or ordinary
numbering when readers need a unique label across the document. A standalone
body has no original mark to rank; attaching a body with `of:` uses its original.

Each physical page starts at 1, independently for each counter owner and series.
Ordering follows original declarations within that stream. All originals in the
stream with non-`none` numbering consume a slot, including ones using a different
pattern or custom marker; use a separate series when numbering sequences should
be independent. Hidden numbered originals retain a slot, while unnumbered and
omitted originals take none.
Synchronized blocks share a stream; independent local blocks retain their owners.

A `deixis-block` that breaks across pages still collects its bodies into one list
at its end, so page-local markers repeat inside that list (1, 2, 1, 2), as they
do for endnotes. For multi-page blocks, either send the notes to each page's
footer with `deixis-footnote.with(target: "page")`, which then restart cleanly
per page, or keep ordinary numbering inside the block. Threaded blocks share one
stream: numbering continues across them on a page and restarts on the next.

**The assigned counter is unchanged.** `note.count` and `deixis-note-counter`
report the source-order assigned value and current counter respectively, including
explicit updates; unnumbered originals retain `note.count: none`. `note.marker`
is the displayed content; references, outlines, attached bodies and reused marks
share it. A reuse on another page keeps its original's marker. Manual counter
updates change assigned counts but do not change the page-local rank. This
separation preserves identity and existing counter arithmetic. Multi-note
references keep caller order and individual links; page-local markers are not
collapsed into numeric ranges across pages.

Custom body renderers should use `deixis-generate-body-marker` (or the supplied
`marker-str` content) to preserve that label. Their `data.count` remains the
assigned counter, just like a query record's `count`.

The page is the original mark's physical page, using its painted return point
where available; a spanning region uses its first painted page. Resetting the
printed page counter does not merge physical pages. A separate or split footnote
body retains the original marker even if its first fragment is on another page.
This policy does not restart at a body fragment or move notes between pages.

Page-dependent marker widths can affect pagination. This mode requires extra
layout passes; deeply nested contextual notes or pathological boundary changes
can still exceed Typst's convergence limit. Compiler warnings must be treated as
failures. Test long documents with the intended fonts, symbol pattern and page
size. Ordinary assigned numbering remains the default. Touying restarts per
physical frame; the existing slide-setting recipe remains available for
explicit host-controlled counter resets.

## Restart at a heading

Apply a native show rule after setup, selecting the heading level and series:

```typst
#show heading.where(level: 1): it => {
  deixis-update-note-counter(0, target: "page", series: "notes")
  it
}
#let note = deixis-endnote.with(series: "notes")

= First Chapter
Text#note[Starts at one.]
= Second Chapter
Text#note[Starts at one again.]
```

The reset runs before the heading's title, so a new mark in that title gets 1
and the next original gets 2. Subheadings and other series are unaffected.
Reused marks and references keep their original number, including when they
precede that original. Print endnotes where wanted; printing does not restart
their stream.

`target: "page"` deliberately selects document numbering even inside a block.
Use `target: 0` for the current scope; synchronized/threaded aliases share that
reset. A native rule applies to every matching heading in its scope, including
headings inside notes or custom output. If only selected headings should restart
numbering, put the update and heading together in a small wrapper instead.

## Slides and explicit page boundaries

For Touying, reset at the start of the slide's setting function, before its
body. The [presentation integration](rendering.md#presentation-frameworks)
shows the full setup and host-owned page overlays. Select each stream explicitly:

```typst
#let annotations(body) = deixis-setup-notes(page-overlays: false, [
  #deixis-update-note-counter(0, target: "page", series: "default")
  #body
])
#slide(setting: annotations)[...]
```

Each rendered animation frame starts at one, so persistent notes keep the same
numbers across a pause; the next slide starts at one too. This is frame-local
numbering, not one continuous stream across distinct slides. Use wrapper-created
IDs across animation frames, as described in the rendering guide.

For a page boundary you create yourself, put `#pagebreak()` followed by
`#deixis-update-note-counter(0, target: "page", series: "notes")` before its
originals. An ordinary page break or an update of native `counter(page)` alone
does not reset note numbering. This recipe does not cover pages formed by natural
pagination. Page headers and overlays run in native rendering order and are not
a general substitute for a reset at an original's boundary.

## Resets inside live bodies

Updates inside live body content retain native evaluation order. They are
barriers to nested-original preparation: a mark is not extracted past a reset.
Headings also retain live ordering, so a heading rule that generates an update
runs before nested title/following marks. This conservatively applies to bodies
containing headings even when those headings have no reset rule. Other nested
originals can still register early at their body's declaration.

Deferred/overlay bodies still evaluate in their actual rendering context, so a
reset inside them is not a substitute for a main-flow section reset. In
particular, background bodies run before that page's main flow; foreground bodies
run after it. Within an overlay, [paint priority](paint-order.md) can also change
the order of live counter updates. Use an explicit target when a shared owner
must be selected deliberately.

Arbitrary custom show callbacks cannot be inspected before rendering. When such
a callback changes note counters, put that state-dependent content in a native
`context` to keep its declarations and generated updates in live order. In
this excerpt, `custom-content` is the callback's content:

```typst
#deixis-inline-note-body(inline: false)[#context { custom-content }]
```

Context-generated nested notes remain subject to Typst's finite layout passes;
this does not make arbitrarily deep registration chains converge.
