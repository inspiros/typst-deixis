# One body, several marks

Declare a note once, then use `deixis-mark(of: ...)` or the equivalent
`deixis-inline-mark(of: ...)` where another passage needs the same annotation:

```typst
#show: deixis-setup-notes
First#deixis-endnote(id: <shared>, backlink: "multiple")[One explanation.]
Again#deixis-mark(of: <shared>).
#deixis-print-endnotes()
```

The [small shared-note example](../../examples/shared-notes.typ) also decorates
a repeated passage. The target is the annotation's public ID. A repeated mark can appear before the original declaration, on a
later page, or in another scope. It keeps the original number and series without
advancing any counter. Defining an original mark twice with the same ID remains
an error; repetition is explicit.

Both forms share one occurrence engine and support the same local appearance,
forward targets, names, and backlinks. `deixis-mark(id: ...)` also creates originals;
`of:` always means reuse. Identity arguments are named. See
[annotation identities](identities.md) and the
[mark/body example](../../examples/mark-and-body.typ).

## Compared with a reference

Both `@shared` / `deixis-ref(<shared>)` and a repeat display the original number
and register one return-link origin. For a bare number their visible result is
often identical; a prose reference is usually enough. References also support
lists, numeric ranges, supplements, and native page forms.

A reused mark uses the inline-mark interface by default for another annotated passage. It accepts
passage content, marker overrides, marker position, and inline decoration such
as underline/highlight/box. The content argument to `deixis-ref` is a supplement;
the content argument to `deixis-mark` is the passage being marked. A repeat
adds no connector automatically. An optionally named occurrence can now supply
measured inline geometry for explicit connection selection.

Forward use is allowed with an annotation ID declared later:

```typst
Earlier#deixis-mark(of: <later>).
Later#deixis-endnote(id: <later>)[The shared explanation.]
#deixis-print-endnotes()
```

The original declaration remains the counter owner regardless of source order.
An occurrence does not become the primary mark because it appears first.

## All three mark forms

`deixis-mark` supports every current mark type. Bare calls remain inline,
independently of the original's type. Select another form explicitly:

```typst
#deixis-mark(of: <shared>, mark-type: "region", inline: true,
  layer: "background")[$x^2 + y^2$]
#deixis-mark(of: <shared>, mark-type: "phantom", occurrence: <quiet>)
```

`deixis-region-mark(of: ...)` and `deixis-phantom-mark(of: ...)` are equivalent
specialized forms using the same engine. All forms retain forward lookup, the
original counter/scope/series, and one body. See the
[small example](../../examples/shared-mark-types.typ).

Regions require either a new passage or `pins`, never both. Supplied `pins`
select region mode when `mark-type` is `auto`, matching the note wrappers.
Content alone keeps the inline default. Automatic corners are private to each
region occurrence, including unnamed and nested occurrences.

A region original supplies its captured shape, layer, padding, marker placement,
and common styles beneath local overrides. Switching from an inline/phantom
original inherits common stroke/fill/radius and marker style; region-specific
defaults come from region configuration. Component dictionaries select the mark
branch. Local marker/region changes never alter the shared body. Overlay region
markers remain foreground, as for original regions.

Phantom repeats emit only a semantic origin. They accept no passage or appearance
override and do not hide or renumber the shared body. Region-only options are
rejected on other repeat types instead of being ignored.

## Appearance

The default call displays the original marker and uses its marker-style function.
It can repeat an inline, phantom, or region original as an inline marker. The
surrounding text context belongs to this occurrence. Local decoration controls
match inline marks:

```typst
#deixis-mark(of: <shared>, inline-mode: "underline")[Another passage]
#deixis-mark(of: <shared>, marker-style: it => strong(it))
#deixis-mark(of: <shared>, marker: none)
```

`marker` overrides only this occurrence. With `marker: none` and no content, the
call publishes an invisible return-link origin without adding an inline box or
empty paragraph. It does not change the original mark or the body's marker.

The original mark's resolved stroke/fill/radius are retained even if defaults
change before the repeat. Component dictionaries on supported styling parameters
select the `mark` branch, with `nodes`/`rest` fallbacks as in ordinary marks:

