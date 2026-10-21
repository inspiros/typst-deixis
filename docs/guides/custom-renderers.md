# Custom body renderers

For a border or background, use `container-func` and keep the built-in renderer.
To replace the marker/body layout, supply `render-single`. A small complete
renderer uses two helpers. Pass the record supplied to the renderer; semantic
`deixis-query-notes` records contain summaries, not live renderer data:

```typst
#let card(note, ..args) = block(inset: 8pt, fill: gray.lighten(95%))[
  #deixis-generate-body-marker(note)
  #deixis-generate-body-content(note)
]
#deixis-inset-note(render-single: card)[A custom explanation.]
```

The [connected card example](../../examples/custom-renderer.typ) adds a native
reference and a connector to the body's live start point. Ordinary note calls
continue to use the built-in renderers without these helpers.

## Destination and content have separate roles

`deixis-generate-body-marker(note)` publishes the native body destination and
formats its marker. For a body without a visible marker, use
`deixis-generate-body-meta(note)` instead. Emit one of these helpers once for
that annotation. Calling both, repeating either, or duplicating a complete
built-in renderer produces a duplicate-destination diagnostic. Render a separate
annotation when it needs a second independently selectable body.

`deixis-generate-body-content(note)` returns `note.body` with live start/end
metadata. It adds no marker, destination, container, styling, or backlink. Use it
once where the body actually appears, rather than adding a second `note.body`.
It is the same content path used by the built-in renderers. To transform the
content, pass a copy with a replaced body:

```typst
#deixis-generate-body-content(note + (body: emph(note.body),))
```

Native layout supplies the locations, including continuations of a long inline,
page-footnote, block-footnote, or endnote body. A span is not a rectangle. Framed
connections still need a supported adapter and its actual single-frame evidence;
use `point: "start"` or `"end"` for a content boundary.

## What each renderer supplies

The semantic catalogue always keeps registered declarations. Painting does not
add another annotation or change the counter owner.

| Renderer output | Body destination/native ID | Live body span and page-note queries | Body connection |
| --- | --- | --- | --- |
| `note.body` alone | None | None | No live endpoint |
| Body metadata/marker plus raw body | Present | None | No complete span |
| Body-content helper alone | None | Present | Missing destination |
| Metadata/marker plus body-content helper | Present | Present | Start/end points; complete frame when the adapter supports one |

For a paired note without a body destination, `deixis-ref` and `@id` fall back to
the original mark. Original/reused markers have no body link until one is
published. A standalone body's package reference displays `?` and has no link
when it lacks a destination; its page form also displays `?`. A raw native
`link(id)` needs an actual published native label.

Catalogue `body.dest` stays `none` when the renderer omits metadata. Its
`body.start`/`body.end` can still exist when the content helper supplies a unique
complete span. The catalogue row itself links to the original mark, or to a
standalone body's destination/declaration fallback. That declaration fallback
is deliberately separate from a package reference's live-body destination.
`deixis-query-notes(page: here().page())` selects complete spans, so a
metadata-only renderer is absent from that page view.
Queries never infer a painted body from a declaration or execute the renderer.

Custom output that duplicates or omits span boundaries cannot supply a unique
catalogue span or connection point. Page queries exclude incomplete/duplicate/reversed spans,
while the unfiltered catalogue retains their declarations. No geometry is guessed from marker text.

## Measurement, allocation, and callbacks

Helpers honor `note.disable-links`: destinations and live span metadata are
omitted during detached measurement, while the body keeps its native layout.
Forward the original record so this flag survives. Do not render a second live
copy to measure it. Callbacks should accept `..args`; forward named arguments
when delegating to a built-in renderer.
Nested inline marks follow that detached sizing scope too: visible marker
styling is retained, while their live destinations and body-link lookups are
omitted. Their ordinary links remain in the actual rendered body. See
[scopes inside notes](deferred-scopes.md).

Page-footnote allocation is checked independently of these helpers. A custom
renderer may omit its destination/span or return empty content without being
mistaken for a missing native entry. See [rendering](rendering.md#footnote-ownership).

For return links, add `deixis-generate-backlinks(note)` at the intended location,
or delegate to a built-in renderer to retain its policy and formatting. A custom
renderer owns its own container, marker arrangement, and backlink composition.
The default grid group and inline-decoration bodies use their own formatting
paths; see [configuration](configuration.md#rendering-extension-points).

Explicit `deixis-generate-backlinks(note)` generates the available buttons even
when `note.backlink` is false. The built-in renderer decides whether to invoke it
according to that policy. A custom renderer owns that choice; the helper itself
does not add another destination or live span.
