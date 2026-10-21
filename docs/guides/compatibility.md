# Compatibility, Limits And Migration

This guide describes the supported contract of the **unreleased 0.2.0 checkout**.
The published `@preview/deixis:0.1.1` has a different API. The manifest requires
Typst **0.15.0 or newer**; the compiler matrix is 0.15.0 and 0.15.1, with separate
Tinymist 0.15.10 editor checks and Touying 0.6.3/0.8.0 integration fixtures.
The supported behavior and remaining boundaries are described below.

## Supported Behavior

| Area | Contract |
| --- | --- |
| Identity | `id:` creates/names; `of:` attaches/reuses. An original, its body and reused marks may appear in any order. One original and at most one body per annotation. A standalone body's ID is not an original-mark placeholder. |
| Marks and references | `deixis-mark` covers inline, region and phantom forms; specialized names remain available. Reuse shares numbering/body and adds a return origin. `@id` / `deixis-ref` formats a reference rather than a measured mark occurrence. |
| Body placement | The body adapter owns placement. Margin bodies follow the mark/anchor; footnotes allocate at their native declaration/collection; inline bodies stay in flow; inset bodies use their declaration/placement; endnotes use a printer. Identity lookup does not move native allocations. |
| Invisible declarations | Overlay margin/inset and collected endnote body declarations add no flow whitespace. Page footnotes intentionally reserve space. Native `place` for flow margin/inset bodies can interrupt paragraphs. |
| Connections | Body `connector:` supplies the original-to-body shorthand. Independent `deixis-connect` calls add edges, including deliberate duplicates. Reused marks never inherit an edge. Forward endpoints and named occurrences work. |
| Continuation visuals | Default dots, optional hollow portals and suppression use the existing continuation field. Native presets support size/style and optional peer/counterpart links. Endpoint heads, including the filled open-notch `stealth`, remain independent. |
| Frames | Accepted single painted margin/inset frames and explicitly framed inline bodies provide rectangle ports. Native live body start/end points can select collected or paginated bodies. Partial, missing or duplicate geometry is diagnosed. |
| Pins and attachments | Pins, attachment IDs and annotation IDs have separate namespaces. String/label spellings agree. Pin targets share scope/select/physical-page rules. Attachments capture one live frame; equal names or containing rectangles do not merge owners. |
| Drawing order | Higher `z-index` paints later within an overlay layer. Equal priorities keep documented command/group order. Flow, foreground, background and host composition retain their separate order; grouped layouts can be atomic. |
| Routing | `deixis-route` supplies native line/cubic geometry. Scenes register fixed accepted rectangles and opt-in avoid/ignore/cut/cross behavior. Numeric groups return plans; `deixis-routing` scopes collect individual document edges. These are supported APIs in the unreleased checkout, rather than disposable experimental imports. |
| Host integration | Native hiding suppresses deferred visuals while retaining semantic identities/counters. Reapply setup after replacing native page layers, or let the host own both hooks. Touying frame-local IDs require the documented pre-layout callback recipe. |

Use [identities](identities.md), [body ownership](ownership.md),
[rendering](rendering.md), [setup](setup.md), and
[independent connections](independent-connections.md) for adapter-specific details.

## Unified Note Queries

`deixis-page-notes` is removed in 0.2. Use
`deixis-query-notes(page: here().page())`, replacing `note-type:` with
`include-types:`, `marker-str` with `marker`, and `body-type` with `type`.
Page selections default to native body order and include standalone bodies;
plain catalogue queries retain paired annotations in source order. Override
`order:` and `include-unpaired:` explicitly when needed. All modes return safe
semantic records, never executable renderer data. Incomplete/duplicate custom
spans do not provide page membership. See [query migration](queries.md).

## Routing Boundaries

Automatic avoidance is opt-in and uses registered fixed geometry. It does not
discover arbitrary text, figures or other document ink. Add attachments or select
accepted note/pin geometry with `deixis-routing(nodes: ...)`. It routes edges;
it never packs or moves those objects. Native overlay-margin packing remains a
separate body-placement mechanism. Flow-margin collision avoidance and collision
checks between body layers are not implemented.

The automatic `avoid`/`separate` policies use sharp orthogonal paths with zero
radius. Curves, rounded routes and mixed sections retain manual/native routing
and scene cut/cross interactions. `avoid` searches each edge independently;
`separate` also attempts bounded group repair. Successful plans need not eliminate
all crossings, contacts or shared lanes and are not globally optimal.

