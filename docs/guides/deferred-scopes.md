# Local scopes inside note bodies

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

## Nested collections still have a pass limit

A block inside a deferred body that itself collects footnotes adds another
registration, collection, and destination chain. The reduced case converges in
an inline body and a native flow page footnote, but exceeds Typst's five-pass
budget in the tested margin/inset paths, overlay page footnotes, and endnotes.
This includes a single named block; changing the inner wrapper to a standalone
body or moving its declaration outside the scope did not repair those controls.

Prefer an inline local explanation for this layout. For a local footnote
collection, use an ordinary flowing block or a native flow host. Naming the
block or omitting links is not a general convergence fix. A block footnote
normalizes all valid layer requests to its native collection path.
These are reduced-layout limits, not a guarantee for arbitrary nested native
contexts. See the [block guide](blocks.md) for pagination and footer boundaries.

<!-- Maintainer evidence: [engineering audit](../maintainers/deferred-scopes.md). -->
