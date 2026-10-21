# Connectors And Arrowheads

Deixis requires Typst 0.15.0 or newer. The package runtime has no
external drawing dependency. The native backend handles routes, measured node
ports, endpoint heads, and page continuation decorations.

A margin or inset body's `connector` draws one edge from its original mark.
Repeated marks add PDF links/backlink origins without adding connections
automatically. Use [`deixis-connect`](independent-connections.md) to draw
independently configured edges from originals or named repeats to a measured
margin/inset body. Both use the same `connector` option.

## Start With One Option

After importing Deixis and enabling `deixis-setup-notes`, a route name is enough:

<!-- deixis-example: {"id": "automatic-curve", "height": "150pt", "prelude": "#set page(margin: (left: 18pt, right: 130pt, top: 18pt, bottom: 18pt))"} -->
```typst
#deixis-margin-note(connector: "curve")[An annotation with automatic placement and ports.]
```

Add an arrow with one more option:

<!-- deixis-example: {"id": "stealth-head", "height": "150pt", "prelude": "#set page(margin: (left: 18pt, right: 130pt, top: 18pt, bottom: 18pt))"} -->
```typst
#deixis-margin-note(connector: (route: "curve", heads: "stealth"))[The arrow points to this note.]
```

A route name is shorthand for `(route: name)`. The same names work with inset
notes. Margin side selection, body placement and connector ports keep their
defaults; add record fields only as needed, such as `heads: (body: "circle")`.
Use `deixis-set(connector: "curve")` to share a route across notes.

The [simple example](../../examples/connectors.typ) demonstrates these calls.
The sections below explain the controls available when a drawing needs them.

## A Complete Connector

A connector record collects every edge option. Defaults come from
`deixis-set(connector: ...)`, which can be scoped by note type, such as
`connector: (margin-note: "curve")`. A note's own record merges with those
defaults field by field, so `connector: (heads: "stealth")` keeps an inherited
route; `connector: none` disables the edge. A note's component `stroke`/`radius`
(for example `stroke: (connector: gray)`) styles its connector unless the record sets
`stroke`/`radius`.

<!-- deixis-example: {"id": "orthogonal-ports", "height": "150pt"} -->
```typst
#deixis-inset-note(
  layer: "foreground", width: 100pt, dx: 140pt, dy: 30pt,
  connector: (
    route: "orthogonal",
    ports: (mark: (side: right, at: 50%, gap: 2pt), body: left),
    via: ((relative-to: "mark", offset: (30pt, 0pt)),),
    heads: (mark: none, body: deixis-arrowhead(shape: "triangle", length: 7pt, width: 5pt)),
    stroke: blue + 0.8pt,
    radius: 4pt,
  ),
)[Marked phrase][An annotation.]
```

The fields are `route`, `ports`, `via` or `segments`, `heads`, `cuts`, `crossings`, `gap-marks`, `continuation`, `scene`, `stroke`, `radius`,
`render`, `layer`, and `z-index`. A connector needs an enabled route; specifying a head alone does not
turn the default `"none"` route into a visible line.

## Connection Layer

Margin and inset connections share one rule: the default/`auto` layer is
`"foreground"`, independently of the body's layer. Use `connector.layer` to
select `"background"` or `"foreground"` explicitly:

<!-- deixis-example: {"id": "background-curve", "height": "150pt", "prelude": "#set page(margin: (left: 18pt, right: 130pt, top: 18pt, bottom: 18pt))"} -->
```typst
#deixis-margin-note(layer: "flow",
  connector: (route: "curve", layer: "background"),
)[An immediate body with a background connector.]
```