**Avoidance promises centerline clearance against registered inflated rectangles.**
Stroke width, arrowhead extents, gap indicators and custom painter ink can extend
outside that centerline contract. Increase clearance/padding or choose explicit
geometry when that ink matters. Automatic bridges, line jumps, smoothing and
general ink-aware routing remain future visual/features work. Crossing gaps and
manual cuts/indicators are optional and retain their existing settings.

Automatic continuation points stay in a page-local interval: the accepted
margin body's selected channel, or content width for other destinations.
`connector.spill` can select content/page/custom bounds. Opposite spill points
do not share a required x coordinate; use an exact split when that coordinate
is deliberate. Marker ink/badge packing
remain separate from these point bounds.

The current checked bounds are 128 scene nodes, sixteen enabled visible fragments
per routing scope/physical page/layer, and eight exact visits per searched
fragment. Search/cell/group budgets bound work and can produce an explicit
failure. No unchecked route is painted on failure. Numeric group callers inspect
each result's status before preparing/painting it; document adapters diagnose it.
Read-only planning callbacks may run more than once during native layout.

Groups are independent across physical pages, overlay layers and nested routing
scopes. Attachments remain page-wide; scoped `nodes:` lists replace the outer
list and restore it on exit. Endpoint lookup and repeated IDs on Touying subslides
retain their physical-page rules. Cross-page connectors draw source/destination
fragments only; intermediate pages have no shaft. Automatic spill points may
move within permitted boundary choices, while exact split positions, sockets and
waypoints stay fixed. Counterpart links target actual accepted peer geometry;
they do not require equal coordinates across differently sized pages.

