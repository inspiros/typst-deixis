# Routing Scenes

Examples assume the package import from [getting started](getting-started.md#1-start-with-native-footnotes).
Numeric geometry needs no setup; document selectors need the standard setup too.
Excerpts with callback variables extend the surrounding example.

Use a prepared scene when routing between your own shapes or around fixed objects.
Resolved `bounds` need no note setup, counters, pins or document queries. For
existing content, the same constructor also accepts explicit mark, body and pin
selectors in a `context` with `deixis-setup-notes`. These read accepted geometry;
they do not render or measure the content again.

```typst
#let scene = deixis-routing-scene(nodes: (
  (id: <a>, bounds: (left: 0pt, top: 20pt, right: 40pt, bottom: 50pt)),
  (id: <b>, bounds: (left: 200pt, top: 20pt, right: 240pt, bottom: 50pt)),
  (bounds: (left: 80pt, top: 10pt, right: 120pt, bottom: 70pt)),
))
#let path = deixis-route(scene: scene, from: <a>, to: <b>, route: "orthogonal")
#assert.eq(path.status, "ok")
```

Prepare and place the result as in [numeric routing](numeric-routing.md).
[The small drawing example](../../examples/routing-scene.typ) includes a cut node.
Prepare the scene once and reuse it for several routes. Node bounds stay fixed;
routing cannot move or pack content.
Use [group routing](route-groups.md) when several explicit orthogonal fragments
should consider each other's shafts. Separate `deixis-route` calls remain independent.

## Measured Document Nodes

Use selectors instead of `bounds` to borrow existing document geometry:

```typst
#context {
  let scene = deixis-routing-scene(nodes: (
    (id: <source>, pin: <figure-port>),
    (id: <target>, body: <explanation>),
    (id: <obstacle>, pins: (<top-left>, <bottom-right>)),
  ))
  let path = deixis-route(scene: scene, from: <source>, to: <target>, route: "orthogonal")
  if path.status == "ok" {
    let request = deixis-prepare-connector(path, heads: "triangle")
    deixis-absolute-place(top + left, dx: path.origin.first(), dy: path.origin.last(),
      deixis-render-connector(request))
  }
}
```

See [Routing Measured Content](../../examples/document-scene.typ) for a complete
small example with `deixis-attach` corner pins and an annotation body.

Declared connections can register the same selectors through
[`deixis-routing(nodes: ...)`](document-routing.md#register-existing-notes-and-pins).
That scope combines the selected geometry with live attachments before planning
its individual connections; no separate scene callback is required.

| Selector | Geometry |
| --- | --- |
| `mark: <note>` | Original mark; add `occurrence:` for a named inline, phantom or region reuse |
| `body: <note>` | One accepted margin, inset or nonbreaking inline frame, with a complete live span/destination |
| `body: <note>, point: "start"` or `"end"` | A live boundary point, also for printed footnotes/endnotes and paginated bodies |
| `pin: target` | One exact pin point, using existing name/scope/select/page rules |
| `pins: (target, ...)` | Rectangle around selected pins on one page, including producer padding |

Choose exactly one selector or numeric `bounds`. Optional `padding` expands the
resolved document bounds; it accepts signed lengths or the existing edge
padding dictionary and resolves in the constructor's font context. `pin:` uses
the exact coordinate independently of producer padding; `pins:` follows region
padding semantics. A positive padding can turn a point into an area obstacle.

Point/zero-area document nodes default to `behavior: "ignore"`; rectangular
nodes default to `"avoid"`. An ignored point also works with literal numeric
bounds. Only `ignore` permits zero-area bounds. Named point endpoints have a free
normal by default; an explicit `side:` constrains their departure/arrival.

Document selectors preserve existing strict frame rules: they do not approximate
a paginated/fragmented body with a union of distant rectangles. Use body start/end
points when a full frame is unavailable. Multi-page regions require explicit
`page:` and use that native region fragment's bounds. Raw pin bounds cannot
combine pages. An explicit page on a single frame/point must match its actual page.
Missing, ambiguous, unprinted or unusable targets receive diagnostics.

Layer controls painting. An explicitly selected node participates regardless of
its body's layer; the scene does not discover or pack other layers' contents.
Use the scene for drawing after geometry is accepted. Feeding its result back
into body size/placement can create a layout cycle; native convergence limits
still apply. Extra live observers of late route evidence can consume another
layout pass, especially with immediate margin bodies; inspect diagnostic results
outside document layout when possible.

Hidden nodes have no fabricated bounds, contribute no obstacle, and remain named
so a route selecting one can return `status: "endpoint-hidden"`. Callers can
skip painting that result. The other registered nodes remain usable. Forward
selectors work; constructor position does not determine the selected body page.
Native drawing still follows the caller's placement/layer order.

Document nodes infer search bounds from captured page frames when available.
Explicit `pages:` entries override those bounds. Pure numeric nodes never acquire
an implicit document coordinate plane or query dependency. Explicit registration
is required: text, arbitrary figures and other note bodies do not automatically
become obstacles. Existing note connectors do not silently opt into this engine.

## Scenes In Document Connectors

Add `scene` to an ordinary note's `connector` or to `deixis-connect`. The small
[Notes Around Figures example](../../examples/scene-connectors.typ) uses:

```typst
connector: (
  route: "orthogonal", radius: 0pt, heads: "triangle",
  scene: _ => deixis-routing-scene(nodes: (
    (mark: <detail>), (body: <detail>), (pins: (<tl>, <br>)),
  )),
)
```

`scene` accepts `none` (default), a prepared `deixis-routing-scene` value, or a
function taking the current document/page-fragment record and returning that
value. The function runs after visible endpoints and the active physical page
are selected. It can use `doc.page`, `doc.fragment`, `doc.nodes`, `doc.layer` and
`doc.continuation`; custom shaft painters receive these fields as
`request.route.document`. The scene callback sees the preferred endpoints;
the final painter/marker sees any selected replacement. A continuation preference
is retained in `continuation.allocation.preferred`. Keep the function read-only:
return geometry rather than drawing content or moving a body. Native layout may evaluate it again while
converging. Hidden endpoints/declarations and disabled routes do not evaluate it.
Prepare a shared scene in `context` when several edges can reuse it.

Only the current physical page's nodes participate. An absent page is an empty
plane; unpaged nodes never become global obstacles. An active avoidance node
requires sharp orthogonal routing, `radius: 0pt`, and point-only active waypoints.
Native `radius: auto` enables rounding and is rejected for avoidance; it retains
its ordinary stroke-dependent value on pages without avoidance nodes.
Explicit pins/waypoints remain hard visits, including the selected half around
`"split"`. With margin `via: auto`, the planner replaces the adapter's synthetic
lane waypoints while retaining the accepted body position and attachment policy.
The geometric port choice is tried first. If it is blocked or unreachable,
one fallback search can use the adapter's other automatic ports. A successful
preferred route stays unchanged, even when another port could be shorter.
Inset and independent framed endpoints can have alternatives. Ordinary margin
inline exits retain their text-line policy; a region exit can slide along its
existing outward side, and its body can slide within the existing safe span of
the inner border. Bodies stay in their accepted positions.

Explicit `connector.ports` constrain that endpoint: a pin socket or percentage
stays exact, and a selected side never changes sides. With `at: auto` (also the
default for a bare side), a blocked/unreachable preference can slide along that
side. The gap and outward normal stay fixed. Explicit `at: 50%` or a pin socket
locks the point. Successful preferred routes are retained without sliding.
Numeric `deixis-route` endpoints also retain their existing fixed-port contract.
The fallback minimizes shaft length plus bend penalties over permitted discrete
choices and finite visibility projections along permitted sides (plus displacement
cost for an automatic continuation). It shares the
preferred search's expansion allowance; there is no per-port-pair search loop.
See [An Exit Along The Same Side](../../examples/sliding-ports.typ) for a compact
example. Visibility candidates do not guarantee a globally shortest continuous
attachment; they preserve the bounded candidate-graph contract.
Without avoidance nodes on the active page, ordinary native routing is preserved,
including margin lanes, curves and mixed sections; `search` is `none`.

Registering the endpoint through its matching `mark:`/`body:` selector permits
only its outward attachment stub through its own clearance pocket. Existing
positive port gaps work too. This association follows the exact annotation,
occurrence or selected body point, never an arbitrary enclosing box. Numeric
boxes and `pins:` rectangles are independent obstacles. Interior/custom sockets
and padding that encloses the attachment are not silently exempted; move the
port outside the registered frame or choose appropriate registration. Foreign
overlapping obstacles still block the stub. Duplicate matching owners receive a
diagnostic. A point pin has no outward direction by default and cannot escape
from inside an avoidance box merely by being named.

Routing and scene interactions finish before head preparation. Scene cuts merge
with manual cuts; optional connector-crossing gaps follow that preparation.
`request.route.interactions` and `scene-cuts` describe the original route, and
the native painter or a custom painter uses the same prepared shaft/heads.
No gap indicator or crossing symbol is enabled implicitly.

A blocked constrained endpoint, unavailable permitted ports/path, blocked hard
waypoint or exhausted search produces a final diagnostic naming the physical
page and failure detail. That fragment
executes no head, shaft painter or continuation marker and has no unchecked
fallback. Cross-page connectors route the existing endpoint fragments separately.
With avoidance enabled, a blocked/unreachable automatic relay can move along its
current top/bottom boundary. Explicit `("split", x-spec)` positions stay fixed;
bare `"split"` still separates exact visits and permits automatic allocation.
See [obstacle-aware continuations](connectors.md#obstacle-aware-continuations) for
selection, budgets and callback geometry. Intermediate pages receive no
extra shaft. Scene routing changes neither body packing nor layer/paint order;
independently planned connectors can still share a corridor.

## Nodes And Interactions

Each node accepts `bounds`, optional `id`, `page`, and `behavior`. Bounds require
finite absolute `left`, `top`, `right`, `bottom` lengths and positive dimensions
(zero-area points are allowed with `behavior: "ignore"`).
The optional ID is a nonempty string or label; equivalent spellings name the same
scene-local node. IDs are unique across the scene and independent of note IDs.

| `behavior` | Effect |
| --- | --- |
| `"avoid"` (default) | Prevent the planned centerline from entering its inflated rectangle |
| `"ignore"` | Retain a named endpoint without blocking or reporting interactions |
| `"cut"` | Keep the original route and hide shaft intervals inside its rectangle during preparation |
| `"cross"` | Keep the shaft and report entry/exit intervals for an optional custom painter |

Avoidance uses `route: "orthogonal"`, zero `radius`, and point-only `via`.
Rounded corners, curves and mixed sections are rejected when avoidance nodes
are present: smoothing a safe sharp corner can enter an obstacle. Scenes without
avoidance nodes support all existing native line/cubic routes and sections.
Numeric sharp orthogonal scene routes use the planner even in an empty plane.
Document connectors preserve their native route on pages without avoidance nodes.

Cut and cross rectangles use their original bounds, without avoidance clearance.
Boundary contact alone is not an interior crossing. Native cubic roots preserve
loops and repeated entries without fitting a new curve. Interactions are recorded
against the original geometry, before head trimming and any cuts. A cut applies
to the shaft; it does not hide heads, node ink, labels or custom decorations.

Successful scene routes add `interactions`, sorted by distance then node order.
Each entry contains `node` (normalized ID or `none`), `index` (zero-based scene
node index), `behavior`, `page`, `from`, `to`, `entry`, `exit`. Distances are along
the original drawable route; entry/exit points use its source-local frame.
`scene-cuts` holds the cut intervals. Preparation merges these with explicit
`cuts`, retaining the original route and the existing head/trim/gap contracts.

No crossing decoration or line jump is enabled implicitly. For example, a custom
painter can draw a small symbol at selected `request.route.interactions` entries.
Omit the symbol to keep ordinary cuts plain. Connector-to-connector crossing
groups remain a separate [document feature](connectors.md#automatic-gaps-at-line-crossings).
Independent avoiding routes can still share a corridor; they do not jointly
optimize congestion or reserve lanes.

## Endpoints And Clearance

Plain numeric endpoints keep their existing behavior. A node ID is shorthand for
a midpoint port on the side facing the other endpoint's center, choosing the
larger horizontal/vertical displacement (horizontal wins ties). This is a stable
simple choice, not a search over all possible ports. Specify a side when needed:

```typst
from: (node: <a>, side: right, at: 25%),
to: (node: <b>, side: left),
```

`side` accepts `auto`, `left`, `right`, `top`, `bottom`. `at` defaults to `50%` and
ranges from `0%` to `100%`: top to bottom on vertical sides, left to right on
horizontal sides. A custom exact port can instead use
`(point: (40pt, 30pt), normal: right, owner: <a>)`. On an avoidance node it must be
on that node's original border with an outward cardinal normal.

`clearance` defaults to `4pt` and expands every avoidance rectangle. The short
outward endpoint stub is exempt from its own node only. Other nodes, including
overlapping ones, still block it. `escape` defaults to `4pt`, must be positive,
and sets the minimum stub length and nearby detour rails. An owned stub extends
at least through the clearance pocket.

Clearance concerns the **centerline**, not shaft thickness, head ink or custom
node ink. Increase it to account for those when appropriate. Exact-clearance
boundary channels remain available, including touching inflated rectangles.

## Pages And Failures

The default plane has `page: none`. Positive `page` values identify independent
physical page planes; coordinates always start at that page's own origin.
Unpaged nodes do not become global obstacles on physical pages. Equal coordinates
on two pages never imply a collision between them.

```typst
#let scene = deixis-routing-scene(
  nodes: (
    (id: <a>, page: 1, bounds: first-box),
    (id: <b>, page: 2, bounds: second-box),
  ),
  pages: (
    (page: 1, bounds: (left: 0pt, top: 0pt, right: 600pt, bottom: 400pt)),
    (page: 2, bounds: (left: 0pt, top: 0pt, right: 420pt, bottom: 300pt)),
  ),
)
```

Named endpoints infer their shared plane. Supply `page: 1` to `deixis-route` for
numeric endpoints on that page. A node on an undeclared page still establishes
its plane with unbounded search. `bounds` on the constructor limits the unpaged
planner; `pages` supplies per-page search bounds. Bounds constrain avoidance
search, not arbitrary native curve painting or clipping.

A numeric route connects one plane. Connecting `<a>` directly to `<b>` in the
example above is rejected. Compose separate fragments with explicit boundary
ports, or use the existing document connector's endpoint-page continuations.
Document connectors can now apply `connector.scene` separately to both existing
endpoint fragments, including fallback allocation of automatic horizontal
boundary ports. Joint paired-boundary planning and intervening-page fragments
remain future work. See
[continuation markers](connectors.md#page-continuation-markers).

Successful scene routes have `status: "ok"`, `page`, and `search` statistics
(`none` for an ordinary non-planned route). A failed route/search returns
`kind: "deixis-route-failure"`, `status`, `detail`, `page`, `stats`; it has no
drawable geometry. Status is `endpoint-blocked`, `waypoint-blocked`, `no-path`,
or `budget`; a hidden document endpoint returns `endpoint-hidden`. Inspect this before preparing a route. Preparation rejects failures
instead of painting an unchecked fallback through an obstacle.

The first bounded implementation accepts 128 scene nodes, eight exact waypoints
per planned route, 65,536 candidate lattice cells and 50,000 expansions. Adjust
`max-cells`/`max-expansions` on the scene explicitly if needed. Candidate cells
are not eagerly materialized: interval indexes are prepared once, and each search
tests only expanded adjacent edges. `bend-cost` is a nonnegative length, default
`12pt`; score is Manhattan route length plus this cost per bend. Search is optimal
over the finite candidate graph with its cardinal ports, ordered visits and no
immediate U-turns, not over arbitrary continuous geometry.

Arc-length cuts and interactions use the native backend's approximate length and
`0.00001pt` cleanup precision. Node curves, stroke-aware clearance, safe smoothing,
body packing and automatic flow/cross-layer packing remain separate work.
[Numeric groups](route-groups.md) add bounded joint congestion planning;
[document routing](document-routing.md) collects individual declarations and
registers native content frames in place.
