# Deixis Documentation

<img src="../assets/logos/deixis-logo-horizontal.svg" width="260" alt="Deixis">

Annotate a passage, share its explanation, or connect objects in your own drawing.
These guides describe the **unreleased 0.2.0 checkout** for **Typst 0.15.0+**.
[Install the local preview override](guides/installation.md) before compiling
its `@preview/deixis:0.2.0` examples.

## Start Here

- [Installation](guides/installation.md): install the checkout and configure your editor.
- [Getting started](guides/getting-started.md): add a first note, share it, and choose its appearance.

Guide snippets continue a document with the package import and setup from
[getting started](guides/getting-started.md#1-start-with-native-footnotes), unless
they include their own. Fragments that require earlier declarations or a custom
callback say so; linked editable examples provide complete documents.

## Notes, Marks, And Placement

- [Footnotes and long bodies](guides/footnotes.md): native footer pagination and appearance, overlays, whitespace, breakable borders, and page/local ownership.
- [Annotation identities](guides/identities.md): create with `id:`, attach/reuse with `of:`, and declare components in either order.
- [Shared notes](guides/shared-notes.md): many inline, region, or phantom marks with one marker and body.
- [Body ownership](guides/ownership.md): what a body declaration controls for each adapter.
- [Rendering paths](guides/rendering.md): immediate placement, overlays, and native collection.
- [Regions and pins](guides/regions.md): highlight formulas/images and select spatial regions.
- [References](guides/references.md): native references, ranges, page links, and return links.
- [Table and figure notes](guides/local-notes.md): local block ownership, floated collections, and repeated headers.
- [Collected notes](guides/collected-notes.md): endnote printers, typography, groups, and pagination.
- [Margin overflow](guides/margin-overflow.md): optional checking after margin packing/spillover.

## Appearance And Extensions

- [Appearance and color](guides/appearance.md): default styling, scoped palettes, and explicit overrides.
- [Configuration](guides/configuration.md): reusable defaults, adapter/component keys, resets, and capture timing.
- [Containers](guides/containers.md): native/custom body wrappers and explicit container options.
- [Custom renderers](guides/custom-renderers.md): live body helpers, navigation, measurement, and partial output.
- [Drawing order](guides/paint-order.md): z-index, separate component priorities, and layer boundaries.

## Connections And Drawings

Begin with [Connectors](guides/connectors.md) for note shorthand, or
[Routing objects in place](guides/document-routing.md) for your own objects.

- [Connectors](guides/connectors.md): routes, side/sliding/pin ports, exact waypoints, native arrowheads, and optional cuts/crossing gaps.
- [Independent connections](guides/independent-connections.md): connect pins, original/reused marks, frames, and live body points.
- [Pin API](guides/pins.md): names, scopes, occurrence selection, padding, and attached anchors.
- [Routing objects in place](guides/document-routing.md): immediate node registration and scoped manual/avoid/separate planning.
- [Numeric routing](guides/numeric-routing.md): build and paint geometry from known coordinates, without document setup.
- [Routing scenes](guides/routing-scenes.md): fixed obstacles, accepted document geometry, and avoid/ignore/cut/cross behavior.
- [Routing groups](guides/route-groups.md): explicit orthogonal batches, repair budgets, and checked results.

Useful comparisons: [curve families](../examples/curve-routes.typ),
[Hobby curves](../examples/hobby-curves.typ), [off-curve controls](../examples/control-curves.typ),
[native heads](../examples/arrow-tips.typ), [custom ports](../examples/attached-ports.typ),
[shared lanes](../examples/shared-lane.typ), [optional crossing gaps](../examples/automatic-crossings.typ),
and [small portals](../examples/portal-continuations.typ).

## Pages, Scopes, And Presentations

- [Setup and page layers](guides/setup.md): initialization, safe reapplication, and host-owned composition.
- [Scope names and targets](guides/scopes.md): local owners, shared threads, relative and forward selection.
- [Breakable blocks](guides/blocks.md): per-page margins, block-end footnotes, and native geometry limits.
- [Scopes inside notes](guides/deferred-scopes.md): local numbering and collections in deferred bodies.
- [Counters and resets](guides/counters.md): series, shared owners, strict updates, and heading/slide recipes.
- [Annotation visibility](guides/visibility.md): Touying reveals, native hiding, component ownership, and cover limits.
- [Review comments](guides/review-comments.md): series-based omission for draft/final builds, preserved passages, and shared comments.
- [Touying frame identities](guides/touying-identities.md): frame-local IDs and references across repeated subslides.

## Queries And Custom Views

- [Selection and queries](guides/queries.md): collection boundaries, filtering, ordering, and [adaptive page headers](examples/adaptive-header.typ).
- [Outlines and custom views](guides/outlines.md): one entry per annotation, marked-page lists, and passage indexes.
- [Annotation data](guides/note-data.md): custom titles, tags, status, and catalogue fields.
- [Editorial recipes](guides/editorial-recipes.md): critical apparatus, independent source/editorial series, and first-use glossaries.

## Find A Task

| I Want To… | Read | Try |
| --- | --- | --- |
| Install the checkout or configure my editor | [Installation](guides/installation.md) | [First Notes](../examples/first-notes.typ) |
| Add my first notes | [Getting started](guides/getting-started.md) | [First Notes](../examples/first-notes.typ) |
| Remove editorial notes from a final copy | [Review comments](guides/review-comments.md) | [Review Comments](../examples/review-comments.typ) |
| Share one explanation among passages | [Identities](guides/identities.md) · [Shared notes](guides/shared-notes.md) | [Shared Notes](../examples/shared-notes.typ) |
| Annotate a presentation | [Touying integration](guides/rendering.md#presentation-frameworks) | [Touying Reveals](../examples/touying-reveals.typ) |
| Choose colors and containers | [Appearance](guides/appearance.md) · [Configuration](guides/configuration.md) | [Automatic Palettes](../examples/automatic-palette.typ) |
| Draw connections around objects | [Routing objects in place](guides/document-routing.md) | [Routing In Place](../examples/routing-in-place.typ) |
| Build a note index or custom view | [Outlines](guides/outlines.md) · [Queries](guides/queries.md) | [Note Catalogue](../examples/note-catalogue.typ) |
| Annotate headings with outlines or running headers | [Repeated headings](guides/outlines.md#repeated-headings) | [Footnotes](guides/footnotes.md#headings-outlines-and-running-headers) |

## Offline Reading And Compatibility

The [downloadable manual](manual.pdf) combines a guided introduction, 23 worked
examples with source beside compiled output, and a compact reference to all
public APIs. Setup badges distinguish document APIs, independent numeric helpers,
and conditional extension hooks. The [API reference](reference/README.md) supplies
source-derived defaults; the [agent skill](../skills/deixis/SKILL.md) includes
checked document recipes for coding agents.

Use [Compatibility and migration](guides/compatibility.md) for supported behavior,
remaining native/routing limits, and changes from 0.1.1. Maintained editable sources live in [examples](../examples/).

## Contributing

For dependencies, checks, artwork and local website commands, see
[CONTRIBUTING](../CONTRIBUTING.md). The [architecture](development/architecture.md)
explains runtime contracts; [release preparation](development/release.md) lists
packaging and manual checks.
