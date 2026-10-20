# Numeric routing

When coordinates are already known, use `deixis-route` without notes, pins,
setup, page overlays or a layout context. The
[small example](../../examples/numeric-routing.typ) connects two custom cards.
For measured document content, keep using [pin connections](independent-connections.md#connect-pins-without-creating-notes).
For several sharp orthogonal fragments, use [group routing](route-groups.md) to
share a scene and run checked congestion repair before the same painting step.

```typst
#let path = deixis-route(from: (0pt, 0pt), to: (120pt, 40pt), route: "hobby")
#context {
  let drawing = deixis-prepare-connector(path, stroke: teal + 1pt, heads: "triangle")
  deixis-render-connector(drawing)
}
```

The three steps have separate responsibilities:

| Function | Result | Context |
| --- | --- | --- |
| `deixis-route(from:, to:, route:, via:, segments:, radius:)` | Numeric line/cubic geometry | None required; no queries, measurement or callbacks |
| `deixis-prepare-connector(path, stroke:, heads:, cuts:, gap-marks:)` | Existing connector painter request | Styles and custom head preparation can need context |
| `deixis-render-connector(request)` | Native drawing content | Uses the prepared request without rerouting or repeating head callbacks |

A custom backend can consume the numeric geometry directly, or consume the
prepared shaft/heads. Preparing again is only necessary when preparation inputs
change. Stroke-only halo passes can reuse the request as described in the
[painter guide](connectors.md#a-custom-connector-painter).

## Input plane and constraints

All points, including B-spline controls and points inside sections, use one
caller-defined plane: x increases rightward and y downward. Supply pairs of finite
absolute lengths, such as `(30pt, -10mm)`. Unitless numbers, font lengths,
percentages, frame dictionaries, pin targets and page splits are rejected.
Resolve those in your own adapter first. The numeric entry does not read
`deixis-set` defaults.

An endpoint is a point or `(point: ..., normal: ...)`:

```typst
#let path = deixis-route(
  from: (point: (20pt, 30pt), normal: right),
  to: (point: (180pt, 90pt), normal: left),
  route: "hobby", via: ((80pt, 10pt),),
)
```

Normals point **outward at both ends**, following the port convention. A curve
departs along the source normal and arrives opposite the target normal. Accepts
`left`, `right`, `top`, `bottom`, or a nonzero finite numeric vector such as
`(2, -1)`; vectors normalize internally. Omit `normal` or use `auto` for a free
endpoint. Orthogonal/chamfer endpoint normals must be cardinal. Polylines follow
their supplied vertices and do not add bends to satisfy normals.

`route` accepts the same native names and grouped algorithm settings as
[document connectors](connectors.md#routes-and-ports). The default is a straight
line. `radius` is a finite nonnegative absolute length, default `0pt`; it controls
orthogonal/chamfer corners. There is no stroke-dependent automatic radius in this
geometry-only entry. Legacy routing callbacks are not numeric builders.

`via` is an array of absolute points and native route switches. All supplied
numeric points are hard visits, as pin waypoints are in the document API;
rounded corners preserve them. Alternatively, `segments` uses the existing
`(route:, via:)` section records. Supply either `via` or `segments`, with `none`
meaning omitted. B-spline `controls` are also absolute input-plane points, but
influence the curve without becoming hard visits. Explicit equal B-spline/Hobby
switches delimit independent sections. A `"none"` section makes a discontinuity;
it does not cut an unchanged interpolating curve midway. Use `cuts` at preparation
for that. Page continuation belongs to the document adapter. Optional `scene`
and `page` arguments add [page-local nodes and avoidance](routing-scenes.md).

## Geometry result

The result has `kind: "deixis-route"` and
`frame: "source-local-x-right-y-down"`. It contains only numeric geometry:

| Field | Meaning |
| --- | --- |
| `origin` | Input source point in the caller's plane |
| `start`, `end` | Source-local endpoint positions; start is `(0pt, 0pt)` |
| `segments` | Ordered line/cubic records in that local frame |
| `bounds` | Conservative bounds including endpoint positions and cubic handles, with left/top/right/bottom/center-x/center-y |
| `length` | Approximate drawable arc length, excluding undrawn gaps |
| `has-start`, `has-end` | A drawable segment reaches the corresponding endpoint |
| `start-tangent`, `end-tangent` | Unit travel directions; zero when that endpoint has no drawable path |
| `gaps` | Internal discontinuities with start/end positions and travel tangents |

A line is `(kind: "line", start:, end:)`. A cubic adds `c1` and `c2`.
Consecutive records need not touch: a gap starts a new subpath. Custom painters
must preserve these breaks. Quadratic corners are elevated to cubics. No native
content, note IDs, pins, registry state or document metadata enters this result.

Bounds are conservative centerline/control bounds, not tight curve extrema or
stroke/head/ink bounds. Arc lengths and cuts retain the shared numeric precision
limits. Degenerate segments and hard-point duplicates within `0.00001pt` are
cleaned up. Coincident endpoints can still form a nonempty returning path.
Native overflow limits still apply to extreme coordinates and algorithm settings.

## Preparation and placement

`deixis-prepare-connector` accepts a geometry result. Defaults are black 1pt,
no heads, no cuts and no gap marks. Heads use the existing shape/custom-head and
`(mark:, body:)` conventions; cuts and optional ticks use the existing connector
records. Mark/body mean source/target here. Preparation keeps the route intact,
calls each present head renderer once, then trims/cuts its shaft. Head content
executes when painted, so painting it twice also repeats its content effects.
There is no measurement of custom node content. Opt-in scene cuts join explicit
cuts at preparation; crossing events remain available on the original route.

The request uses the existing source-local painter frame. `route.document` is
`none`; `crossings` is `none`, since an isolated route has no page/layer/group
context. It includes `route`, `shaft`, `manual-shaft`, `uncut-shaft`, `cuts`,
`heads`, `gaps`, `gap-marks` and `stroke` as in document callbacks.

The native painter does not apply `origin` automatically. To draw in the original
input plane, position its output yourself:

```typst
#context {
  let drawing = deixis-prepare-connector(path, heads: "triangle")
  place(top + left, dx: path.origin.first(), dy: path.origin.last(),
    deixis-render-connector(drawing))
}
```

Allocate your diagram's frame normally. Painting is overlay content and does not
reserve node or drawing dimensions. For automatic document lookup, page relays,
z-order and grouped crossing gaps, use `deixis-connect` instead.
