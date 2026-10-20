# Drawing order within page overlays

Use `z-index` when two annotations overlap. Higher integers paint later and
therefore appear on top. The default is 0; negative values are allowed.

```typst
#deixis-inset-note(layer: "foreground", z-index: 2)[Passage][Explanation.]
```

Choose an overlay layer first: inset bodies and page footnotes default to native
`"flow"`, which retains native order. Margin bodies default to foreground.
The [small example](../../examples/z-order.typ) fixes two overlapping callouts in
place so changing one integer shows the stacking effect.

## Separate body and connector priorities

A scalar applies to the applicable overlay components of a creating wrapper.
Use the existing component dictionaries for independent control:

```typst
#deixis-inset-note(
  layer: "foreground",
  z-index: (body: 2, connector: -1),
  connector: (route: "curve"),
)[Passage][Explanation.]
```

Here the body can cover other default-priority bodies, while its connector stays
behind default-priority drawings in that overlay. `mark` selects region drawings;
`nodes` selects mark and body. Inline marks and phantom points retain native
behavior. Reused region occurrences inherit their original mark's priority and
can override it locally, without changing the original, body, or connections.

Set defaults through the usual type/component cascade:

```typst
#deixis-set(z-index: (inset-note: (body: 2, connector: -1)))
```

An attached body inherits the original declaration's ordering values, including
forward declarations. Local component values refine those defaults; a local
scalar replaces them. This does not attach another connection to a reused mark.

An explicit `connector.z-index` overrides the link component. `auto` inherits it:

```typst
#deixis-connect(from: "source", to: "destination",
  connector: (route: "curve", z-index: 3))
```

An independent connection owns its own priority. Custom connector renderers can
read the resolved integer at `request.route.document.z-index`.

## Equal priorities and groups

Equal values preserve the existing order within an overlay: regions, connections,
page footnotes, insets, then margins. Ties inside each adapter retain its existing
declaration or accepted-batch order. This preserves default output and keeps
default connectors below bodies; it is not a global source-order rule.

For one region note whose components share a priority and overlay, this means
**region mark → connector(s) → body**, from back to front. Body fills can cover
connector shafts. These phases apply across all notes; one annotation is not an
indivisible stack. A scalar priority moves its applicable components together
while preserving these ties. To put its connector above its region and body,
use `z-index: (nodes: 0, connector: 1)` on the creating wrapper.

Multiple explicit `deixis-connect` calls at the same priority paint in their
connection-declaration query order, so a later call paints over an earlier one.
Shorthand edges use their adapter's prepared order: margin edges, then inset
edges, then explicit edges. An explicit edge keeps its own priority even when
its endpoints belong to a note with a different priority; set its
`connector.z-index` when needed.

Some output must move as a whole:

| Output | Ordering unit |
| --- | --- |
| Region occurrence | Its drawing on that page/layer, including foreground markers |
| Connection | One page fragment with its highlight, shaft, and heads/custom drawing |
| Inset or built-in margin layout | One body, including its container and decorations |
| Overlay page footnotes | One native footer column per page/layer, including its groups |
| Custom margin layout | The complete output of one existing page/scope/layer callback batch |

All body priorities in an atomic multi-note group must agree. Conflicts produce
a diagnostic naming the members and their values. Set a common default or use a
function preset rather than assigning conflicting priorities to individual
members. Native page footnotes from several text columns can share one footer
column; text columns do not automatically create separate ordering groups.
Foreground and background groups are separate.

## Layer and state boundaries

Priority orders drawings **within one Deixis page overlay**. Background remains
below native flow, and foreground remains above it. Native flow bodies, immediate
regions, endnotes, block footnotes, and direct layout calls keep native order;
their `z-index` values do not turn them into page overlays. Flow bodies can still
have independently prioritized overlay connectors.

Native hiding also applies before a component paints: a higher priority cannot
reveal a covered region, body, or edge. Deferred region painters retain geometric
anchors without painting ink. See [annotation visibility](visibility.md) for native flow and deferred
callback behavior.

Overlay region markers always use foreground, including markers of background
shapes. Setup's native/user page hooks retain their order outside Deixis drawings.
No integer crosses those boundaries or escapes a host theme's composition/clipping.

Priority does not reorder packing inputs, change margin spillover rules, move a
placement anchor, or reallocate footnotes. Unchanged bodies retain their geometry.
Each live body and custom group/layout
output is emitted once. Native body traversal follows the resulting emitted
order, so shared `state` updates can change order too. If a body's text or size
depends on that state (or a renderer explicitly uses priority), its resulting
geometry can change. Keep state-dependent
logic independent of paint order when fixed geometry is needed.
