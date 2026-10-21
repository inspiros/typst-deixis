# Independent connections

Examples use the [standard import and setup](getting-started.md#1-start-with-native-footnotes).
Excerpts with existing IDs or callback variables extend the surrounding example.

Use body `connector:` options for the usual original-mark-to-body connection.
Use `deixis-connect` when a line needs its own source selection or configuration.
The [small editable example](../../examples/independent-connections.typ) draws two
independently styled connections to one body.

For custom objects, `deixis-attach(id: <card>)[...]` supplies a `(node: <card>)`
endpoint. A [routing wrapper](document-routing.md) collects individual connections
and plans them together, using attached obstacles. Existing selectors below
remain available inside that wrapper.

```typst
#deixis-inset-note(id: <shared>, connector: none,
  layer: "foreground", width: 100pt, dx: 120pt, dy: 50pt,
)[Original passage][One explanation.]
#deixis-mark(of: <shared>, occurrence: <again>)[Another passage]

#deixis-connect(from: <shared>, to: <shared>)
#deixis-connect(from: (mark: <shared>, occurrence: <again>), to: <shared>,
  connector: (route: "curve", heads: (body: "triangle")))
```

A label/string in `from` selects the annotation's original mark; one in `to`
selects its body frame. Explicit forms are `(mark: id)` and `(body: id)`. Add
`occurrence: name` to the mark selector to choose a named repeat. Label-valued
IDs resolve to the same annotation as strings of the same spelling;
occurrence names stay scoped to that annotation.
Neither reference labels nor unnamed repeats become geometric endpoints.
Named repeats may be inline frames, region spans, or phantom points. Regions use
their fragment on the body's page, clamped to the first/last fragment when the
body is outside the span. A named phantom supplies an intentional zero-size
semantic point; a hidden inline repeat still has no drawable frame. See
[shared notes](shared-notes.md).
To choose a live body content boundary instead of a frame, use
`(body: id, point: "start")` or `"end"`.

## Connect pins without creating notes

If coordinates are already known, [numeric routing](numeric-routing.md) builds
the same native geometry without setup or document declarations. Pins remain
useful for measuring actual placed content and selecting its page.

Pin connections also support a control polygon, without declaring any note:

```typst
#deixis-connect(from: (pin: <source>), to: (pin: <destination>),
  connector: (route: (kind: "b-spline", controls: ((pin: <bend>),))))
```

Controls bend the curve without promising an exact visit. Use `via` for exact
knots and explicit sections to combine them; see
[influence curves](connectors.md#influence-point-curves) and the
[small comparison](../../examples/control-curves.typ).

The routing core is also useful for diagrams made entirely of your own content.
Attach pins to cards, figures, table cells, or other native elements, then use
`deixis-connect` for the edges. This shares routes, heads, manual cuts, optional
crossing gaps, layers, and custom painters with note connectors. The
[card example](../../examples/pin-connections.typ) is a small complete drawing.
No note mark or body is required; setup supplies the page overlays and lookup.

```typst
#deixis-connect(from: (pin: <out>), to: (pin: <in>),
  connector: (route: "curve", via: ((pin: <bend>),)))
```

Pins can be either endpoint, including pin-to-pin, mark-to-pin, or pin-to-body
connections. A bare string/label keeps its existing note-ID meaning; `(pin: ...)`
makes pin selection explicit. Define the pins directly with `deixis-pin` or
attach them to arbitrary content with `deixis-attach`. Declarations may precede
the pins, and pins inside deferred body renderers work too. No phantom annotation,
body, counter, or reference origin is created. See the
[small editable example](../../examples/pin-connections.typ).

`pin` takes a name or `(name:, scope:, select:, page:)` record. Names/scopes accept
equivalent strings/labels; native location scopes isolate component instances.
The default requires one unique occurrence. Use first/last or a page restriction
to select deliberately; `select: "all"` must still yield just one point here.
Connections use the native pin position, ignoring its region-padding preset.
An unconfigured pin is a zero-size, direction-free endpoint. Existing
`ports.mark/body` sides/gaps can constrain departure/arrival. The callback's
endpoint identity contains `(pin:, scope:, location:)`; it is not a note ID.

A pin in `ports` instead replaces a note's attachment point while preserving
its full bounds. Use `(pin: target, side: left, gap: 2pt)` there; see
[custom ports](connectors.md#pins-as-custom-ports). This requires the node's page,
whereas a pin endpoint chooses its own page and needs no body frame.

Pin waypoints must belong to the route's page. For a cross-page route, place
source-page pins before the existing `"split"` control and destination-page pins
after it, for example `via: ((pin: "out-bend"), "split", (pin: "in-bend"))`.
Without a split, waypoints belong to the source side. Wrong-page or intermediate
pins are diagnosed instead of reusing their coordinates on another page. The
connection retains its existing endpoint-only page-continuation policy.

## Ownership and defaults

Each declaration draws one additional edge. It does not replace, deduplicate, or
restyle the body's implicit connection. Use `connector: none` on the body when
declaring all lines yourself. Several edges can share nodes without narrowing
their bounds or candidate ports.

The 0.2 API keeps shorthand on bodies. Creating or reusing a mark never inherits
an edge, and there is no mark-side `connector:` option. Name an occurrence and
use `deixis-connect` to add its connection, including before the original/body.
This keeps the simple note call short and makes additional edges explicit.

An explicit declaration defaults to a straight line and foreground. Its
`connector` dictionary accepts the same route, ports, waypoints/segments, heads,
stroke, radius, renderer, and layer settings as body connectors. The `mark` and
`body` port/head names retain their endpoint roles. A head alone works here
because the explicit default route is enabled; body shorthand retains its usual
disabled route default.

Settings and typography come from the connection declaration, independently of
the destination body. Configure explicit connections through the `connection`
type in `deixis-set`, for example:

```typst
#deixis-set(
  connector: (connection: (route: "curve", heads: (body: "circle"))),
  stroke: (connection: teal + 0.8pt),
)
```

Each declaration captures its settings. Later changes do not restyle earlier
edges. Explicit calls have no note counter, body, reservation, placement anchor,
outline entry, or PDF return-link origin. They are metadata-only in the document
flow. `connector: none` disables the declaration and skips endpoint resolution;
its selector shapes are still checked.

## Supported endpoints and pages

- Sources: original inline, phantom, or region marks, plus visible named repeated
  inline frames. Original inline marks keep the existing typographic marker-bound
  approximation. Use a named repeat to route from a complete short passage box.
- Destinations: one painted margin or inset body, in any body layer, or an inline
  body declared with `breakable: false`. Standalone
  bodies can be destinations through their ID/public label, but have no original
  mark to use as a source. Source and destination may belong to different notes.
- Point destinations: start/end locations from any supported body adapter,
  including printed endnotes, native page/block footnotes, and unframed inline
  bodies. The selected point determines the destination page.
- Forward declarations work for originals, body labels, and named repeats. The
  declaration can occur anywhere in the document; its position does not anchor
  the edge. Actual endpoint geometry determines routing.
- Cross-page routes paint on the source and destination pages in either selected
  overlay. They retain continuation/head ownership and do not paint intermediate
  pages or create new pages. A region source uses the fragment on the body's
  page when available, otherwise the closest endpoint page of that region,
  matching the existing inset policy.

Destinations use prepared margin bounds or actual inset corner probes, without
measuring or replaying their bodies per edge. Missing/hidden sources, unknown
occurrences, unsupported body types, and missing/fragmented/duplicated body frames
produce diagnostics outside the painting callback. Hidden named repeats keep
their return-link identity but deliberately have no routing ports.
Every frame also needs one complete live body span and destination on its page.
An inset whose live boundaries fall outside its proposed frame cannot be selected
as a whole body; this includes continuation into another column on the same page.
Choose an explicit start/end point for such a body.

## Connect to a collected or paginated body

Choose a body's live content boundary to connect to an endnote or footnote,
including a long body that continues across pages:

```typst
#deixis-endnote(id: <detail>)[An explanation printed later.]
#deixis-connect(from: <detail>,
  to: (body: <detail>, point: "end"))
#deixis-print-endnotes()
```

`point: "start"` selects the native location before the live body payload;
`"end"` selects the location after it, on its final printed page. These are
zero-size points. They do not enclose the marker, container, or backlinks and
do not measure glyphs. For block content, Typst commonly reports them at the
leading edge of the first/last content line, rather than after the final glyph.
Use directional `ports.body` and its `gap` to keep arrowheads clear of text.
Body-relative waypoints use the selected point as their reference position.

Native, aligned, grid, and column endnote layouts retain their own pagination.
Native page/block footnotes keep their reservations and allocation. The printer
must actually print the body; a connection does not trigger printing or create
a reservation. Declarations can precede the original, body, or printer. Repeated
or overlapping printers still emit one body. See the
[small editable example](../../examples/collected-connections.typ).

Points also work on margin/inset and ordinary inline bodies without imposing a
single-frame layout. Their native start/end positions, recorded by the live
renderer, determine routing. Exactly one complete start/end span and one live
body destination are required. Missing/unprinted, suppressed, or duplicated body
output is diagnosed outside painting; an incomplete span is never silently
replaced with a link destination.

The default `point: none`, or an omitted field, keeps the complete-frame contract
below. A point selection does not add a reference origin, change a note number,
move a body, or change native wrapping. Start/end points are supported now;
rectangular continuation fragments and selection by arbitrary page remain
deferred. Start/end points also follow bodies that continue between columns on
the same page, in either text direction. A matching start/end page alone does
not mean the body fits one frame.

## Connect to a body in normal flow

Inline bodies can supply a complete frame without changing their declaration's
placement role. Opt into one native nonbreaking frame with `breakable: false`:

```typst
#deixis-mark(id: <idea>)[A new idea]
#deixis-inline-note-body(of: <idea>, inline: true,
  breakable: false)[A short explanation]
#deixis-connect(from: <idea>, to: <idea>)
```

With `inline: true`, the frame is an inline box, so the complete note stays
together on one line. With `inline: false`, it occupies a nonbreaking block.
It may move to the next line/page when needed. Its native frame includes the
rendered marker, body, backlinks, and container. Ports use the four live corners;
surrounding native transforms produce their page-space envelope. A child that
paints outside its native frame remains outside those bounds.

The default `breakable: true` keeps the existing rendering path; selecting it as
a complete-frame destination reports that a single frame is required. Explicit
start/end point targets remain available. Adding or
disabling edges does not change whether/how the body is framed. No new body or
reference origin is created per incoming edge. Forward IDs, named sources,
standalone bodies, and both connection layers work as for margin/inset targets.

A custom single renderer must preserve exactly one live rendered span and body
destination, as built-in renderers do. Suppressing or duplicating its output
cannot produce a valid frame merely because an outer box exists. Long bodies
should keep native pagination; a nonbreaking body can overflow an undersized
page, as native nonbreaking containers do. Fragment selection remains separate
work. See the [small editable example](../../examples/connected-inline-bodies.typ).

## Routing limits

Explicit edges use the generic port/waypoint router. Margin body shorthand keeps
its existing lane staggering and spillover relay heuristics; extra independent
edges do not automatically join those lanes. Ports and waypoints can constrain
routes, but do not provide general obstacle avoidance.

Complete footnote/endnote frames and arbitrary continuation rectangles need
separate fragment/geometry contracts; explicit start/end points are supported.
The declaration cannot
force an endnote printer or reserve a native footnote at another location. Custom
renderers must preserve the single-frame contract and rendered-span metadata;
rendering the passed body zero or several times is not a selectable destination.
Immediate body transforms retain the placement limits described in
[rendering](rendering.md). Use `connector.z-index` for independent ordering
within that overlay; [paint order](paint-order.md) explains ties, atomic groups,
and native state/layer boundaries.

See [connectors](connectors.md) for route/head/renderer contracts and
[body ownership](ownership.md) for page allocation and placement rules. Modern
painters receive canonical source/target identities under
`request.route.document.connection`; legacy painters receive `connection` in
their request. Neither contains live body content.
For a point destination, the target identity is `(annotation: ..., point: "start"
| "end")` and the reported body bounds have zero width/height. Complete-frame
target identities keep their existing form.
