# Routing Objects In Place

Examples use the [standard import and setup](getting-started.md#1-start-with-native-footnotes).
Excerpts with existing IDs or callback variables extend the surrounding example.

Use `deixis-attach` to register geometry where an object is rendered, and
`deixis-connect` to declare each connection. Wrap the drawing in
`deixis-routing` to plan its connections together after layout:

```typst
#import "@preview/deixis:0.2.0": *
#show: deixis-setup-notes
#show: deixis-routing

#grid(columns: (auto, 1fr, auto),
  deixis-attach(id: <source>)[Source], [],
  deixis-attach(id: <target>)[Target],
)
#deixis-connect(from: (node: <source>), to: (node: <target>),
  connector: (heads: "triangle"))
```

The [small example](../../examples/routing-in-place.typ) adds an anonymous
obstacle and a second connection. Objects register their own accepted native
bounds; there is no coordinate list or separate rendering pass to maintain.
Connections and nodes may appear in either order. Adding a later connection can
change an earlier route: collection happens before joint planning, rather than
reserving a path as soon as its declaration is encountered.

The name `deixis-attach` covers attaching geometric anchors and routing identity
to existing content. Ordinary pin-only calls remain useful on their own; adding
`id:` opts into a selectable routing frame. There is one wrapper for both uses.

## Choose A Routing Policy

The wrapper's `policy:` selects how subsequent `deixis-connect` declarations
and enabled margin/inset shorthand connectors are planned. Its default remains
`"separate"`:

| Policy | Rules and work |
| --- | --- |
| `"manual"` | Native connector geometry, with no automatic registered-node scene, obstacle search, pair scoring or group repair. Curves, rounding and mixed route sections work. |
| `"avoid"` | Sharp orthogonal paths avoid registered objects independently. Nearby or overlapping connectors are allowed. Usually one search per fragment, with a bounded fallback for a failed preference. No connector-pair scoring, reservations or repair. |
| `"separate"` | Obstacle routing plus bounded path/automatic-socket repair, proximity penalties and collision guards. Complete separation is not guaranteed. |

Registering an attachment alone does not enable automatic search. Ordinary
connections outside a routing wrapper retain their existing native routing.
`connector.route` describes the path's geometry; `policy` chooses the planning
rules. Optional `connector.crossings` chooses a visual crossing treatment.

Use ordinary Typst show-rule scopes to change the policy midway. This excerpt
uses attachments `<a>`, `<b>` and `<c>` already registered in the drawing:

```typst
#show: deixis-routing.with(policy: "avoid")
// Subsequent connections avoid registered objects but may share corridors.
#deixis-connect(from: (node: <a>), to: (node: <b>))

#show: deixis-routing.with(policy: "manual")
// Subsequent connections use native paths without automatic collision search.
#deixis-connect(from: (node: <a>), to: (node: <c>))
```

Earlier declarations retain their captured policy. A local
`#deixis-routing(policy: "manual")[...]` temporarily overrides an enclosing
policy; the outer policy resumes afterwards. Bind reusable settings with
`#let my-rule = deixis-routing.with(policy: "avoid", clearance: 2pt)`, then
`#show: my-rule`. Each wrapper instance owns its own page/layer groups;
reusing the same bound settings does not merge separate scopes. The
[policy example](../../examples/routing-policies.typ) illustrates sequential rules.

Independent connections keep the wrapper's default sharp orthogonal geometry.
Note shorthand retains its own geometry and enabled state. `manual`
can choose another `connector.route`, whereas `avoid` and `separate` require
sharp orthogonal routes. Styling, arrowheads, manual cuts and optional crossing
gaps remain explicit connector settings. Under `manual`, attached cut/cross
objects are not processed automatically. An explicit `connector.scene` is still
a deliberate opt-in to that scene's routing and interactions. Ordinary native
geometry outside a routing wrapper retains its existing defaults.

## Deliberately Share A Lane

Choose `manual` when the path itself must be literal. Two common pins and a
polyline force the segment between them to coincide. This excerpt assumes
registered attachments `<a>` through `<d>` and the two named pins:

```typst
#deixis-routing(policy: "manual")[
  #let lane = ((pin: <lane-start>), (pin: <lane-end>))
  #deixis-connect(from: (node: <a>), to: (node: <b>),
    connector: (route: "polyline", via: lane, stroke: blue))
  #deixis-connect(from: (node: <c>), to: (node: <d>),
    connector: (route: "polyline", via: lane, stroke: orange))
]
```

Declare the two pins at the ends of a clear horizontal lane. The
[shared-lane example](../../examples/shared-lane.typ) attaches them to the drawing
and uses `connector.segments` for orthogonal approaches around an exact straight
shared segment. Both shafts remain separate connectors, with their own style,
arrowheads and native paint order. The later shaft can cover the earlier one;
use different widths/dashes when both should stay visible.

`avoid` also permits shared corridors while retaining object avoidance. Shared
`via` pins require exact visits, but they do not override an obstacle between
those visits or force a particular connecting segment. Likewise, `weight: 0`
under `separate` removes the separation incentive but retains group bookkeeping;
it neither forces overlap nor provides the cheaper `avoid`/`manual` execution
paths. `rounds: 0` still computes the initial group proposal.

## Register An Object

`deixis-attach(id: <name>)[content]` registers one rectangle and renders the
content once. An attachment with a routing ID is a **nonbreaking native frame**;
use `inline: true` for an inline box. Existing attachments without routing
options retain their previous behavior, including breakable blocks and scanning.
Registration reads corner probes from the live frame without measuring/replaying
its content. Registered rectangles must have positive width and height, except
`behavior: "ignore"`, which also permits points.

| Option | Meaning |
| --- | --- |
| `id: none` | Optional nonempty string/label for connection selection. An ID alone registers an avoidance node. It creates no note, counter or native reference label. |
| `behavior: auto` | With an ID, defaults to `"avoid"`; without one, preserves ordinary attachment. Explicit `"avoid"`, `"ignore"`, `"cut"` or `"cross"` registers a node, even without an ID. |
| `scope: none` | Existing string/label/location namespace, now shared by the node ID and its attached pins. |

`avoid` applies the routing scope's clearance around the rectangle. `ignore`
provides endpoints without an obstacle. `cut` hides the finished shaft inside
the rectangle; `cross` reports entry/exit events to custom painters. Neither
adds an indicator. Existing `connector.gap-marks` and `connector.crossings`
remain optional.

All explicitly registered visible attachments on the physical page supply its
routing obstacles, including anonymous attachments and attachments outside the
routing wrapper. The wrapper groups connections; it does not limit which
registered page objects exist. Ordinary document ink is not discovered.

## Register Existing Notes And Pins

The optional `nodes:` list adds selected existing geometry to this scope's
scene, using the same node entries as `deixis-routing-scene`. This excerpt
selects an existing note `<detail>` with a reused occurrence `<again>`:

```typst
#show: deixis-routing.with(nodes: (
  (body: <detail>),
  (mark: <detail>, occurrence: <again>, behavior: "ignore"),
))
```

The first entry makes the accepted body frame an avoidance rectangle. The second
registers a named reused mark without making it an obstacle. Notes stay declared
and rendered normally, before or after the connections. There is no extra note
ID, wrapper, detached measurement or content replay. See the
[small example](../../examples/routing-around-notes.typ).

Entries support `mark`, `body`, `pin` or `pins`, with the same `behavior`,
`padding`, occurrence, point and physical-page rules as the
[scene selectors](routing-scenes.md#measured-document-nodes). Rectangles default
to `"avoid"`; points default to `"ignore"`. `"cut"` hides the shaft inside the
selected frame, while `"cross"` reports interactions to the painter. Neither
enables crossing symbols. Literal `bounds` also work, with an explicit positive
physical `page`; unpaged geometry belongs to the numeric scene API. Scene-local
`id` is optional and does not create a `(node: ...)` attachment endpoint. Use the
note's existing `(mark: ...)` or `(body: ...)` selector for connection endpoints.

Only the accepted geometry on the current page participates, regardless of the
note body's paint layer. Hidden nodes supply no obstacle. Body placement and
margin packing stay fixed. Connections to a registered mark/body retain its
semantic ownership and short outward-stub exemption; a foreign overlapping box
is still blocking. Positive node padding can enclose the original socket, so use
an explicit outward port gap or keep padding zero and choose scope `clearance`.

Complete body frames currently require margin, inset or explicitly framed inline
bodies. Collected/paginated bodies support live start/end points, which do not
describe their full rectangles. Multi-page regions require an explicit page
fragment. Missing, duplicated or unsupported frames diagnose; registration does
not invent bounds. Existing [scene limits](routing-scenes.md) apply.

The list belongs to this wrapper instance. Nested wrappers use their own lists;
the outer list resumes afterwards. Registered attachments remain page-wide.
Note/pin geometry resolves only when an `avoid`/`separate` group needs a scene;
manual scopes and scopes without searched connections do not require those
targets to be rendered. Entry structure is still validated. Padding lengths
freeze in the wrapper's declaration font context. The combined scene retains
the existing 128-node limit. The default list is empty and adds no note/pin lookup.

## Select Endpoints And Sockets

Select an attachment with `(node: <name>)`. Optional `scope` uses the same
normalization as pins: labels and strings with the same spelling agree. IDs must
be unique within their scope on one physical page. An ID repeated on different
pages selects the declaration's local instance when possible; otherwise it must
identify one instance, or supply `page:` explicitly. This supports repeated
Touying subslides without merging their geometry.

A bare `<name>` in `deixis-connect` retains its existing annotation meaning.
Use `(node: <name>)` for an attachment and `(pin: <name>)` for a pin. These roles
are explicit so existing note and pin identities remain unambiguous.

The same spelling can name a note, attachment and pin simultaneously. It does
not merge their geometry or obstacle ownership. An attachment around a live note
body remains a separate avoidance frame; selecting the note body does not exempt
that containing wrapper. Use the wrapper endpoint or `behavior: "ignore"` as
appropriate. Wrapping an overlay declaration captures its empty declaration
frame, not its later painted body; use `nodes: ((body: id),)` for that geometry.
See the [identity namespaces](identities.md#note-attachment-and-pin-names).

Use the existing `connector.ports` for socket direction, percentage, gap or a
custom attached pin:

```typst
#deixis-attach(id: <card>, pins: (
  outlet: (anchor: horizon + right),
))[Card]
#deixis-connect(from: (node: <card>), to: (node: <target>), connector: (
  ports: (mark: (pin: <outlet>, side: right)),
  heads: "triangle",
))
```

Registered attachments offer four **side midpoints** by default: top, bottom,
left and right. These are routing sockets, not extra public named pins. No
`pins:` dictionary is needed to connect two registered objects. The
[port example](../../examples/attached-ports.typ) compares automatic selection
with a custom attached outlet.

| `connector.ports` | Permitted attachment |
| --- | --- |
| Omitted or `auto` | The four side midpoints; ordinary geometric preference first. |
| `(mark: right)` | Any point on the source's right border; starts at the nearest point and can slide around obstacles. |
| `(body: (side: left, at: 25%))` | Exact point one quarter down the target's left border. `0%`/`100%` select corners with that side's outward direction. |
| `(mark: (pin: <outlet>, side: top))` | Exact pin coordinate, with an upward departure. |

Port keys remain `mark`/`body` for source/target, including custom objects. Add
`gap: 2pt` to a side/pin record to offset it outward. A pin socket inside an
avoidance rectangle receives no clearance exemption. The `pins:` dictionary
accepts any number of names and positions; two corners were only a common
region-mark recipe. Pins can also be placed with text scanning or an explicit
coordinate/anchor specification.

A blocked or unreachable preferred fragment gets one bounded fallback search
over its permitted midpoints/side positions and automatic page boundary. Fixed
percentages and pin coordinates never move. Exact `via` points retain their
absolute positions even if the source socket moves. A successful preference is
retained for the independent reference and under `avoid`. Under `separate`,
bounded same-page socket repair may reconsider that preference to reduce
congestion; see below. Shared
identity and the literal socket define an intentional junction; coincident
anonymous coordinates remain accidental. An outward socket can exit its owned
rectangle, but receives no exemption from foreign obstacles.

### Reconsider Automatic Ports

The `separate` policy can change a feasible automatic socket when that improves
the whole group's congestion. The [automatic-port example](../../examples/automatic-ports.typ)
uses a large spacing rule to make neighbouring middle outlets too close; one
connection can instead leave/enter another permitted side. The objects stay fixed.

Each repair round tries fixed source/target pairs for a congested connector
against the other accepted routes, then applies ordinary path repair. Automatic
side midpoints and the selected side's existing finite sliding samples are
eligible; exact percentages and pin coordinates remain fixed. Each side keeps
its current socket plus at most seven nearest permitted alternatives before
forming pairs. Candidate ordering is deterministic. This is bounded local
improvement, not a global search over all connectors, continuous side positions
or simultaneous socket changes on several edges.

A socket move must strictly reduce parallel exposure and group energy, preserve
every accepted route, stay within `max-detour` of each **original independent
route**, and introduce no additional contacts, crossings or collinear overlap.
Owner clearance and intentional common stubs use the actual candidate sockets.
Rejected/failed proposals leave the accepted sockets and paths unchanged.
All attempted searches count against the existing search/expansion/cell limits.

`rounds: 0` disables this socket-repair phase (the initial fixed-socket group
proposal still runs). A zero separation weight also skips socket repair. Use
`avoid` for independent object avoidance without any connector repair, or
`manual` for literal native paths. No extra tuning option is needed.

For a cross-page connector, the same phase can move an **automatic spill point**
along its existing top/bottom boundary. It keeps the accepted real socket, boundary
height, normal and exact visits fixed. Up to seven alternatives come from local
object edges, route rails and spacing offsets, with the same acceptance/work
limits. An explicit split coordinate stays fixed. The
[spill-spacing example](../../examples/spaced-continuations.typ) shows this without
an extra connector option.

Each physical page decides independently. The two spill points need not share
an x coordinate; counterpart links follow the accepted points. With page-local
costs and constraints there is no benefit to jointly searching their Cartesian
product. A future coupled constraint, such as an explicit alignment requirement,
would need a separate design. Coordinated multi-edge port swaps remain separate.

Existing mark occurrences, note frames/live body points and pin endpoints also
work inside the wrapper. Attached routing nodes and explicit `nodes:` entries
supply rectangles. Selecting a note endpoint or collecting a shorthand connector
does not register that note's body automatically.

## Route Note Shorthand

Enabled margin/inset body connectors capture the policy at their **body
declaration** and join explicit connections in the same page/layer group. No
additional routing switch or note ID is required:

```typst
#show: deixis-routing.with(policy: "avoid")
#deixis-margin-note(
  connector: (route: "orthogonal", radius: 0pt, heads: "triangle"),
)[A Source][A Margin Explanation]
```

The [note example](../../examples/routed-notes.typ) combines margin and inset
shorthand around a registered obstacle. Existing `deixis-set` connector defaults
can supply the shared geometry. The scope chooses planning rules; it does not
enable a disabled note connector or replace its chosen curve/radius. Search
presets therefore require sharp orthogonal shorthand, just like explicit
connections with nondefault geometry. Use `manual` for existing curves, rounded
paths, native margin lanes or an explicit `connector.scene`.

Body placement, packing, numbering and backlinks retain their own rules,
including for `layer: "flow"`. The **connector's** foreground/background layer
determines its routing group. In a searched scope, margin shorthand keeps its
permitted endpoint sides/sliding spans but leaves intermediate path selection to
the planner; native synthetic lane points are not hard visits. Explicit `via`
points, pin sockets and splits remain constraints. Outside the wrapper, native
margin lane routing is unchanged.

A reused mark gains no shorthand connection. Use `deixis-connect` for a chosen
additional occurrence. Forward mark/body order is supported: the original
mark's scope does not override the body's captured policy. A nested manual
wrapper can keep one body connector native while its neighbors are searched.
Declarations created later in an independently rendered note body or native
overlay need a local `deixis-routing[...]` wrapper around that content; the outer
main-flow markers do not enclose those native layout roots. Existing native
layout-pass limits for nested note adapters still apply.
Late overlay bodies combined with automatic crossings and final painter-state
queries can also exceed the native pass budget, including outside a routing
scope. Immediate bodies avoid that extra deferred geometry dependency.

## Scope And Policy

`#show: deixis-routing` collects subsequent declarations. Alternatively,
`#deixis-routing[ ... ]` encloses a drawing. The innermost wrapper owns each
connection; nested wrappers form separate groups without requiring group IDs.
The search policies support at most sixteen enabled visible fragments per
scope/page/layer. Manual paths do not enter this planner or consume its budget.

Under a search policy, each physical page and foreground/background layer has an independent group.
Different `z-index` values in one layer share planning and retain their painting
order; registered nodes do not move. Shaft proximity is not checked across
layers or separate wrappers. At equal priority, ordinary connection commands
paint before collected connection commands; collected groups use first-declaration
order, and each group's members retain declaration order. This same ordering
controls optional crossing gaps.

The `avoid` and `separate` policies use sharp orthogonal routing with
`radius: 0pt`. Curves, rounding and mixed route sections receive diagnostics;
exact `via` points and pin visits work. These policies do not combine
`connector.scene` with their automatic registered-node scene. Use the `manual`
policy or ordinary connectors for an explicit scene, or the numeric APIs for
custom plans.

```typst
deixis-routing(body, policy: "separate", nodes: (), clearance: 4pt, escape: 4pt, bend-cost: 12pt,
  spacing: 3pt, weight: 4, max-detour: 25%, rounds: 2,
  max-searches: 64, max-expansions: 50000, max-cells: 65536)
```

Scene settings control fixed obstacle search for `avoid`/`separate`. Group
repair settings apply to `separate` and retain the
[numeric group's contracts](route-groups.md#options-and-work-limits): centerline
spacing, bounded detours, guarded improvements and checked rollback on budget
exhaustion. Search/count/cell limits apply to each searched page/layer plan,
including rejected proposals and fallback work. Unused tuning values are still
validated, so a misspelled/invalid setting does not silently become valid when
changing presets. The public numeric group API is unchanged.
A failed fragment produces a diagnostic and no unchecked fallback. Complete
separation and global optimality are not promised. Geometry planning is pure;
Typst can repeat it during layout or distinct priority bands. Heads, renderers
and live attachment content execute only through accepted painting contexts.

## Pages, Visibility And Setup

Cross-page connections use the existing source/target page fragments and
continuation options. Intervening pages get no fragment. Each group uses the
accepted dimensions of its own page, even after a page-size change. Ordinary
split/continuation preference resolves first. If blocked or unreachable, the
same bounded alternative-port/boundary search used by ordinary scene connectors
selects a feasible fragment. Under `separate`, bounded repair may then reconsider
its automatic boundary point to reduce local congestion, keeping the real socket
fixed. Under `avoid`, a successful preferred/fallback point stays fixed.
An explicit split coordinate never moves. Incoming fragments reverse the search
and exact visits together, then restore the original shaft direction; peer links
still target real nodes. Custom paint callbacks can instead call the lazy
`(request.counterpart)()` to link directly to the accepted opposite spill point;
see [continuation navigation](connectors.md#page-continuation-markers). That lookup
does not influence planning. Bare/array split separators without an explicit
coordinate remain automatic and use each page's contextual spill interval.
Margin destinations stay in their selected margin channel; other destinations
use content width. `connector.spill` can override that interval; see
[spill placement](connectors.md#spill-placement).
Fallback and repair share the group's search/expansion
budgets, and both preference/fallback attempts share one per-edge scene allowance.

Native hidden nodes do not become obstacles, and hidden declarations/endpoints
produce no connector. Hidden geometry is never invented. The node registry
retains its physical-page ownership for repeated subslides.

Use `deixis-setup-notes` and both automatic page layers, or install the explicit
[host hooks](setup.md) with `page-overlays: false`. The background hook publishes
physical-page bounds; the selected connector layer paints the group. After
replacing native page foreground/background, reapply setup as documented there.
Collected connection declarations remain invisible in inline, block and
paragraph positions; explicit node wrappers intentionally provide their frame.

`deixis-routing-scene` and `deixis-route-group` remain the lower-level,
setup-free APIs for numeric drawings. The scene constructs reusable geometry;
the group function returns routes and does not register or paint content.