See [document policies](document-routing.md), [scenes](routing-scenes.md),
[numeric groups](route-groups.md), and [connector continuations](connectors.md#page-continuation-markers).

## Native Layout Boundaries

Overlay placement uses existing pages; it cannot create pages for spillover.
Page footnotes use native flow by default and paginate; an opt-in overlay
footnote must fit its assigned reserved frame. Empty paragraph boundaries and parent-scope floats can prevent
native footer allocation; the package diagnoses these cases instead of inserting
whitespace. Ordinary column-scope floats have maintained support.

Local table/figure notes use `deixis-block`; float the complete block to keep
the collection with the figure. Repeated table headers reuse marks or references,
without creating originals/bodies or named occurrences again. See
[local notes](local-notes.md).

Arbitrary native fragments do not automatically become complete body rectangles.
Use `breakable: false` for a single-frame inline body, or a live start/end point
for a paginated body. Region marks retain their explicit page-fragment rules.
Wrapping a deferred overlay declaration names its empty declaration frame,
not its painted body; use a body selector for the latter.

Typst has a finite contextual layout-pass budget. Deep deferred note/scope/
collection chains, dense flow layouts and custom callbacks that need later
geometry can still fail to converge. Supported fixtures cover documented bounded
cases; the package does not promise arbitrary recursive layouts. Scoped native
page styles should use the host-owned hook pattern because captured decorations
do not restore automatically through nested lexical page scopes.

See [footnote/rendering limits](rendering.md#footnote-ownership),
[paginated blocks](blocks.md), [scopes inside notes](deferred-scopes.md),
[custom renderers](custom-renderers.md), and [scoped page styles](setup.md#host-owned-or-scoped-page-styles).

## Output Formats

Deixis targets paged output: PDF, PNG and SVG. Typst 0.15's HTML export is
experimental and has no pages or page layers. With `--features html --format
html`, Deixis keeps every annotation body and its navigation, and drops geometry:

- Page footnotes, including overlay layers, print in Typst's footnote section.
- Margin, inset and comment bodies follow the document as one list,
  `<aside class="deixis-notes">`, in declaration order.
- Endnote printers and block-local footnotes print `<ol class="deixis-notes">`
  lists where they run, without separators or spacing.
- Markers link to their bodies, and body markers and backlinks return to the
  marks through `deixis-mark-*`/`deixis-body-*` ids. References and note
  outlines link the same way; outlines omit page numbers.
- Inline decorations keep native underline and highlight. Box and parenthesis
  edges, region shapes, pins, connectors and other page paint are omitted
  without diagnostics.

See the [HTML endnote example](../../examples/html-endnotes.typ). After installing
the unreleased 0.2.0 checkout, compile it with:

```sh
typst compile --features html --format html examples/html-endnotes.typ target/html-endnotes.html
```

The body marker itself is a return link even with the default backlink setting;
`backlink: true` adds a separate return button. Each selected series has its own
list, and separate printers retain print-once ownership.

Built-in renderers and containers emit plain inline text. Custom renderers,
containers and margin layouts, and direct drawing calls such as
`deixis-render-connector` or `deixis-absolute-place`, run as written; Typst
warns about layout elements in them that HTML ignores, as it does for the
document's own `set page` rules. Typst also drops placed content (`place`,
floating figures) from HTML, including annotations declared inside it. Page
references (`form: "page"`) and Touying slides have no HTML equivalent.
Page-local numbering has no page boundaries in HTML and displays one continuous
sequence per counter owner and series. Margin, inset and inline notes, Deixis
footnotes and native footnotes declared inside an endnote body converge in PDF
and HTML, as do margin notes inside margin bodies. HTML footnotes cost Typst
another layout pass, so documents near the convergence budget can fail in HTML
even when paged output converges: Deixis notes declared inside a Deixis footnote
body work in PDF but exceed the budget in HTML, where a nested footnote can also
report a missing native footer allocation. Long forward-attachment chains retain
the same convergence limit.

Tagged PDF output, including `--pdf-standard ua-1`, compiles without
diagnostics. Native footnotes are tagged as notes beside their marks, and
markers are tagged links. Overlay bodies (margin, inset and comment notes) are
painted in a page layer, so assistive technology reaches them after the page's
flow content, without a note role. When explanations must be read beside their
marks, prefer native footnotes or inline notes; endnotes read as a list where
they are printed.

## Known Limits And Future Directions

- **HTML export:** upstream export remains experimental. Deixis preserves note
  bodies and navigation through a semantic fallback, while page geometry and
  connectors are omitted. Broader HTML support depends on export maturity;
  custom layouts and placed content retain the limits described above.
- **Accessibility:** overlay bodies follow page-flow content in tagged PDFs and
  lack a note role. Improving their reading order and semantic association is an
  open direction; use native footnotes or inline notes when reading beside the
  mark is essential.
- **Margin collisions:** flow margins have no collision packing, and body layers
  have no shared collision checks. More general packing remains future work;
  overlay-margin packing already operates within existing frames.
- **Shared margin planning:** document-wide planning could reduce repeated work,
  but requires context-correct measurements and bounded feedback. A shared plan
  is not part of the current contract; executable bodies cannot be cached safely.
- **Convergence:** Typst's finite layout-pass budget bounds deep deferred scopes,
  forward attachments and geometry-dependent callbacks. Page-local numbering and
  HTML footnotes also depend on layout passes. Reducing feedback depth remains a
  direction for improvement, without a guarantee for arbitrary recursive layouts.

## Migrate From 0.1.1

Install the checkout's `0.2.0` preview override and update imports first. The
installer keeps the old `0.1.1` cache separate. See
[installation guide](installation.md).

| Previous usage | 0.2 contract |
| --- | --- |
| `label: <n>` on a note | Use `id: <n>` for creation. There is no secondary body alias; update references to the original ID. |
| A body/wrapper `id: <n>` intended to attach to an original | Use `of: <n>`. Body-only `id:` creates a standalone body; wrapper `id:` creates an original and body. |
| Attached body/wrapper relies on the caller's scope | It now inherits the original rendering instance. Set `target: 0` deliberately to select the caller's scope. |
| `series:` or original-mark options on an attached body/wrapper | Put creation options on the original; local repeated-mark decoration belongs on the reused mark. |
| Attached inline body inherits the original's marker callback | Its marker now follows local body options and body-declaration defaults, consistently with the other adapters. Pass `marker-style:` on the body to deliberately reuse a custom callback. |
| The style component key `link`, as in `stroke: (body: ..., link: ...)` or `z-index: (link: 2)` | Use `connector`, as in `stroke: (body: ..., connector: gray)`. The old key is diagnosed. |
| `link`, `link-ports`, `link-waypoints`, `link-marks`, `link-heads` on margin/inset notes or `deixis-set` | Use `connector`. A route name is shorthand: `connector: "curve"`. Otherwise `connector: (route: ..., ports: ..., via: ..., heads: ...)`; `link-marks: "body"` becomes `heads: "stealth"`, `"both"` becomes `heads: (mark: "stealth", body: "stealth")`. Note records merge with `deixis-set(connector: ...)` defaults. The removed names are diagnosed. |
| Page footnotes painted in the foreground by default | They now use native flow and paginate. `deixis-setup-notes.with(override-page-footnotes: true)` restores the overlay default; `layer:` still selects one note's layer. |
| `deixis-set(separator:, clearance:, gap:)` for page footnotes | Page footnotes share the native footer; use a document-level `set footnote.entry(...)`. The Deixis options still style block collections and endnotes. |
| Page footnote bodies copy the declaration's text style | They use the native footer typography, so notes in headings or emphasized text print as ordinary footnotes. Margin, inset and endnote bodies still capture declaration typography. |
| Margin connector implicitly follows its body's layer | Connections default to foreground independently of the body. Set `connector: (layer: "background")` when needed. |
| Flat arbitrary container arguments on note calls | Put them in `container-args: (...)`; unknown note keywords are diagnosed. Keep style options on the note. |
| Per-name scanned `padding` map | Use `pin-padding: (...)`, with `padding:` as the uniform fallback. Geometric pin padding remains separate from endpoint gaps. |
| Outline `include-celibates` and old callback records | Use `include-unpaired`; callbacks receive semantic query records and structured body descriptions. Runtime identity is `note.id`; custom fields live in `note.data`. |
| `deixis-default-render-single` / `deixis-default-render-group` | Use `deixis-aligned-render-single` / `deixis-aligned-render-group`; short aliases are `aligned-render-single` / `aligned-render-group`. No compatibility aliases. |
| `deixis-set-pin-pattern(prefix:, postfix:)` | Set delimiters on `deixis-attach`, or bind `deixis-attach.with(prefix: "[", postfix: "]")`. Default scanning still uses `deixispin` and an empty postfix. |
| `deixis-highlight-rect-region` / `deixis-highlight-ellipse-region` | Use `deixis-region-mark(stroke: none)`; add `region-shape: deixis-ellipse-region` for an ellipse. |
| `deixis-group-layout` | Choose a public group renderer through `render-group:` on settings or a collection printer. |
| `deixis-default-footnote-style` | Supply a `body-style` callback, such as `it => text(size: 0.85em, it)`. Page footnotes use native footer typography. |
| `deixis-show-refs` | Use `#show: deixis-setup-notes`, which installs the reference bridge automatically. |
| `deixis-place-anchored(internal-id: ...)` | Use public pin targets via `pin:`. Inset note adapters resolve original marks internally. |
| `deixis-minipage(margin: ...)` | Preserved: `margin` supplies internal padding (`inset: margin`, `outset: 0pt`), as in 0.1.1. Earlier external-margin wording was incorrect. |
| Internal module paths or underscore helpers | Import the public facade `src/lib.typ` (or the package). Internal source paths, mutable state and private record shapes may change. |

There are no compatibility aliases for removed `label:` or repeat-only calls.
Unknown IDs, duplicate originals/bodies and unresolved `of:` targets diagnose
rather than silently selecting a different object. Details and examples live in
[identity migration](identities.md#migrating-to-unreleased-02),
[containers](containers.md#migration-and-diagnostics), [pins](pins.md), and
[outlines](outlines.md).

The current API is supported within these limits but remains **unreleased**.
The [illustrated manual](../manual.pdf), guides, and agent skill describe this
checkout. When updating from another version, check the migration table above
and keep the imported package version consistent with the examples.

## Factory Appearance Changes

Unconfigured decorations now use muted blue-gray `#496579` instead of bright
red. Mark fills use 6% accent opacity. The margin/inset/inline marker-to-body gap is 0.25em instead
of 0.05em; native-style footnotes retain 0.05em and endnotes keep 0.75em. The larger gap can affect wrapping,
margin packing and footnote reservation. Explicit colors/gaps, body text styling
and renderer precedence remain authoritative. See [appearance](appearance.md)
for the earlier-default recipe. Automatic discrete palettes are opt-in through `deixis-set(palette: colors)`;
explicit styles retain precedence and ordinary no-palette appearance stays unchanged.
