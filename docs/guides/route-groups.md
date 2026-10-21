# Routing A Group

Use `deixis-route-group` when several connectors should be planned together.
For ordinary document content, [routing objects in place](document-routing.md)
collects individual `deixis-connect` calls and attached geometry automatically.
It returns sharp orthogonal routes through fixed page geometry. Coordinates
alone need no note setup:

```typst
#let plan = deixis-route-group((
  (from: (0pt, 0pt), to: (100pt, 0pt)),
  (from: (0pt, 1pt), to: (100pt, 1pt)),
))
#context for path in plan.routes {
  if path.status == "ok" {
    let request = deixis-prepare-connector(path, heads: "triangle")
    place(top + left, dx: path.origin.first(), dy: path.origin.last(),
      deixis-render-connector(request))
  }
}
```

The [small drawing example](../../examples/route-group.typ) uses named scene
nodes and a shared exit. Each returned path uses the existing
[numeric preparation and painting API](numeric-routing.md); planning executes
no head, painter or note-body callback. Prepare and paint accepted paths once.

## Edges And Scenes

Each edge requires `from` and `to`. These accept the existing
[scene endpoints](routing-scenes.md): absolute point pairs, outward normals,
named nodes, explicit side/percentage sockets and owned boundary points. Add
`scene: scene` to reuse prepared obstacles, page bounds, cuts and accepted
mark/body/pin geometry. Omitting it creates an empty unbounded scene.

Optional edge fields are:

| Field | Meaning |
| --- | --- |
| `via` | Ordered exact absolute points; no route switches or influence controls. Like single-route scene search, at most eight visits per fragment. |
| `page` | One physical page plane. Named nodes can infer it; both endpoints must belong to the same plane. |
| `id` | Optional caller lookup name: a nonempty string or native label. It creates no note or pin. Equivalent string/label IDs must be unique on the same page. |

At most sixteen fragments can be planned together. Results preserve input order
and add a zero-based `index` and normalized `id` (`none` when omitted). An empty
array returns an empty plan with zero work. Input order supplies deterministic
priority and ties; repair can reconsider earlier routes to improve the group.

Ports, outward escape stubs, visits, obstacles and assigned pages remain fixed.
Automatic node-side selection resolves once toward the peer before planning.
Repair does not search alternative sockets. Split cross-page edges into explicit
fragments yourself; page planes can have different dimensions, and reservations
never cross between them. Global budgets can affect how much work reaches later
fragments.

Hidden document nodes intentionally have no accepted frame/page. A hidden-endpoint
failure retains the explicitly requested `page`; supply it when reusing an edge
ID across covered page fragments. This preserves page ownership without inventing
geometry for hidden content.

This function always uses sharp orthogonal geometry. Use `deixis-route` for
single native curves, mixed sections or smoothing.

## Shared Junctions

Use the same scene socket for an intentional shared junction:

```typst
#let plan = deixis-route-group(scene: scene, (
  (from: (node: <hub>, side: right), to: <first>),
  (from: (node: "hub", side: right), to: <second>),
))
```

Scene identity and the exact resolved point define the junction. String and
label names agree; the same socket can appear at either end of an edge. Only
the actual common mandatory outward stub is shared. Nearby parallel lanes,
different sockets, foreign obstacles and subsequent coincident shafts retain
their usual avoidance/contact meaning.

A named ignored point, including a selected document pin, supplies a point
junction without a mandatory stub unless a side is explicitly requested.
Coincident anonymous coordinate pairs or two different named nodes at the same
coordinate do not imply a junction. Intermediate `via` points stay hard visits.
There is no additional public junction-name namespace.

## Options And Work Limits

```typst
deixis-route-group(edges, scene: none, spacing: 3pt, weight: 4,
  max-detour: 25%, rounds: 2, max-searches: 64, max-expansions: 50000)
```

| Option | Meaning |
| --- | --- |
| `spacing` | Positive absolute centerline proximity distance. **This is not stroke or arrowhead clearance.** Exact spacing incurs no proximity charge. |
| `weight` | Finite nonnegative multiplier for parallel exposure. Zero preserves independent geometry and tie behavior. |
| `max-detour` | Finite nonnegative ratio. Every accepted route stays within its independent length multiplied by `1 + max-detour`; the reference never grows during repair. |
| `rounds` | Integer zero through four. Zero retains independent planning and the initial soft proposal, with no subsequent repair rounds. |
| `max-searches` | Positive shared search-count limit, including unsuccessful and rejected attempts. |
| `max-expansions` | Positive shared expansion limit. The scene's per-attempt expansion and lattice-cell limits still apply. |

The planner first checks independent routes, then tries a soft proposal and
bounded repairs. A proposal commits only if it retains successful routes,
respects detour limits, adds no accidental contacts/proper crossings/collinear
overlap, and reduces group energy. Each proposal changes one page only; another
page's improvement cannot pay for new collisions here. Ties keep the incumbent.

Limits preserve checked incumbent geometry. If independent planning itself
failed or exhausted a budget, that entry remains an explicit
`deixis-route-failure`, with `status`, `detail`, `page` and `stats`. It has no
drawable segments. Inspect failures before painting; the successful entries can
still be used. Complete separation and global optimality are not guaranteed.

## Results And Quality

The result has `kind: "deixis-route-group"`, `routes`, `quality` and `stats`.
Successful entries are ordinary `deixis-route` records with scene cut/cross
interactions computed only after acceptance. Individual search statistics retain
their usual geometric score; changing reservations do not expose a misleading
per-route congestion total.

`quality.before` describes independent plans; `quality.after` describes the
accepted group. Both contain:

| Field | Meaning |
| --- | --- |
| `missing` | Number of entries without checked geometry. |
| `length`, `score` | Total shaft length and length plus bend cost. |
| `exposure` | Summed parallel overlap within spacing, counting each unordered route pair once and excluding intentional shared stubs. |
| `overlap`, `shared` | Accidental collinear overlap and intentional common-stub overlap. |
| `contacts`, `crossings` | Accidental contact locations and their proper-crossing subset, counted per route pair. Intentional junction geometry is excluded. |
| `energy` | Score plus weighted exposure, used to accept improvements. |

Geometric values are native lengths; counts are integers. Quality describes
uncut centerlines. Heads, painting cuts and optional crossing decorations do not
change planning scores or clearance. A plan with no accepted repair can be the
correct bounded result.
Exposure and shared overlap are pairwise measures, not the unique ink length of
a trunk shared by several connectors.

`stats` reports `searches`, charged `expanded` work, repair `rounds` entered and
`limits-hit`. Limits identify `searches`, `expansions`, `cells`, or
`attempt-expansions`. Index preparation has separate fixed internal bounds and
falls back to scanning without changing geometry or charged expansions.

Create and reuse a plan when its resolved geometry stays the same. The bounded
planner can still be expensive in repeated document layout passes; indexing is
not a general speed guarantee. The separate [document adapter](document-routing.md)
handles explicit scopes/pages/layers. Moving note bodies, arbitrary ink discovery,
safe rounding and stroke/head envelopes
remain separate work. Ordinary margin placement and single-route defaults are
unchanged.