Both layers resolve the whole document and support page continuations. A body
can be immediate without making the connector immediate. Connector `"flow"`
is rejected. Within each page layer, connections paint below note bodies; native
page and host-theme overlays retain their normal composition/clipping rules.
Custom painters receive the active layer in `request.route.document.layer`
(or the legacy request's `layer`) and run with declaration typography. Relative
head sizes, port gaps, and route radii therefore use the declaration's font size.
See [the small example](../../examples/connector-layers.typ).

This changes the unreleased 0.2 margin behavior: a background/flow margin body no
longer implicitly selects the connection's layer. Set `connector.layer` explicitly
when a line should sit behind page content. Inset connections can now choose a
background too. Body placement, footer reservations, and collision groups are
unchanged. Direct margin-layout hooks used without Deixis setup still paint
their own connections locally; install setup/page overlays for layer control.

## Routes And Ports

| Route | Behavior |
| --- | --- |
| `"polyline"` / `"straight-line"` | Straight segments through the points |
| `"orthogonal"` / `"right-angle"` | Horizontal/vertical routing; radius rounds corners |
| `"chamfer"` | Orthogonal routing with cut corners |
| `"curve"` | Angle-bisector interpolation with chord-scaled handles |
| `"catmull-rom"` / `"catmull-rom-centripetal"` / `"ccr"` | Distance-weighted Catmull–Rom interpolation |
| `"catmull-rom-uniform"` / `"ucr"` | Uniform Catmull–Rom interpolation |
| `"b-spline"` | Clamped control curve: endpoints are exact, interior controls pull the curve |
| `"hobby"` | Interpolation with globally solved tangents and Hobby cubic velocities |
| `"none"` | Disable the connector, or an undrawn segment inside a mixed route |

The [curve comparison](../../examples/curve-routes.typ) uses identical knots for
the three local interpolating curves. `"curve"` gives a simple chord-scaled shape;
centripetal Catmull–Rom is a useful choice for unevenly spaced knots. Uniform
Catmull–Rom preserves uniform-parameter derivative continuity, but can overshoot
or form loops around clustered knots. Port constraints and sharp reversals can
create strong bends or stationary tangents with any interpolating choice.

Free endpoints of `curve` and Catmull–Rom follow the adjacent chord. Hobby derives
their directions from its boundary conditions; B-splines follow their control
polygon. With no knots/controls, two free pins give a straight curve. Forced node
sides/normals still determine departure and arrival.
An earlier waypoint may coincide with the final destination and continue
elsewhere before returning. Only adjacent duplicates are collapsed; ordinary
coordinate waypoints retain the existing 0.1pt simplification tolerance, while
explicit pin visits use the much smaller numeric geometry tolerance.

Curve, Catmull–Rom and Hobby interpolate their knots. B-spline controls have
different semantics, described below.

### Curve Settings

A string keeps the defaults. A route record groups controls for its algorithm:

<!-- deixis-example: {"id": "curve-tension", "height": "240pt"} -->
```typst
#deixis-inset-note(width: 130pt, dx: 120pt, dy: 30pt,
  connector: (route: (kind: "curve", tension: 2)),
)[Curve][A tension-controlled curve.]

#v(85pt)
#deixis-inset-note(width: 130pt, dx: 120pt, dy: 30pt,
  connector: (route: (kind: "catmull-rom", parameterization: "uniform", tension: 1.5)),
)[Spline][A Catmull–Rom curve.]
```

For `curve` and Catmull–Rom, `tension` defaults to `1` and divides the
control-handle lengths after endpoint constraints: `2` halves the handles;
`0.5` doubles them. Knots and port directions stay fixed. A shared tension keeps
the existing tangent continuity within a section, including uniform Catmull–Rom's
uniform-parameter derivative continuity. It does not guarantee fewer overshoots
or loops. Try values between `0.5` and `2` first; larger values pull handles
toward their knots, while smaller values can make broad bends.

Tension must be a positive finite integer/float with a finite reciprocal.
Lengths, percentages, `auto`, zero, negative values, infinity, and NaN receive
diagnostics. Coordinates still use native floating-point precision; extreme
values are not a useful substitute for selecting waypoints or a different route.

`"catmull-rom"` defaults to `parameterization: "centripetal"`; the other choice
is `"uniform"`. Existing `"ccr"`/`"ucr"` and descriptive names keep their meanings
and also accept tension records. Their parameterization is fixed; use the family
name to select it explicitly. Line/orthogonal/chamfer/none records accept `kind`
only; corner rounding stays in `connector.radius`. B-spline records accept
`controls`, described below. Unknown or inapplicable settings are errors.

The same record works in `connector.route`, `deixis-set`, and mixed-route sections. Each
record needs `kind` and replaces previous route settings as a whole; switching
from a Catmull–Rom record to `(kind: "curve")` cannot inherit its parameterization
or tension. Type/component configuration maps remain available around these
literal values. The [small handle comparison](../../examples/route-settings.typ)
shows three tensions on the same knots.

### Hobby Interpolation

Start with `connector: (route: "hobby")`, using ordinary exact `via` knots. Hobby
solves tangent directions across the whole section before constructing its
cubics; a later knot can affect an earlier bend. It offers a different style
from local Catmull–Rom interpolation. The
[small comparison](../../examples/hobby-curves.typ) shows both on the same knots.

<!-- deixis-example: {"id": "hobby-curve", "height": "150pt"} -->
```typst
#deixis-inset-note(width: 130pt, dx: 120pt, dy: 45pt,
  connector: (route: (kind: "hobby", tension: 1.5, curl: (mark: 0, body: 1))),
)[A passage][An explanation.]
```

Tension defaults to `1` and must be finite and at least `0.75`. Larger values
generally shorten handles, but also participate in the global angle solve;
`2` does not in general simply halve the old handles. Start with `1` or `1.5`.
MetaPost's finite velocity bound limits each handle to four chord lengths;
tight reversals, forced directions and uneven spacing can still overshoot or
backtrack. Centripetal Catmull–Rom remains useful when local spacing stability
matters more than this style.

`curl` changes the boundary bending condition at free ends. It accepts a finite
nonnegative number for both ends, or a `(mark: ..., body: ...)` map; omitted
entries default to `1`. These mean the start/end of each section. Curl `1`
balances the endpoint's mock curvature with its neighbor; `0` uses the flat
mock-curvature boundary condition. This approximation does not promise zero
actual curvature or exact curvature continuity. Hobby joins have continuous
tangent direction, without a general C1/C2 speed/curvature guarantee.

A port normal or axis replaces curl at that boundary, before solving the
interior angles. Controls are not rotated afterward. Two free endpoints without
interior knots form a straight curve regardless of curl. Consecutive duplicates
collapse; returning to an earlier point is preserved. Coincident endpoints do
not request a cyclic spline: this is an open route with independent boundaries.

Records work in defaults, `segments`, inline `via` switches and both page halves.
Each section/page fragment solves independently and keeps the existing endpoint
and relay directions. An explicit Hobby switch starts a fresh solve even with
identical settings; use one section when tangent continuity across its knots is
wanted. Empty sections do not absorb endpoint directions, while real `"none"`
spans still interrupt the shaft. Native heads, cuts, optional crossing gaps/indicators and
custom painters share its cubic geometry. Per-knot tensions/directions, cyclic
closure and MetaPost's `atleast` policy are not options in this API. Extreme
finite inputs that cannot be represented receive a numerical-boundary diagnostic.

### Influence-Point Curves

Put influence points in the route's `controls`, leaving `via` for exact visits:

```typst fragment
connector: (route: (kind: "b-spline", controls: ((pin: <bend>),)))
```

A clamped B-spline starts and ends at its selected ports. Interior controls
pull the curve without requiring it to pass through them. With free endpoints,
zero controls give a line, one gives a quadratic, two give a cubic Bézier, and
more give a piecewise cubic with uniform interior knots and C2 continuity.
Repeated controls retain their multiplicity; they can intentionally change the
shape or produce stationary tangents. Coincident endpoints can enclose a loop;
a wholly coincident polygon produces no shaft or heads.

Controls accept `(x, y)` coordinate pairs, framed points, or `(pin: target,
offset: (dx, dy))` records. They share the usual coordinate/frame rules:

<!-- deixis-example: {"id": "spline-controls", "height": "150pt"} -->
```typst
#deixis-inset-note(width: 130pt, dx: 120pt, dy: 45pt,
  connector: (route: (kind: "b-spline", controls: (
    (relative-to: "mark", offset: (40pt, -30pt)),
    (relative-to: "body", offset: (-40pt, -30pt)),
  ))),
)[A passage][An explanation.]
```

Mark/body/page anchors and offsets work as for waypoints. A coordinate pair is
relative to the previous control; the first uses the section's preceding exact
waypoint, or the normal initial waypoint origin. Controls do not advance the
origin used by subsequent hard waypoints. Explicit frames are useful when the
polygon should remain independent of port selection. Control pins accept the
same string/label names, scope/select/page targets and length offsets as waypoint
pins. They select one occurrence on the relevant page; pin padding does not move
the control point. Scalar and legacy anchor-string waypoint spellings are not
control-point forms.

Node port directions keep priority: the builder adds boundary controls to honor
departure/arrival while retaining user influences. The degree/segment count can
therefore increase for constrained endpoints. Neutral pin endpoints/ports leave
the supplied control polygon unchanged and allow exact quadratic/Bézier handles.
Boundary controls can extend outside the supplied polygon's bounds. As with the
other routes, port constraints do not provide obstacle avoidance.
B-splines use the supplied polygon instead of automatic margin lane waypoints;
margin body placement and port selection keep their existing behavior.

Each B-spline section has its endpoints and its own control polygon. To visit an
exact interior knot, end a section there and choose the following route:

```typst fragment
segments: (
  (route: (kind: "b-spline", controls: ((pin: <bend>),)),
    via: ((pin: <joint>),)),
  (route: "curve"),
)
```

The next section can also be a B-spline with its own `kind`/`controls` record;
even identical explicit records start separate sections. Several hard waypoints
inside one B-spline section receive a diagnostic rather than silently becoming
influences or repeating a polygon. Joining sections can introduce a corner.
`tension`, degree and custom knot vectors are not controls for this route.

For cross-page links, initial controls belong to the source half, like initial
waypoints. Put a route record after `"split"` to give the destination half its
own controls; its pin targets resolve on that half's page. The destination half
otherwise uses the same route with an empty control polygon. Heads, cuts,
optional crossing gaps/indicators, and custom painters use the resulting native
line/cubic geometry. The [small comparison](../../examples/control-curves.typ)
shows exact knots beside influence points.

Line appearance is independent of the route. Use a native stroke for dashed or
dotted lines, caps, joins, thickness, and paint:

<!-- deixis-example: {"id": "dashed-stroke", "height": "150pt"} -->
```typst
#deixis-inset-note(width: 130pt, dx: 120pt, dy: 45pt,
  connector: (route: "orthogonal", radius: 4pt,
    stroke: stroke(paint: blue, thickness: 1pt, dash: "dashed", cap: "round")),
)[A passage][An explanation.]
```

A port may be a side alignment/string or `(side: ..., at: ..., gap: ...)`.
`at` is `auto` or a percentage from 0% to 100% along that edge, measured left to
right for horizontal edges and top to bottom for vertical edges. `gap` offsets
outward from the node. With `at: auto`, a selected side is a continuous segment:
the router chooses its nearest point to the other endpoint or adjacent waypoint.
Two sliding sides use the closest points, with a deterministic midpoint when their
ranges overlap. A percentage selects a fixed point. `ports: (right, left)` means
mark right/body left. A scalar side applies to both; `auto` retains adapter defaults.

Every rectangular node offers four selectable sides, rather than just four fixed
dots. Automatic candidate policies retain useful differences:

| Connection | Automatic attachments |
| --- | --- |
| Explicit connections to framed notes/regions/named boxes | Four side-center candidates per frame |
| Implicit inset connection | Four body probes; four region sides or the inline marker's two vertical and available horizontal candidates |
| Implicit margin connection | A selected mark exit and a sliding point on the body's inner border, with its existing corner clearance and lane/spillover policy |
| Pin endpoint | One unforced point; a selected side supplies an outward direction at that point |
| Native body start/end and named phantom points | Coincident directional candidates; they do not acquire a rectangle |

The available controls have one convention; automatic routing remains sensitive
to the adapter. Choosing a side explicitly uses the shared sliding rule. Use
`(side: left, at: 50%)` for a fixed midpoint. In unreleased 0.2, this is a tightening
of explicit `at: auto` behavior: older adapters could keep a midpoint instead.

Node bounds remain independent of restricted ports. Selecting top ports does not
change what a `body-bottom` waypoint means. Explicit sides can be constructed on
the full frame even when the automatic candidate set has fewer sides. Curved and
orthogonal routes respect signed outward port directions; straight segments use
the line's actual direction. Port constraints are not obstacle avoidance: a forced
side can require a loop or a route across other content.

Inline marker frames are shared typographic approximations based on font size
and marker width. Region frames use recorded pins; body frames use measured
bounds. Arbitrary glyph outlines and arbitrary container silhouettes are not
available as routing obstacles.

## Pins As Custom Ports

A pin supplies a custom attachment point on any content, including inside a
rendered note body:

```typst fragment
connector: (
  route: "curve",
  ports: (body: (pin: "socket", side: left, gap: 2pt)),
)
```

`pin` accepts a string/label or the shared `(name:, scope:, select:, page:)` target.
Exactly one occurrence must match, after filtering to the node's physical page.
The pin need not be on the rectangular border. It changes the attachment, while
the original node bounds still define body/mark-relative waypoints. Missing,
ambiguous, multiple, and wrong-page selections produce diagnostics.

`side` supplies a page-space outward direction. Its default `auto` leaves the
pin unforced, with no normal; a nonzero signed `gap` needs an explicit side.
Pin padding expands regions and does not shift a connection. Use independent
`gap` values when several edges share a socket. A pin record does not accept
`at`: its position already comes from the pin.

Custom pin ports use generic routing in place of margin lane offsets prepared
for the original attachment. Body placement, packing, and spillover are retained.
Virtual continuation boundaries keep their relay ports; endpoint sockets and
arrowheads belong only to actual endpoints. Use `via` for deliberate extra bends.
See [pin endpoints](independent-connections.md#connect-pins-without-creating-notes)
and the [small example](../../examples/pin-connections.typ).

## Waypoints And Mixed Routes

Structured points state their reference frame:

```typst fragment
via: (
  (relative-to: "mark", anchor: bottom + right, offset: (12pt, 8pt)),
  (relative-to: "previous", offset: (0pt, 20pt)),
  (relative-to: "body", anchor: top + left, offset: (-10pt, 0pt)),
  (relative-to: "page", offset: (80%, 25%)),
)
```

Mark/body coordinates default to the node center; page coordinates default to the
physical page's top-left. An optional Typst alignment selects an edge/corner.
Lengths are offsets from that origin. Percentages use the referenced frame's
width/height; previous-relative percentages use the center-to-center delta between
mark and body. Coordinates use positive x right and positive y down.

A pin waypoint visits its recorded location, with an optional length offset:

```typst fragment
via: ((pin: <bend>), (pin: (name: "bend", scope: "diagram"), offset: (2pt, 0pt)))
```

Pin targets use the same selection rules as endpoints and custom ports. Their
offsets accept signed/font lengths; percentages have no point-size basis.
Native routes visit pin waypoints exactly. Rounded orthogonal/chamfer routes
retain the corner at that point, while ordinary waypoints keep their usual
rounding. Endpoint-head trimming can consume nearby shaft segments as usual.

Legacy `(dx, dy)` pairs remain cumulative from the previous point. Their
percentages are fractions of the mark/body center delta. Legacy anchor strings
such as `"mark-right"` or `"body-bottom-left"` select absolute node coordinates;
using two strings in a pair independently selects x and y. Anchor names are
validated. Prefer structured points when mixing absolute and relative rules.

Use segment records to change algorithms deliberately:

<!-- deixis-example: {"id": "mixed-segments", "height": "150pt"} -->
```typst
#deixis-inset-note(width: 130pt, dx: 120pt, dy: 45pt,
  connector: (route: "polyline", ports: (mark: right, body: left),
    segments: (
      (route: (kind: "curve", tension: 2), via: ((relative-to: "mark", offset: (30pt, 20pt)),)),
      (route: "polyline", via: ((relative-to: "body", anchor: left + horizon, offset: (-20pt, 0pt)),)),
      (route: "orthogonal"),
    ),
  ),
)[A passage][An explanation.]
```

The last segment reaches the body. Do not combine `segments` with `via`.
Route strings and records can also be interleaved in `via`. Each switch owns
its settings: switching to `"curve"` resets tension to `1`; a section without a
`route` continues the previous settings. Switching sections can introduce a
corner; it does not promise tangent continuity across different policies.
Native spline endpoint
handles are constrained to ports; their interior Catmull–Rom interpolation retains
its selected uniform or centripetal policy.

For cross-page connectors, legacy `"split"` and `("split", x-spec)` controls remain
supported. Start/mark and end/body heads belong to actual endpoints; continuation
boundaries get their own small decoration. A connector is painted on the endpoint
pages, not as a line through all intervening pages. A broader page-continuation
API remains future work.

## Spill Placement

Automatic page continuations use the content frame's top/bottom boundaries,
following the connection's document direction. Margin shorthand retains its
forward spillover convention. Horizontally, the default `connector.spill: auto`
uses the accepted body's selected left/right margin channel for a margin
destination, and the content width for inset bodies, attached objects and pins.
This applies to body shorthand and independent connections, including explicit
margin-body start/end points. The margin body's accepted physical side supplies
the channel; an explicit edge does not rerun margin packing or side selection.

Each physical page resolves its own interval from its accepted dimensions and
margins. Outgoing ordinary connections prefer the source projection (or the last
pre-split waypoint); incoming ones prefer their local destination. Margin
shorthand keeps its lane preference. The preference is clamped **before** route
planning. Obstacle fallback and `separate` congestion repair use the same hard
interval, while the shaft can travel elsewhere on the page. Opposite spill points
can have different x coordinates, including on equal-size pages. If an exact
body start/end point lies on the continuation boundary, its local incoming
fragment can have zero length. The existing empty-path contract then supplies
no shaft or endpoint arrowhead for that fragment.

Most calls need no extra setting. Override the interval when needed:

```typst fragment
connector: (spill: "content", continuation: "portal")
connector: (spill: "page")
connector: (spill: (left: 20%, right: 80%))
```

`"content"` selects the physical page's content width; `"page"` selects its
whole width. A dictionary gives absolute page-x coordinates, with percentages
relative to that page's width. Font lengths freeze at declaration. A resolved
interval must be positive and inside the physical page. These are routing-point
bounds: marker ink, custom badge hit areas and headers/footers are not packed.
Continuation appearance remains configured separately by `continuation`.

Scoped margin destinations use accepted page-local block frames, including their
inset channels and top/bottom boundaries. A body spilled into another block of
the same thread uses that accepted destination block's frame on its page. If the target scope has no accepted
frame on an endpoint page, automatic margin placement diagnoses that limitation;
choose `"content"`, `"page"`, a custom interval, or an exact split deliberately.
A completely blocked channel produces the existing routing failure instead of
silently switching margins. These constraints do not add obstacle search to
native/manual routing: only configured scene or routing policies avoid nodes.

Exact `("split", x)` choices retain their existing literal/relative semantics
and bypass automatic placement. Exact pins and hard visits are unchanged.
Custom continuation callbacks receive `allocation.region` (left/right,
top/bottom, kind in physical page coordinates), or `none` for an exact split.
See [Spill Regions On Different Pages](../../examples/spill-regions.typ).

## Page Continuation Markers

Continuation markers identify another fragment of a connection; they are
independent of endpoint heads and internal cut/crossing indicators. The default
`connector.continuation: auto` preserves the native dots. `none` suppresses them.
Use `"portal"` for a small hollow ring, or `"dot"` for the filled dot explicitly:

```typst fragment
connector: (heads: "stealth", continuation: "portal")
```

The ring defaults to a 4pt diameter (or three shaft widths when larger), with a
solid outline in the shaft's color/width. Its center is transparent; native
shaft trimming stops the line at the inner rim, including round/square caps,
without an opaque background patch. Geometry, exact visits, continuation point
and routing allocation stay unchanged. Manual cuts retain their original
arc-length basis. Real endpoint heads stay separate from continuation markers.

Use a dictionary when needed:

```typst fragment
continuation: (shape: "portal", size: 5pt, link: "counterpart")
```

`size` is the diameter and accepts positive lengths, including font lengths.
`stroke`/`fill` optionally override styling. `link` defaults to `none`;
`"counterpart"` links to the other accepted spill point, and `"peer"` to the
real opposite node. Only counterpart linking adds the lazy paired-point lookup.
An unresolved counterpart leaves a plain marker. Shared exits still share a
tiny hit area; keep separate labelled markers when their identities matter.
Native presets require native routing; legacy route callbacks can use the
existing continuation renderer instead.

See [Small Portals Between Pages](../../examples/portal-continuations.typ) for
a linked ring beside an intentionally unmarked connector. The labelled
[shared-exit examples](../../examples/linked-spill-points.typ) use smaller badges
for the case where readers need to distinguish two overlapping links.

A disabled shaft (`stroke: none`) has no automatic dot or native preset.
A native preset also stays absent at an undrawn endpoint section. A custom continuation
renderer can still deliberately paint with a disabled shaft:

```typst fragment
connector: (
  continuation: request => place(center + horizon,
    text(size: 8pt, [→ p. #request.peer-page])),
)
```

The callback receives `direction` (`"outgoing"`/`"incoming"`), `page`,
`source-page`, `target-page`, `peer-page`, `peer`, `status`, `relay`, `point`,
`normal`, `allocation`, lazy `counterpart`, resolved `stroke`, and
`frame: "continuation-local-x-right-y-down"`.
Its local origin is the continuation point. `point` is also supplied in physical
page coordinates; `normal` points outward from that page's top/bottom boundary.
Page numbers are physical; choose your own display labels for front matter or
reset numbering.

`source-page` and `target-page` identify the **real marked and body pages**,
including margin bodies that spill past an intermediate page. `peer` describes
the real opposite node: `page`, page-space center `point`, and `destination`
(a native page/x/y link destination). For example:

```typst fragment
continuation: request => {
  if request.peer != none {
    place(center + horizon, link(request.peer.destination,
      text(size: 8pt, [→ p. #request.peer-page])))
  }
},
```

A callback can capture a name to pair its two markers. See the small
[linked continuation example](../../examples/page-continuations.typ). Native dots
remain the default and do not enable page links or numbering implicitly.

The same callback runs on both endpoint pages, so each marker can link to its
opposite real node. For a direct link to the other **accepted spill point**, call
the lazy `counterpart` function instead:

```typst fragment
continuation: request => {
  let other = (request.counterpart)()
  if other != none {
    place(center + horizon, link(other.destination,
      text(size: 8pt, [↔ p. #other.page])))
  }
},
```

Typst requires parentheses when calling a function stored in a dictionary.
The result is `none` until the opposite accepted fragment is available, or a
record with `page`, page-space `point`, outward `normal`, opposite `direction`
and native `destination`. It follows the final point after independent obstacle
allocation or a page-size change. It does not guess from a preferred relay,
rerun routing or replay another callback. Guard `none`, including in intermediate
layout passes. A missing/suppressed opposite fragment stays absent; duplicated
opposite painting is diagnosed rather than chosen arbitrarily.

Pairing uses each connection declaration internally, including separate
`deixis-connect` calls with identical endpoints; shorthand uses its note body.
There is no extra public connection name to maintain. A custom shaft renderer
can call the same function through `request.route.document.continuation`, even
with `continuation: none`. `peer` continues to target the real opposite node;
`counterpart` targets accepted continuation geometry, not the bounds/offset of a
custom badge. See [Linking Spill Points](../../examples/linked-spill-points.typ).
It is supplied to paint callbacks after selection; a scene-construction callback
only receives preferred geometry and cannot use counterpart lookup to steer a route.

The lookup queries document geometry only when called. Custom shaft/continuation
callbacks publish small accepted-point records; native default dots add neither
these records nor a remote lookup. This is a read-only layout dependency, so
querying a late overlay marker's own output again inside the document can exceed
Typst's native pass budget. Inspect such painter output after compilation.

When several connectors share a relay, give their labels separate clickable
areas and repeat a short name/color on both pages. Coincident clickable dots
would leave overlapping PDF link areas without a reliable choice for the reader.
[Two Links At One Exit](../../examples/paired-continuations.typ) demonstrates
separate A/B badges at one exit and entry; it also changes page dimensions.
Badge spacing is deliberate in that example, not an automatic label packer.

`relay: true` identifies margin fragments whose local shaft geometry still uses
the margin adapter's boundary/lane convention. It no longer makes `peer-page`
an adjacent-page guess. `status: "resolved"` means both real endpoint frames are
known. If a direct/custom layout supplies only one half or a body is never placed,
status is `"incomplete"`; unknown pages/nodes and `peer` are `none`. Guard `peer`
before adding a link instead of inventing a destination.

Custom shaft painters receive the same continuation record at
`request.route.document.continuation` (`none` for same-page connections).
`document.nodes` and `document.source-page`/`target-page` describe the real edge;
`document.fragment` separates its local drawing from those endpoints:

| Fragment field | Meaning |
| --- | --- |
| `page` | Current physical page |
| `kind` | `"whole"`, `"source"`, or `"target"` |
| `status` | `"resolved"` or `"incomplete"` |
| `source`, `target` | Current page-space attachment/continuation points, axes, normals and roles |
| `logical.source`, `logical.target` | Real numeric endpoint nodes, or `none` when unknown |

The source-local native `route` geometry is unchanged. Decorations paint after
the shaft painter; use `continuation: none` when that painter owns all decoration
ordering. Scene construction can consume the same measured node geometry, while
[document node selectors](routing-scenes.md#measured-document-nodes) provide the
shorter form for ordinary callers.

Optional [`connector.scene`](routing-scenes.md#scenes-in-document-connectors)
routes each fragment against explicitly registered objects before preparing
heads. It accepts a prepared scene or a read-only `doc => scene` function. Sharp
orthogonal avoidance, native curve cuts and crossing records share the numeric
engine. Defaults keep existing routing. A blocked fixed continuation point
produces a diagnostic; it does not silently paint through the obstacle.

Automatic relay x positions are kept within both endpoint pages, including
different page widths; an off-page candidate falls back into their common
margin bounds when possible. Explicit `"split"` positions retain literal caller
coordinates. With `connector.scene`, automatic boundary allocation can instead
select a clear reachable relay on each endpoint page. Drawing through
intermediate pages is not implemented. [Numeric scenes](routing-scenes.md) keep
each page's obstacles separate and require explicit fragment composition.

Changes to native page width, height and margins are covered by maintained
forward/backward connector tests. Each fragment uses its own accepted physical
page snapshot; a page-number reset does not replace that geometry. The two relays
can have different y coordinates, and scene allocation can also give them
different x coordinates. Fixed split positions and user waypoints stay literal:
they can extend off-page. Avoidance diagnoses coordinates outside its declared
or inferred bounds rather than rescaling them. This is endpoint-page routing, not a
continuous diagram stretched across intervening pages.

## Obstacle-Aware Continuations

An ordinary connector retains its preferred relay. With `connector.scene`, sharp
orthogonal avoidance can replace an automatic relay when the preferred point is
blocked or unreachable. No extra setting is required. See the small
[two-page example](../../examples/obstacle-continuations.typ).

The replacement stays on the same top/bottom boundary, inside the physical page
and any explicit scene bounds. Both its point and inward shaft stub must clear
registered avoidance rectangles. Candidate ports share one search: the fallback
minimizes route length plus `bend-cost` per bend, plus horizontal displacement
from the preferred relay. Equal costs prefer less displacement, then lower x.
A usable preferred route is retained even if another port would be shorter.
The preferred attempt and fallback share the scene's `max-expansions` allowance;
`max-cells` bounds each search lattice. Exhausted budgets are not retried.
Fallback `search` statistics aggregate both attempts and add `attempts: 2`,
`preference` and `allocation-cost`. `score` remains shaft length plus bends;
`allocation-cost` also includes the horizontal preference penalty.

Each page allocates independently, so the two halves may use different x
positions. Existing peer destinations and user-supplied paired names remain the
way to identify a connection. This does not choose a left/right page edge, draw
through intermediate pages, reserve corridors or move note bodies.

`"split"` separates the two halves' hard visits and leaves its relay automatic.
`("split", x-spec)` fixes a literal position when `x-spec` is not `auto`; that
position is never moved. The same fallback search can include the real node's
other permitted automatic discrete ports; explicit sockets/percentages/sides
remain constrained. See [scene port selection](routing-scenes.md) and
[A Clear Way Out](../../examples/scene-ports.typ).
A blocked fixed port, unavailable permitted real ports, blocked hard waypoint,
unreachable boundary or exhausted budget remains a diagnostic with no unchecked
fallback. Without active avoidance, native routes and dots keep their defaults.

`continuation.allocation` contains `automatic`, `preferred` (page-space point),
and `shifted`. The scene callback runs once per fragment preparation, before
allocation, and sees the preferred geometry with `shifted: false`. Native layout
may evaluate that preparation again while converging. It is not called for
each candidate. The final painter and continuation marker receive the chosen
`point`; `document.endpoints` and `document.fragment` agree with that geometry.
An incoming fragment's source-local origin moves with its continuation. Exact
waypoints retain their original page coordinates and order. Heads prepare only
after selection, once per actual endpoint in that fragment.

Clearance concerns centerlines. Custom marker labels, heads and arbitrary text
ink need suitable registration, padding or placement; the allocator does not
measure a marker callback or guarantee its visual bounds.

## Cuts Along The Finished Route

To hide a middle section while preserving the curve on either side:

<!-- deixis-example: {"id": "manual-cut", "height": "150pt"} -->
```typst
#deixis-inset-note(width: 130pt, dx: 120pt, dy: 45pt,
  connector: (route: "curve", cuts: (at: 50%, length: 12pt)),
)[A passage][An explanation.]
```

Cuts are optional and disabled by default (`none` or an empty array). They act
after routing and head sizing, by subdividing existing line/Bézier segments.
They do not add waypoints, change ports, bend the curve, move heads, or affect
body placement. Unlike switching the route to `"none"`, a cut does not divide
interpolation into separately constructed curves.

Use either a center and length or an interval; use an array for several cuts:

```typst fragment
cuts: (from: 40%, to: 60%)
cuts: ((at: 30%, length: 1em), (from: 65%, to: 75%))
```

Coordinates accept nonnegative lengths or percentages; a centered cut's length
must be positive. Percentages refer to distance along the complete original
drawable route, before arrowhead trimming. Absolute positions start at its source.
Changing head size therefore does not shift a cut. Existing `"none"` jumps have
zero drawn length and are excluded from that distance. Font lengths use the
connection's declaration typography. Relative length-plus-percentage values are
not accepted; use a percentage or a length for each field.

Intervals are clipped to the route; overlaps and touching intervals merge.
Equal/reversed intervals or intervals outside the route are empty. A centered
cut near an endpoint is clipped rather than moved inward. Head trimming remains
independent, so a cut under an already removed shaft portion has no extra effect.
Hiding the whole shaft retains its configured heads. Arc lengths use the same
bounded numerical approximation as native head trimming.

Cuts and indicators are independent: `gap-marks` stays `none` unless requested.
Add `gap-marks: "slash"` or `"bar"` for paired ticks at surviving internal gaps;
endpoint cuts have no paired indicator. Stroke caps can project into a gap, and
native dash patterns restart at subpaths. Use butt caps when a precise clear
interval matters. Cuts describe centerline geometry, not obstacle ink clearance.

For cross-page edges, each painted endpoint-page route has its own distance
basis; the cut specification applies to each. No imaginary path through intervening
pages is measured. A custom painter can use `uncut-shaft` on selected pages when
only one page should retain a cut.

See the [small curve-cut example](../../examples/connector-cuts.typ).
Automatic crossing gaps require a separate explicit setting below. Bridges and
jump indicators remain future features and will also be optional/configurable;
enabling manual cuts does not enable detection.

## Automatic Gaps At Line Crossings

Add `crossings: "gap"` to each participating line:

```typst fragment
connector: (route: "polyline", crossings: "gap")
```

The default is `none`. Both connections must opt in and share a group, physical
page, and overlay layer. Higher `z-index` passes over lower lines; ties follow
the existing connection paint order. At equal priority, margin connections
precede inset connections, then explicit connections; explicit edges follow
declaration order. Reversing priority changes which line receives a gap. No body
is moved, and unselected lines do not participate. A plain gap exposes the actual
background instead of painting a background-colored band.

Use a dictionary for a separate diagram or different spacing:

```typst fragment
crossings: (group: <diagram>, gap: 10pt, clearance: 4pt)
```

`mode` defaults to `"gap"`, the only implemented effect. `group` is a nonempty
string/label, default `"default"`; equivalent strings/labels select the same group.
`gap` is the minimum missing distance along the underpassing shaft, default 8pt.
It can widen to clear the upper stroke at a shallow angle, including lower cap
projection. `clearance`, default 4pt, protects visible fragment ends on both lines,
with room for the whole gap on the lower line. These are font-capable lengths;
gap must be positive and clearance nonnegative. Percentages have no reference
basis here.

All native routes participate, including smooth curves, both Catmull–Rom
variants, and rounded orthogonal paths. Detection uses line/cubic geometry;
legacy route callbacks have no native geometry and cannot participate. A custom
`connector.render` may paint the supplied native shaft, including through a
third-party backend, but it must retain that geometry for crossing results to
describe the output. A disabled/zero-width shaft does not occlude other lines.

Detection uses geometry after head trimming and manual cuts. Higher lines are
processed first, so a lower line does not get a phantom gap beneath an upper
line's own automatic gap. Touches, true corner contacts, shared endpoints,
parallel/collinear overlap, and self-intersections within one connection are
excluded. Straight-through waypoints and smooth cubic joins remain eligible, with one hit
per physical crossing. Overlapping gaps merge. Multiple crossings of two curves
are independent; self-intersections within one connection stay excluded.
If a gap cannot fit with the requested clearance it is skipped; painters receive
the skipped point and reason. Gap marks stay independently optional.

Each cross-page continuation participates only on its painted endpoint page;
page-continuation dots retain their separate meaning. Hidden declarations and
hidden endpoints do not participate. Native body/external-object occlusion and
arbitrary painter silhouettes are outside this line-geometry contract. Use
explicit groups for separate diagrams; planning is pairwise and intended for
modest groups, without changing ordinary routes when disabled.
Dash patterns and transparency are not sampled: each participating shaft is
treated as continuous between its geometric cuts. Arrowhead silhouettes and
gap indicators are not additional crossing obstacles.

Curve detection subdivides control hulls to a 0.01pt geometric tolerance and
refines transverse intersections against the original cubic polynomials. The
original curve is retained for arc-length cuts and painting; no polyline is drawn
in its place. Exact tangencies and nearly tangent or sub-tolerance features are
not reliable crossing targets. A depth/leaf budget (12 levels, 1024 leaves per
original segment) bounds preparation; exceeding it gives a package diagnostic.
Gap sizing uses the local crossing angle, rather than a full stroke silhouette
or obstacle-clearance proof. Dense/tightly bending geometry may need explicit
cuts or custom painting. These controls never enable automatic body movement.

See the [small priority example](../../examples/automatic-crossings.typ) and
[curve comparison](../../examples/curve-crossings.typ).

## Head Styles And Custom Heads

`connector.heads` selects the head at each endpoint:

<!-- deixis-example: {"id": "custom-heads", "height": "150pt"} -->
```typst
#deixis-inset-note(width: 130pt, dx: 120pt, dy: 45pt,
  connector: (route: "curve",
    heads: (
      mark: "circle",
      body: deixis-arrowhead(shape: "diamond", length: 8pt, width: 6pt, fill: none, stroke: blue),
    ),
  ),
)[A passage][An explanation.]
```

Shapes are `stealth`, `triangle`, `vee`, `circle`, `diamond`, and `bar`. A shape or
`deixis-arrowhead(..)` by itself selects a body head, so `heads: "stealth"` points
at the note; `(mark: "stealth", body: "stealth")` draws both. `none` disables
both. Length and width default to stroke-scaled
sizes; fill inherits the line paint. The circle shape supports unequal length and
width, producing an ellipse. `trim` can override the shape's shaft shortening.

`stealth` is the filled open-notch tip; `vee` has constant-width stroked arms.
The [small comparison](../../examples/arrow-tips.typ) shows triangle, stealth
and vee side by side. Use `heads: "stealth"`, or
`deixis-arrowhead(shape: "stealth", length: 10pt, width: 9pt)` for explicit size.

Heads orient from the actual path tangent, including mixed segments and curves.
Shortening walks the actual path and subdivides Bézier curves. If heads consume
the entire path, the shaft is omitted; head size is retained and the two heads
may overlap. Coincident endpoints without a drawable path produce no heads.
Length calculations use adaptive numerical approximation, with a 0.005pt local
flatness tolerance and a subdivision depth bound.

A custom head callback receives one request dictionary:

| Field | Meaning |
| --- | --- |
| `length`, `width` | Resolved requested dimensions |
| `fill`, `stroke` | Resolved head styling |
| `endpoint` | `"mark"` or `"body"` |
| `tip`, `direction`, `frame` | `(0pt, 0pt)`, `(1, 0)`, `"tip-local-x-forward-y-down"` |

It returns `(body: content, trim: length, bounds: (left:, top:, right:, bottom:))`.
The tip is the origin; the shape extends mostly toward negative x. Return content
in those coordinates, with accurate visual bounds including any stroke. Deixis
rotates/translates the drawing and trims the shaft. The callback must avoid live
note state or registration: it describes reusable drawing content and geometry.

[Native head examples](../../examples/connector-heads.typ) and an
[optional CeTZ head adapter](../../examples/connector-cetz.typ) demonstrate both
paths. The CeTZ example imports CeTZ itself and translates its canvas back to the
local tip. The package does not import CeTZ.

## A Custom Connector Painter

When your own code already has coordinates, [numeric routing](numeric-routing.md)
provides line/cubic geometry without setup or page lookup. Separate preparation
can supply this same painter request, including trimmed/cut shafts and heads.

`connector.render(request)` replaces native painting after endpoint selection,
path construction, and trimming. It returns content in source-local coordinates:
origin at the selected source, positive x right, positive y down. It owns both the
shaft and endpoint-head output. Use `deixis-render-head(head, tip, forward)` to
paint a prepared head with the native transformation if useful.

| Request field | Meaning |
| --- | --- |
| `frame` | `"source-local-x-right-y-down"` |
| `route.origin` | Source origin in page coordinates |
| `route.start`, `route.end` | Original endpoints in source-local coordinates |
| `route.segments` | Untrimmed segment records; `kind`, `start`, `end`, and cubic `c1`/`c2` |
| `shaft` | Final segment records after head trimming, manual cuts, and automatic gaps; may be empty |
| `uncut-shaft` | Head-trimmed segments before manual cuts or automatic gaps |
| `manual-shaft` | Geometry after manual cuts, before automatic crossing gaps; native helpers can restore this shaft selectively |
| `cuts` | Sorted/merged requested intervals with resolved `from`/`to` distances on the original route |
| `crossings` | `none` or the resolved group/gap/clearance settings, paint `order`, automatic `cuts`, `hits`, and `skipped` points |
| `route.gaps`, `gaps` | Internal discontinuities in the original route and final cut shaft, respectively; each has local `start`, `end`, and unit `start-tangent`, `end-tangent` vectors |
| `gap-marks` | Prepared gap decoration with resolved shape/size/stroke, or `none` |
| `route.start-tangent`, `route.end-tangent` | Unit forward vectors, using nonzero derivative fallbacks |
| `route.bounds`, `route.length` | Conservative control-point bounds and approximate arc length; bounds exclude heads, gap marks, and stroke |
| `route.document` | Page identities, node page-space bounds, endpoint normals/roles, and adapter context |
| `heads.mark`, `heads.body` | Prepared head records or `none`; include body, trim, bounds and original request |
| `stroke` | Resolved native shaft stroke, or `none` for a disabled shaft |

Use `deixis-render-connector(request)` to reuse the complete native painter in a
callback. It paints the trimmed shaft, optional gap marks, then prepared heads, without
repeating geometry, sizing, or head callbacks. This halo recipe first paints a
wider shaft without heads, then paints the original connector:

<!-- deixis-example: {"id": "halo-painter", "height": "150pt"} -->
```typst
#let halo(request) = {
  deixis-render-connector(request + (
    stroke: stroke(paint: white, thickness: request.stroke.thickness + 4pt, cap: "round"),
    heads: (mark: none, body: none),
    gap-marks: none,
  ))
  deixis-render-connector(request)
}
#deixis-inset-note(width: 130pt, dx: 120pt, dy: 45pt,
  connector: (route: "curve", render: halo, z-index: 1),
)[A passage][An explanation.]
```

This assumes an enabled shaft and a white background. Overriding the painter's
stroke changes painting only: head sizes and trimming have already been resolved.
Prepared gap styling also stays unchanged unless `gap-marks` is overridden.
The helper paints the supplied shaft without applying `cuts` again. Replacing
`shaft` with `uncut-shaft` deliberately restores the full head-trimmed path, and
native gap marks follow that supplied geometry.
Replacing it with `manual-shaft` retains manual cuts while removing automatic
crossing gaps. `crossings.cuts` uses distance along that manual shaft, excluding
its existing holes; `cuts` keeps its original-route basis. Crossing hit/skipped
points use the source-local frame; hit `over` values identify page/layer paint
order, and skipped records have `reason: "clearance"`. Numeric route evidence is
published before automatic decoration and before your painter is invoked.
Give this edge a higher overlay priority than the line it crosses. A halo covers
anything beneath its band, including page content; use it deliberately.

Segments may be discontinuous when a mixed route uses `"none"`; respect each
segment's start rather than connecting across a gap. Overlay content uses the
host page's clipping behavior; arbitrary callbacks must not assume a dedicated
canvas or change the document's page settings. Margin lane staggering and page
continuation decorations remain adapter-owned.

A route can also be a callback, `connector: (route: callback)`. It receives absolute
`S-x`, `S-y`, `E-x`, `E-y`, source-local `waypoints`, `dx`, `dy`, `stroke`, `radius`,
legacy `mark`, semantic `heads`, axis directions, continuation flags, and adapter
context. `fixed-waypoints` lists pin visits in the same source-local coordinates.
`gap-marks` supplies the normalized style; this legacy callback owns its gap
geometry and decoration too.
Its normalized `cuts` also remain callback-owned. Use `connector.render` when
Deixis should construct, trim, and cut the native path before your painter runs.
Its returned content is placed at the source. It owns geometry and
painting; `connector.render` is preferable when Deixis should retain routing.

## Underpasses, Gaps, And Obstacles

To pass behind an opaque native object, use `connector.layer: "background"`.
For Deixis objects in the same overlay, priorities control their paint order.
Transparent areas still reveal the connector. Layer/priority selection does not
change the path.

To route around an object, choose ports and add waypoint pins or explicit bends
with the required clearance. No built-in route detects arbitrary objects.
Curves may overshoot their waypoint polygon, and rounded corners can cut inside
it, so check the resulting geometry.

For a true gap across a known crossing, use three mixed segments: draw to the
near gap edge, use `route: "none"` to the far edge, then resume drawing. This
leaves the background untouched. A `"none"` chunk at a real endpoint also removes
that endpoint's head. Exact pin visits retain corners on rounded routes.

To make a longer deliberate break visible, add one option:

<!-- deixis-example: {"id": "gap-marks", "height": "150pt"} -->
```typst
#deixis-inset-note(width: 130pt, dx: 120pt, dy: 45pt,
  connector: (
    route: "polyline", gap-marks: "slash",
    via: ((30pt, 0pt), "none", (20pt, 0pt), "polyline"),
  ),
)[A passage][An explanation.]
```

Your existing route switches stay valid. `gap-marks` defaults to `none`, leaving
the gap plain. `"slash"` or `"bar"` paints a paired tick at each internal gap's
visible ends, aligned with the local path tangent. The marks do not shorten the
shaft, change its route, or fill the hidden interval. They differ from the dots
that indicate continuation on another page. Keep small crossing gaps plain when
extra ticks would clutter the drawing; paired ticks suit a longer hidden section.

For explicit styling, use `gap-marks: (shape: "slash", size: 6pt, stroke: blue + 0.8pt)`.
The shape defaults to slash. Size is a positive length (including font lengths),
defaulting to the larger of 5pt and four marker-stroke widths; percentages have
no reference size. Stroke defaults to the shaft's paint/width/cap, with a solid
dash pattern so a short tick cannot disappear in a dash interval. `stroke: none`
suppresses decoration. A disabled shaft has no native gap marks.

An internal gap requires surviving shaft geometry on both sides. Undrawn chunks
at the real endpoints do not get paired ticks; if head trimming consumes an
adjacent fragment, it does not leave an orphaned pair. Adjacent undrawn chunks
form one gap. Size/clearance is user-controlled, so leave room for ticks beside
the object. The [gap example](../../examples/connector-gaps.typ) compares all three
styles. Custom painters receive gap positions/tangents and can reuse native
painting or supply another indicator; no new gap callback API is required.

The [manual crossing example](../../examples/connector-crossings.typ) demonstrates
an underpass, a halo, and a manual gap. Automatic line gaps are now opt-in as
described above. For object avoidance and bounded connector separation, use
the [scoped routing presets](document-routing.md#choose-a-routing-policy).
Enabled margin/inset shorthand captures the policy at its body declaration and
shares page/layer plans with explicit connections. It keeps its chosen geometry;
search presets require `route: "orthogonal", radius: 0pt`. The
[note example](../../examples/routed-notes.typ) keeps body placement independent.
Bridges/jumps are not implemented. Immediate body packing and cross-layer
collisions remain outside connector routing.
