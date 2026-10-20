# Revealing annotations

To remove editorial notes from a final copy while preserving their marked text,
use [series-based omission](review-comments.md). Native hiding below keeps
annotation identities and counter values.

With the [Touying setup](rendering.md#presentation-frameworks), ordinary `pause`
and `uncover` work around complete annotations:

```typst
#slide(setting: annotations)[
  First idea.
  #pause
  Second idea#deixis-footnote[Its note appears with its mark.]
]
```

See the [small two-frame example](../../examples/touying-reveals.typ). It reveals
a highlighted passage, inset body, connector, and page footnote together. Both
Touying 0.6.3 and 0.8.0 have maintained regression coverage.

## Native hiding

Deixis follows native `hide(...)`, including the default cover produced by Touying.
Setup follows native hiding scope so page overlays and collected notes cannot
escape their covered declaration. Independent foreground and footer content stays
visible when a hidden main-flow passage crosses a page break.

| Component inside native hide | Result |
| --- | --- |
| Inline mark, passage, or inline body | Native hiding preserves its flow footprint and execution |
| Immediate margin/inset body | Native hiding covers the local body; native placement behavior remains |
| Region drawing and marker | No visible shape or marker; geometric return anchors remain |
| Overlay margin/inset body | No live body, packing slot, or body-renderer callback |
| Page/block footnote | No queued/collected entry or footer reservation |
| Endnote declaration | Its printer omits the covered entry |
| Connection | No edge when its declaration or either selected endpoint is covered |

Covered originals still advance their Deixis counter. Reused marks retain the
original number. Native Typst footnote numbering stays independent. Native
queries can still see hidden metadata and semantic identities; hiding does not
remove declarations from the document. Flow bodies also keep native state
effects while covered, whereas omitted deferred bodies do not execute their
live callbacks.
Immediate flow region callbacks can also execute under native hide; deferred
region shape/marker callbacks are omitted. Hiding an endnote printer covers its
native output and suppresses connections to those hidden bodies, while retaining
native execution and print-once ownership.

Use Touying `only` when the complete annotation should be absent from other
frames, including its declaration and counter increment:

```typst
#only("2-")[Text#deixis-footnote[Present from frame two onward.]]
```

## Each component owns its declaration context

A creating wrapper normally puts its mark and body in the same cover. With
separate calls, a covered mark does not automatically hide a body declared
outside that cover:

```typst
#hide[#deixis-mark(id: <shared>)[Covered passage]]
#deixis-inset-note-body(of: <shared>, layer: "foreground")[Visible explanation.]
```

Both shorthand and explicit connections to the covered mark are omitted.
A visible reused occurrence can independently connect to that same visible body.
Covered regions retain their location anchors so separately visible bodies can
still position and link correctly. Covering only a connection leaves its nodes
visible. These rules apply to foreground and background connections equally.

A pin used as a connection endpoint follows its own declaration's hiding context.
A pin used only as a waypoint, socket, or region boundary supplies geometry;
its hiding context does not implicitly cover the consuming component.

## Other cover effects and frame identity

This integration follows native hide. A non-hiding cover stays visible; ordinary
inherited text color is captured with declaration typography by margin, inset,
inline and endnote bodies. Page footnotes use the native footer typography, so a
tinting cover leaves their bodies untinted, as it does `std.footnote` entries. Arbitrary fading,
opacity, clipping, or custom cover functions are not automatically transplanted
onto independent page-overlay drawings.

Touying resolves its animation markers before layout. Markers generated later
inside opaque contextual note content still need Touying's supported callback
forms; capturing hide does not run the host parser inside a live note body.

Use wrapper-created private identities in repeated frames. Literal explicit IDs
remain document-wide: copying the same original `id:` into several frames is
still a duplicate declaration. For shared marks, decoupled components, and local
references, the [frame-local label recipe](touying-identities.md) uses Touying's
pre-layout callback and ordinary native labels. The meaning of `id` and `of`
stays the same.