```typst
#deixis-mark(of: <shared>,
  stroke: (mark: blue, body: red),
  marker-style: (mark: it => strong(it), body: it => emph(it)),
)[Another passage]
```

Here blue and `strong` affect this occurrence. The `body` branches do not change
the shared note body, and a body-only override leaves the occurrence's inherited
mark styling intact. These rules also apply to `fill`, `radius`, `inline-mode`,
and `marker-position`. The hardcoded `marker` itself is a scalar content value,
rather than a component dictionary.
Relative `em` lengths and marker callbacks still use this occurrence's typography.

Passage content is not a second note-body component. Body-only and connector
options are rejected. Layer/padding/shape options apply only in region mode.
A bare repeat of a region or phantom original remains inline; choose its other
form explicitly.

## Body and return links

Repeated markers link to the body when it has been painted. Until then they show
their marker without a dead link. `backlink: true` / `"always"` adds a return hook
for the original mark, every repeated-mark call, and every ordinary reference
call. `"multiple"` enables hooks once the original has at least one other origin.
Repeated marks and references retain their source order after the original's
return link. Built-in measurement includes the resulting hook dimensions.

Footnote, endnote, margin, inset, and inline bodies remain single bodies. Nested
repeated marks do not print another explanation or replay body state. Outlines
continue to show one entry for each annotation. A standalone body with no original
mark has no counter owner; use `deixis-ref` for it. To make it a numbered
annotation, declare the original with `id:` and attach the body with `of:`.

The original mark remains the implicit placement anchor and connector source. Repetition does not
move a margin/inset body, create another reservation, or draw an additional
connector, even when the body has `connector:` enabled. Placing copies of a body
on several pages remains a separate extension. Ordinary
`@label` / `deixis-ref` calls remain the simplest choice for prose references.

## Named occurrence frames

Give an occurrence a name when it needs a stable identity and a measured frame:

```typst
#deixis-mark(of: <shared>, occurrence: <later-use>)[Another short passage]
```

Names are nonempty strings or labels scoped to the annotation. Two different
annotations can both have an occurrence named `later-use`. Reusing a name for
the same annotation is an error, including when selecting its ID as a string or label.
Forward targets work, and naming an occurrence does not advance counters or add
another body/backlink origin. These names are not new note aliases or native
reference labels: `@later-use` does not refer to the shared annotation.

A visible named inline occurrence wraps its formatted marker and optional passage in
one native inline box. Its four measured corners supply a page-space envelope
and four candidate ports, including under native transforms. This box does not
break across lines/pages: use short passages. Its bounds are the native content
frame, not a glyph-ink or decoration-outset measurement. Unnamed repeats retain
their existing wrapping behavior. With no passage and `marker: none`, even a
named occurrence remains invisible and flow-neutral; it has an origin but no
drawable frame or routing ports.

Live backlinks to a visible named occurrence target its painted frame. The early
origin still counts hooks during measurement, so an inline box wrapping to the
next line cannot leave the return destination on the preceding line.

A named region uses its own pin bounds. Connections select its fragment on the
destination body's page, or the nearest first/last fragment outside that range,
matching original-region selection. Return links target the first painted frame
of the whole region, even for an unnamed region declared far from its pins.
A hidden region marker still has region geometry and a return destination.

A named phantom supplies a zero-size point at its native source metadata and
can be an explicit connection source. Hiding an inline repeat with `marker: none`
still supplies no drawable frame. Region/phantom calls add one return origin,
regardless of fragment or edge count. Names are shared across all repeat types.

Reuse retains the [region limits](regions.md), including page-based fragments
and one-page immediate regions. Immediate regions now preserve their native
flow footprint during detached note measurement while painting only in live
output. The [example](../../examples/flow-regions-in-notes.typ) uses a flow-region
repeat in a margin body and a block region in an inset body.

Select a named frame with
`deixis-connect(from: (mark: <shared>, occurrence: <later-use>), to: <shared>)`.
Naming a repeat does not itself draw a line, change the original mark's routing
geometry, or move the shared body. See [independent connections](independent-connections.md).

Body `connector` options remain the simple shorthand; independent edges select
their own source occurrences.
