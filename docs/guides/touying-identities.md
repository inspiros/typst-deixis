# Shared Notes Across Touying Frames

Wrappers without `id:` already create a private annotation on each rendered
frame. Use them for ordinary slides. An explicit literal such as `id: <idea>`
still names one document-wide annotation; replaying that original on several
frames is a duplicate declaration.

When a frame needs separate original/body calls, reused marks, or references,
compute an ordinary native label from a logical slide key, the subslide number,
and the local note name. Touying supplies `self.subslide` before layout through
its callback API:

<!-- deixis-example: {"id": "example-1", "setup": false, "prelude": "#import \"@preview/touying:0.8.0\": *\n#import themes.simple: simple-theme, slide\n#import \"@preview/deixis:0.2.0\": *\n#show: simple-theme.with(aspect-ratio: \"16-9\", config-page(\n  background: deixis-page-overlay(layer: \"background\"),\n  foreground: deixis-page-overlay(),\n))\n#let annotations(body) = deixis-setup-notes(page-overlays: false, [\n  #deixis-update-note-counter(0)\n  #body\n])\n"} -->
```typst
// Author helpers; these are not additional Deixis functions.
#let frame-id(name, frame) = label(repr(("shared-slide", frame, str(name))))
#let note(self: none) = {
  let shared = frame-id(<idea>, self.subslide)
  [
    First#deixis-footnote(id: shared)[One explanation.]
    #if self.subslide >= 2 [
      Another use#deixis-mark(of: shared).
      See #deixis-ref(shared) or #link(shared)[the explanation].
    ]
  ]
}

// Use the setup from the rendering guide.
#slide(setting: annotations)[
  #touying-fn-wrapper(note)
  #pause
  The second passage now shares this frame's note.
]
```

The [small connected-callout example](../../examples/touying-shared-notes.typ)
includes the complete imports and host-owned page-layer setup. The recipe works
on Touying 0.6.3 and 0.8.0, using the existing Deixis API.

The tuple's first value must distinguish logical slides. `self.subslide` restarts
on another slide, so give that slide another key. Serializing the tuple with
`repr` also keeps names containing punctuation or separators distinct. String
and label note names normalize through `str(name)`.

## One Label For Every Component

Use the computed label everywhere that selects the annotation:

<!-- deixis-example: {"id": "example-2", "height": "180pt", "prelude": "#let shared = <idea>"} -->
```typst
#deixis-mark(of: shared, occurrence: <again>)[A reused passage]
#deixis-inset-note-body(of: shared, layer: "foreground")[One explanation.]
#deixis-mark(id: shared)[The original passage]
#deixis-connect(from: (mark: shared, occurrence: <again>), to: shared)
```

These calls can appear in any order. Each frame has one original, one number,
one body, and its own occurrences and backlinks. A reference uses
`deixis-ref(shared)` or native `ref(shared)`; literal `@idea` continues to select
the document-wide `<idea>`, which can coexist with the computed local label.
Native `link(shared)` and `query(shared)` select its live body label as usual.

A covered deferred body has no native body label. A Deixis reference can fall
back to its registered mark; a direct native body link requires a painted body.
See [visibility](visibility.md) and [references](references.md).

## Selecting Another Frame

Choose that frame explicitly with the same helper:

```typst fragment
#deixis-ref(frame-id(<idea>, 2))
#ref(frame-id(<idea>, 2), form: "page")
```

Forward and backward references work. They select exactly that frame's
annotation; there is no implicit first/last/nearest-frame lookup. A body or reused
mark whose original is absent from its frame remains an error. Put a complete
annotation inside `only` when it should be absent from other frames, or gate all
its components together in the host callback.

## Visibility, Scopes, And Counters

Touying function callbacks control their own visibility. Placing a callback after
`pause` does not automatically cover its result. Use `self.subslide` to choose or
hide callback output, as above; keep ordinary `pause` markers visible to Touying's
parser outside opaque `context` blocks.

Identity does not change numbering or placement. Keep the usual per-frame
`deixis-update-note-counter(0)` in the slide setting when numbers should restart.
Block/minipage scopes and shared counter threads retain their existing meaning;
they do not automatically namespace note IDs. A thread can continue numbering
while each frame has distinct annotations.

Pins retain their own explicit scope. For a frame-local socket, the computed
label can be its scope too:

```typst fragment
#deixis-pin(<socket>, scope: shared)
#deixis-connect(from: (pin: (name: <socket>, scope: shared)), to: shared)
```

Prefer the host callback for computing frame IDs: it makes declarations
available before layout. Native counter reads inside `context` can also construct
labels. Successive/nested Deixis blocks now support this case; their former
scope/registry dependency cycle is fixed and covered on both host versions.
Arbitrary contextual registration chains, region/forward geometry, and larger
immediate margin layouts can still exceed Typst's finite pass limit. See
[breakable blocks](blocks.md) for the supported pagination behavior and limits.
