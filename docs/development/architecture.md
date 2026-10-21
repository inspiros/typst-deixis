# Architecture

Deixis 0.2.0 requires Typst 0.15.0+. `src/lib.typ` is the public facade;
underscore helpers, mutable state and internal record shapes are private.
The [user guides](../README.md) define supported behavior. The opt-in `short`
module binds public functions directly: `configure` configures settings,
`note-block` creates Deixis scopes, and native `block` remains available.
`deixis-configure` and `deixis-set` are identical aliases.

## Runtime Layers

Paths below are relative to `src/`.

| Layer | Main Modules | Contract |
| --- | --- | --- |
| Public composition | `lib.typ`, `setup.typ`, `query.typ`, `reference.typ`, `outline.typ` | Exports, page hooks, semantic queries and views. |
| Identity and settings | `core/state.typ`, `core/registry.typ`, `core/attachment.typ`, `core/targets.typ`, `core/counter.typ`, `core/config.typ`, `core/settings.typ` | Original/body identities, forward attachments, scope selection, numbering and option cascades. |
| Declaration evidence | `core/declarations.typ`, `core/visibility.typ`, `core/order.typ`, `core/occurrences.typ` | Source registration, hide ancestry, priorities and repeated-mark destinations. |
| Marks and bodies | `marks/`, `notes/` | Marks, regions, reuse and pins; native allocation and adapter-specific body declarations. |
| Layout and rendering | `layout/`, `render/body.typ`, `summary.typ` | Scope collections, accepted frames, margin packing, containers, destinations, live spans and safe summaries. |
| Paint composition | `render/commands.typ`, `overlay.typ`, `routing/overlay.typ` | Lazy commands, stable priority bands and page layers. |
| Connections and routing | `connection.typ`, `route.typ`, `route-group.typ`, `routing/` | Endpoint resolution, pure numeric paths, scenes, bounded group planning, painting and physical-page continuations. |

## Identity And Execution

`id:` creates an original annotation or a standalone body on a body-only call.
`of:` attaches a body or reuses an original mark. The original retains its assigned
counter; the body controls formatting and adapter-specific placement. Public IDs
are document-wide, including inside locally numbered blocks. Forward attachments
remain pending until final validation. Duplicate originals/bodies are errors;
references do not create mark occurrences. See [identities](../guides/identities.md)
and [body ownership](../guides/ownership.md).

Registry updates are pure state transformations. The registry is boxed in
`metadata` within `deixis-system`, keeping settings argument hashes independent
of registry size. Internal readers use `_deixis-registry(sys)`; writes use
`sys + (registry: metadata(registry))` inline to avoid repeatedly hashing the
unboxed registry. Counter scope and series use separate dictionary keys.
Settings resolution projects the selected stack/global values and accent into a
pure cascade. Callbacks and relative values retain their evaluation contexts;
executable body output must never be cached.

Declaration preparation preserves source order and reset/settings/heading
barriers. Series omission uses separate policy state so registration decisions
do not depend on the counters or bodies they would create. Omitted IDs retain
diagnostic evidence but no semantic registry/query record; edges touching them
disappear. Creation decisions remain stable through later collection printing.
See [visibility](../guides/visibility.md) and [review comments](../guides/review-comments.md).

Page-local display numbering indexes original-mark pages by counter scope and
series without changing source-ordered assigned counts. Reuse, bodies, references
and outlines share the original marker. Registry updates never depend on page
positions. See [counters](../guides/counters.md).

## Body Layout And Evidence

- Page footnotes use native allocation; flow bodies paginate, while overlays
  reserve measured space for one complete body. Local block footnotes collect at
  the block's end; endnotes use explicit printers.
- Inline bodies use native flow. Decorated bodies can wrap and paginate;
  `breakable: false` selects one connection frame.
- Overlay margins pack and spill within existing page frames. Immediate margins
  and inset callouts retain their native placement contracts.
- Measurement suppresses live destinations and paint evidence. Only real output
  should execute body effects once. Body helpers provide a destination and one
  live start/end span; semantic queries expose safe summaries, never executable bodies.
- Renderers preserve supplied content and explicit breaks. Unbreakable native
  containers cannot split oversized content.

See [rendering](../guides/rendering.md), [custom renderers](../guides/custom-renderers.md),
[queries](../guides/queries.md) and [deferred scopes](../guides/deferred-scopes.md).

## Geometry And Routing

Use accepted physical page/frame/pin geometry. Arbitrary native fragments do not
imply one enclosing rectangle; start/end spans provide points. Visibility and
navigation destinations follow painted output independently of source order.

Connections have their own layer and priority. Body shorthand selects the
original mark; explicit connections can select other occurrences, body points,
frames or pins. Page layers use stable priority/insertion bands; flow, atomic
groups and host composition keep their own boundaries.

Pure numeric routes accept resolved coordinates without document setup.
Document adapters resolve identities and geometry before shared route preparation
and painting. Avoidance and separation are explicit, bounded, sharp-orthogonal
centerline operations. Ports, waypoints and fixed splits remain constraints.
Crossing gaps and continuation indicators are independent effects; page fragments
use physical geometry and real peer destinations.

See [document routing](../guides/document-routing.md), [scenes](../guides/routing-scenes.md),
[route groups](../guides/route-groups.md) and [compatibility](../guides/compatibility.md)
for geometry, output-format and finite-convergence limits. Reproduction commands
and independent routing audits are in [CONTRIBUTING](../../CONTRIBUTING.md).
