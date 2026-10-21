# Local scopes inside note bodies

Examples use the [standard import and setup](getting-started.md#1-start-with-native-footnotes).
Excerpts with existing IDs or callback variables extend the surrounding example.

A note body can contain a `deixis-block`. Its local originals have independent
numbering and rendering ownership, just as in ordinary document flow. This works
inside inline bodies, endnotes, page footnotes, and margin/inset bodies in all
three layers. A scope can be named or anonymous.

The [small example](../../examples/scoped-body.typ) puts a locally numbered inline
explanation inside a callout:

```typst
#deixis-mark(id: <reading>)[The main passage]
#deixis-inset-note-body(of: <reading>, width: 260pt, dx: 20pt, dy: 40pt)[
  #deixis-block(inset: 4pt)[
    A local detail#deixis-mark(id: <detail>).
    #deixis-inline-note-body(of: <detail>, inline: false)[Local explanation.]
  ]
]
```

The local mark can be reused before its original with `of: <detail>`. Its body
can also be declared outside the containing note using the same `of:` value;
the body adapter still determines placement. Scope names remain globally unique
and annotation IDs retain their normal document-wide namespace. A block does
not introduce implicit local ID rebinding. See [scope names](scopes.md),
[identities](identities.md), and [body ownership](ownership.md).

## Measurement and links

Margin, inset, and overlay footnote renderers measure their content before
painting. Detached sizing retains nested inline marker text and `marker-style`,
including original and reused marks, but omits their live destination metadata
and body-link lookup. Live rendering publishes the ordinary destinations and
clickable markers. This avoids waiting for a nested destination merely to size
its marker. Use `marker-style` for marker formatting that affects dimensions;
arbitrary native link show rules are not a separate captured marker style.

Custom renderers should forward the supplied note record and its measurement
flag to the standard helpers; see [custom renderers](custom-renderers.md).

## Nested Collections And Pass Limits

A block that collects local footnotes adds another layer of contextual layout.
Simple collections can work inside inline bodies, endnotes, overlay margin
bodies and native flow page footnotes. Margin and other notes directly nested
in endnote bodies also work in PDF and HTML.

Nested collections inside inset bodies or overlay page footnotes can exceed
Typst's five-pass budget. Native flow hosts can also reach that limit with
additional anonymous scopes, forward attachments or contextual declarations.
Naming a block or removing links is not a general remedy.

Prefer an inline local explanation when a nested collection does not converge,
or move the collection into ordinary document flow. A block footnote normalizes
all valid layer requests to its native collection path. In HTML, notes inside a
Deixis footnote body still exceed the pass budget; see
[output formats](compatibility.md#output-formats). See the [block guide](blocks.md)
for pagination and footer boundaries.
