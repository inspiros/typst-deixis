# Declaring, Attaching, And Reusing

Use `id:` to declare a public identity and `of:` to select an existing annotation.
The same ID works for references, body selection, and connections. There is no
secondary body alias or `label:` option in 0.2.

Start with a wrapper when one call should create the mark and body:

<!-- deixis-example: {"id": "example-1", "height": "180pt", "margin": "(left: 18pt, right: 130pt, y: 18pt)"} -->
```typst
#deixis-margin-note(id: <idea>, backlink: true)[A passage][One explanation.]
Another use: #deixis-mark(of: <idea>)[A related passage].
See also @idea.
```

Or declare the components separately:

<!-- deixis-example: {"id": "example-2", "height": "180pt", "margin": "(left: 18pt, right: 130pt, y: 18pt)"} -->
```typst
#deixis-mark(id: <idea>)[First passage]
#deixis-margin-note-body(of: <idea>)[One explanation.]
#deixis-mark(of: <idea>, inline-mode: "underline")[Another passage]
```

There is one original mark and at most one body. Numbered originals take one
counter value; `numbering: none` takes none. Reuse can precede
the original declaration, including in another scope or on another page. It
inherits the original numbering, series, and counter scope. Two declarations
with the same `id:` are an error; choose `of:` deliberately for reuse.

An [omitted original](review-comments.md) has no query identity or counter value.
Its attached body and reused markers disappear even across scopes or forward
declarations; their passages remain. References to its ID report omission.

The [small example](../../examples/mark-and-body.typ) shows the common interface.

Optional [annotation data](note-data.md) belongs to the same creation owner:
use `data: (...)` on an original, a creating wrapper, or a standalone body.
Attached bodies and reused marks inherit it in every declaration order.

| Function | `id:` | `of:` |
| --- | --- | --- |
| `deixis-mark`, specialized inline/region/phantom marks | Declare the original mark and counter owner | Add an occurrence of an original annotation |
| Footnote/endnote/margin/inset/sidenote wrapper | Create a named original mark and its body | Attach only a body to an original mark |
| A `-body` function | Declare a named standalone body, without a mark or counter | Attach a body to an original mark |

All identity arguments are named, and `id:` and `of:` are mutually exclusive.
Both accept nonempty strings or native Typst label values such as `<idea>`.
Public IDs also share Typst's document-wide namespace with other native labels.
`deixis-ref` keeps native-style positional reference targets.

Block `id:` values belong to a separate [scope namespace](scopes.md). They name
rendering/counter contexts and do not publish native reference labels. Pin scopes
also remain independent from annotation and block IDs.

For repeated Touying frames, use private wrapper identities or the
[frame-local label recipe](touying-identities.md). Literal IDs remain
document-wide; a computed native label works with the same `id:`/`of:` API.

## Note, Attachment, And Pin Names

An attachment ID can coexist with a note ID, including the same spelling.
They name different objects; selecting one never falls back to another namespace.
Strings and labels with the same spelling agree within each namespace.

| Name | Declared by | Selected by |
| --- | --- | --- |
| Annotation ID | Note/mark/standalone-body `id:` | `of:`, `@name`, or connection `(mark: id)` / `(body: id)`; bare connection IDs mean original mark in `from` and body in `to` |
| Attached node ID | `deixis-attach(id: ...)` | Connection `(node: id, scope: ..., page: ...)` |
| Pin name | `deixis-pin(name)` or attachment `pins:`/scanned text | `(pin: target)` for endpoints, ports and waypoints; ordinary pin targets for regions/anchors |
| Scene-local node ID | A `deixis-routing-scene` / routing `nodes:` entry's `id:` | Numeric scene routing; it creates no document `(node: ...)` alias or native reference |

Attachment IDs are unique within an attachment scope on one physical page.
Attachment `scope:` also namespaces its generated pins; it does not scope note
IDs or counters. An attachment or pin alone does not create a note, counter, or
native `@name` reference. See [document routing](document-routing.md#select-endpoints-and-sockets).

Wrapping a note does not merge the wrapper and note frames. A wrapper around a
live flow body captures that flow frame. If registered for avoidance, it remains
a separate obstacle for a connection selecting `(body: id)`, even with the same
name. Select `(node: id)` when the wrapper is the intended endpoint; use
`behavior: "ignore"` when it only supplies naming/pins. To register an existing
note body itself, prefer `deixis-routing(nodes: ((body: id),))`.

An overlay body declaration has no native body footprint. Wrapping that
declaration captures its empty declaration frame, not the later painted body.
Use the body selector for its accepted painted geometry. Avoid/cut/cross nodes
require positive rectangles. `behavior: "ignore"` permits an empty declaration
frame, but does not give it the painted body's geometry.

## Declaration Order And Forward Lookup

An original mark (`id:`), its attached body (`of:`), and reused marks (`of:`)
may appear in any order. All six orderings of those three operations are
supported, including reuse across scopes and pages. For example:

<!-- deixis-example: {"id": "example-3", "height": "180pt", "margin": "(left: 18pt, right: 130pt, y: 18pt)"} -->
```typst
#deixis-mark(of: <idea>)[Earlier passage]
#deixis-margin-note-body(of: <idea>)[One explanation.]
#deixis-mark(id: <idea>)[Original passage]
```

Only a numbered original advances the counter, at its declaration point. An
earlier body or reused mark inherits its marker; it does not reserve another
number.
Reuse may also precede a wrapper whose `id:` creates both the original and body.
Inline, region, and phantom marks all follow this contract.

Forward lookup resolves identity; each adapter still chooses placement:

| Body adapter | When its declaration precedes the original |
| --- | --- |
| Margin, foreground/background | Follows the original mark or selected pin; packing may spill to later existing pages |
| Margin, flow | Stays on the declaration page; a distant original cannot move it to another page |
| Footnote | Reserves native footer space at the body declaration |
| Inset | Uses the declaration page by default; explicit pin/placement options retain their usual behavior |
| Inline | Appears in native flow at the body declaration |
| Endnote | Appears at an eligible printer |

See [body ownership](ownership.md) for placement details and
[rendering limits](rendering.md) for native footnote allocation requirements.
Forward lookup does not remove those limits or Typst's finite layout-pass limit
for contextual declarations inside deferred bodies.

These rules still apply in either declaration order:

- One annotation has one original and at most one attached body. A wrapper with
  `id:` already supplies both, so attaching a second body is an error.
- A `-body(id: ...)` call creates a standalone body, not a placeholder for a later
  original. It cannot be reused as a numbered mark or receive an attached body.
- An unresolved `of:` is an error. Mixing `id:` and `of:` within a single call is
  also an error; the flexible order applies to separate calls.

## Choosing A Mark Form

`deixis-mark` creates and reuses every current mark form:

<!-- deixis-example: {"id": "example-4"} -->
```typst
#deixis-mark(id: <term>)[An inline passage]
#deixis-mark(id: <formula>, mark-type: "region", inline: true)[$x^2$]
#deixis-mark(id: <quiet>, mark-type: "phantom")

#deixis-mark(of: <term>)[Another passage]
#deixis-mark(of: <term>, mark-type: "region", inline: true)[$y^2$]
#deixis-mark(of: <term>, mark-type: "phantom", occurrence: <point>)
```

The default is inline; supplying `pins:` selects region mode under `auto`.
Content alone keeps the inline default. The specialized `deixis-inline-mark`,
`deixis-region-mark`, and `deixis-phantom-mark` remain descriptive alternatives.
They share original/reuse behavior with the unified function.

With neither `id:` nor `of:`, a mark is anonymous decoration and does not advance
a counter. A wrapper without `id:` still creates an original note using an
automatic identity; `numbering: none` makes it unnumbered. Give the wrapper an ID when it should be selected later.

See [shared notes](shared-notes.md) for local/component styles, region geometry,
occurrence names, and backlinks. Reused marks never create another body or
inherit the body's drawn connector.

## Bodies And Native References

A separate body can precede its original mark:

<!-- deixis-example: {"id": "example-5"} -->
```typst
#deixis-footnote-body(of: <detail>)[An explanation.]
Here is the original#deixis-mark(id: <detail>).
```

An unresolved `of:` is an error. Use `id:` when a body is intentionally standalone:

<!-- deixis-example: {"id": "example-6", "height": "180pt"} -->
```typst
#deixis-inset-note-body(id: <aside>, layer: "foreground", dy: 30pt)[An independent aside.]
#link(<aside>)[Read the aside.]
```

A standalone body has no counter owner and cannot supply a reused numbered mark.
`deixis-ref(<aside>)[Aside]` links to it; a bare marker reference uses `?`.
An attached wrapper accepts one `[body]` argument. Two passages are rejected
because `of:` does not create another mark.

Attached wrappers and `-body` functions share the same defaults: omitted/auto
`target:` inherits the original mark's exact rendering scope and block instance,
including within a thread. An explicit `target: 0` chooses the calling scope;
a named target chooses another one. This changes body rendering, while the
original keeps its counter owner, series, and number. Forward declarations use
the same rules, and each adapter retains its placement policy.

Configure `series:` on the original mark. Attached bodies and wrappers accept
omitted/auto series; a string is rejected even if it matches the original. A standalone `-body(id: ...)`
may choose a collection series without creating a counter. Attached wrappers
also reject non-default mark-only settings: `numbering`, `marker`, `mark-type`,
`marker-position`, `inline-mode`, `pins`, `padding`, `region-shape`, and `inline`.
Use `deixis-mark(of: ...)` for a decorated additional occurrence. Body styling,
containers, placement, backlinks, and connectors stay on the attached body or
wrapper. `layer:` remains a body option on footnote/margin/inset/sidenote wrappers;
the endnote wrapper's layer applies only to its region mark, so omit it with `of:`.

A named body publishes its canonical ID as an actual native label at its painted
location. `@idea`, `deixis-ref(<idea>)`, native `link(<idea>)[...]`, and
`query(<idea>)` therefore refer to the same annotation. Measurement publishes no
extra destinations. Before a body is printed, package references can fall back
to its original mark; a native public body label exists only after live painting.

## Connections And Occurrences

Keep `connector:` on the body for the usual original-mark-to-body edge. It selects
the original even when a reused mark appears first. Reuse has no automatic edge.
Name an occurrence and select it explicitly when another connection is wanted:

<!-- deixis-example: {"id": "example-7", "prelude": "#deixis-inset-note(id: <idea>, layer: \"foreground\", width: 100pt, dx: 150pt, dy: 45pt)[Original passage][One explanation.]", "height": "180pt"} -->
```typst
#deixis-mark(of: <idea>, occurrence: <again>)[Another passage]
#deixis-connect(from: (mark: <idea>, occurrence: <again>), to: <idea>)
```

Occurrence names are local to an annotation and do not create another public
note identity. Extra explicit edges are additive. See
[independent connections](independent-connections.md).

## Marks Inside Note Bodies

A body can contain another original mark with its own `id:` and body. Existing
declarations register in source order at the body's declaration point; painting
still determines their geometric anchors. See
[notes inside notes](../../examples/notes-inside-notes.typ).

Preparation does not execute contextual callbacks or move registrations across
Deixis state updates. Such declarations retain live ordering and Typst's finite
layout-pass limit. Private internal keys are opaque; select annotations through
public IDs.

## Migrating To 0.2

For container, connector, pin and outline changes as well, see the consolidated
[compatibility and migration guide](compatibility.md#migrate-from-011).

| Previous call | New call |
| --- | --- |
| `deixis-endnote(label: <n>)[Body]` | `deixis-endnote(id: <n>)[Body]` |
| `deixis-endnote-body(id: <n>)[Body]` attached to a mark | `deixis-endnote-body(of: <n>)[Body]` |
| `deixis-endnote(id: <n>)[Body]` attached to a mark | `deixis-endnote(of: <n>)[Body]` |
| `deixis-endnote-body(label: <aside>)[Body]` standalone | `deixis-endnote-body(id: <aside>)[Body]` |
| `deixis-repeat-mark(<n>)[Passage]` | `deixis-mark(of: <n>)[Passage]` |

When a mark had one ID and its body had a different label, use the original ID
throughout and update references/connections that selected the old alias. The
removed repeat name and positional identity shorthand have no compatibility
aliases in the 0.2 API.

Remove `series:` and mark-only options from attached calls; put them on the
original mark, or on a separate reused mark for local decoration. Older attached
wrappers defaulted to the caller's scope; add `target: 0` when that behavior was
intentional. Omitted targets now inherit consistently with `-body(of: ...)`.
