#import "reference/catalog.typ" as api
#import "manual-style.typ": *

#let param-row(name, info) = {
  let default = info.at("default", default: none)
  [#mono(name)#h(0.5em)#text(fill: muted, size: 8pt)[#if default == none { if name.starts-with("..") { [variadic] } else { [required] } } else { [#text("= ")#mono(default)] }]]
}
#let entry-card(entry) = block(breakable: false, above: 4pt, below: 3pt, {
  let fn = api.function(entry.names.first())
  let args = fn.at("args", default: (:))
  // One linked function heading per exported name, even for shared/preset cards.
  let title = entry.names.map(name => [#metadata(name)<manual-api>#box(mono(name, size: 9pt))#label("api-" + name)]).join([#linebreak()])
  block(breakable: false, above: 5pt, below: 3pt)[
    #line(length: 100%, stroke: 0.5pt + luma(210))
    #v(4pt)
    #title
    #v(4pt)
    #setup-badge(entry.setup) #if entry.at("extension", default: false) { badge("EXTENSION HOOK") }
    #h(0.5em)#text(size: 8pt, fill: muted)[Returns #entry.at("returns", default: "content")]
    #v(3pt)
    #entry.summary
    #if "call" in entry { code(entry.call) }
  ]
  if entry.args.len() > 0 {
    block(above: 3pt, below: 4pt, inset: (left: 8pt), stroke: (left: 1.2pt + accent.lighten(65%)))[
      #text(size: 7.5pt, fill: muted)[SELECTED PARAMETERS · SOURCE DEFAULTS]
      #v(3pt)
      #grid(columns: (1fr, 1fr), column-gutter: 12pt, row-gutter: 3pt,
        ..entry.args.map(name => param-row(name, args.at(name))))
    ]
  }
  if "note" in entry { block(above: 3pt, below: 4pt, text(size: 9pt, entry.note)) }
  let guide = entry.at("guide", default: none)
  if guide != none { text(size: 8pt, fill: muted)[Guide: #mono("docs/guides/" + guide, size: 7.5pt)] }
})

= API At A Glance

Start with a note wrapper. Reach for marks/bodies when authoring positions differ,
and independent connections when one explanation needs more edges. The entries
below cover every public export, with shared/preset functions grouped together.

#table(columns: (auto, 1fr), inset: 5pt, stroke: none,
  setup-badge("setup"), [Uses the document annotation system; apply `deixis-setup-notes` first.],
  setup-badge("free"), [Works with supplied content or numeric geometry, without note setup.],
  setup-badge("conditional"), [Numeric/supplied data needs no setup; document lookup or live annotation behavior does. See the entry.],
  setup-badge("installs"), [Installs the document machinery.],
  badge("EXTENSION HOOK"), [Low-level callback or integration API; normal note calls usually suffice.],
)

Badges classify *setup*, not Typst `context`. Queries and document geometry need
context; relative styles and custom painting can need it even on a “No Setup”
path. Direct render helpers do not initialize or register a note.

This is a compact reference: displayed parameters/defaults come from each entry’s first function in runtime
source. Long option sets are shared below; task guides explain records, edge
cases and recipes. A listed `auto` is an argument default, not necessarily the
final value: factory settings and the current Deixis scope can resolve it.

#v(6pt)
#grid(columns: (1fr, 1fr), column-gutter: 12pt, row-gutter: 3pt,
  ..api.exports.sorted().map(name => link(label("api-" + name), mono(name, size: 7.5pt))))

#pagebreak()
= Shared Note Options

Wrappers take `[body]` or `[passage][body]`; body-only functions take `[body]`.
Options apply only where accepted by that adapter. Inherited options stay
omitted in the compact entries rather than repeated for every note type.

#let rows = (
  ("id", "Original/standalone identity; omit for private wrapper identity."),
  ("of", "Attach a body or reuse a mark; exclusive with id."),
  ("data", "Opaque author fields on creation; inherited by attachments/reuse."),
  ("target", "Rendering/counter scope. Attachments inherit their original instance; target: 0 deliberately selects the caller."),
  ("series", "Counter/collection stream. Attachments inherit it; original wrappers choose their adapter's stream."),
  ("marker", "Automatic numbering, a literal marker, or none to hide it."),
  ("numbering", "Pattern/callback, or (restart: \"page\", pattern: \"1\") for original-page display ordinals. Assigned counters stay unchanged; reuse keeps the original marker."),
  ("marker-style", "Callback for marker content; may select mark/body components."),
  ("stroke / fill / radius", "Shared visual styles; component maps distinguish mark, body and connector."),
  ("layer / z-index", "Placement/paint layer and within-layer priority; connector layer stays independent."),
  ("backlink", "Return links from the body: true, false, always, never/none, or multiple."),
  ("container-func / container-args", "Wrap the rendered body; native/custom options stay in container-args."),
  ("render-single / render-group", "Replace body/group formatting; preserve live destination/content helpers."),
)
#table(columns: (1.1fr, 2.9fr), inset: 5pt, stroke: (bottom: 0.3pt + luma(220)),
  ..rows.map(((name, hint)) => (mono(name, size: 7.5pt), text(size: 9pt, hint))).flatten())

== Settings And Defaults

`deixis-configure` is an identical alias of `deixis-set`. For short calls, import
the `short` module, then `import short: *`: use `configure`, `footnote` and
`note-block`. Native `block` remains available. Other aliases omit `deixis-`;
`short as dx` supports qualified calls such as `dx.footnote`.

`deixis-set` accepts palette, numbering, marker-style, body-style, backlink,
marker-position, inline-mode, stroke, fill, radius, connector, separator,
clearance, gap, marker-gap, indent, margin-layout, min-margin-width, side-strategy, mark-align, mark-align-strictness, spillover,
overflow, region-shape, layer, z-index, render-single, render-group and
container-func. Every argument defaults to `auto`, leaving current settings intact.
Type/component dictionaries keep the API small; see `configuration.md`.

Factory marks use muted blue-gray and a faint tint. Body marker gaps are 0.05em
for footnotes, 0.25em for margin/inset/inline, and 0.75em for endnotes. Inset and
page-footnote bodies default to flow; margin bodies to foreground. Page footnotes
use the native footer's typography, separator and gap. Read the placement table
in the tour before changing layers. A palette is opt-in.

#pagebreak()
= Connector Records

A margin/inset body accepts `connector: (...)`; `deixis-connect` uses the same
record. A route name is shorthand, as in `connector: "curve"`. All fields are
optional and merge with `deixis-set(connector: ...)` defaults field by field;
enabling a head does not enable a disabled route.

#table(columns: (1fr, 3fr), inset: 5pt, stroke: (bottom: 0.3pt + luma(220)),
  mono("route"), [Polyline, orthogonal/chamfer, interpolating curve/Catmull-Rom/Hobby, or B-spline influenced by controls. Route records use `kind` and algorithm-specific settings.],
  mono("ports"), [Mark/body sides, side intervals, exact percentages, or a pin-defined custom socket. Outward normals describe departure/arrival direction.],
  mono("via / segments"), [Exact visits or route-section records. Use one representation at a time; controls are distinct from exact waypoints.],
  mono("heads"), [Independent mark/body heads: a native shape, head specification, callback, or none.],
  mono("stroke / radius"), [Single line stroke and turn radius, independent of rectangular node edge/corner styles.],
  mono("cuts / gap-marks"), [Hide intervals on finished curve arc length; optional slash/bar indicators decorate surviving gaps.],
  mono("crossings"), [Optional automatic gaps on participating lower-priority shafts. It does not enable obstacle avoidance.],
  mono("continuation / spill"), [Optional dot/portal/custom page markers and page-local allowed intervals. Margin destinations default to their physical channel, others to content width.],
  mono("scene"), [Prepared scene or page callback for explicit interactions outside collected routing, or under manual policy.],
  mono("render"), [Custom painter receiving prepared geometry, styles, heads and decorations. Delegate to deixis-render-connector.],
  mono("layer / z-index"), [Foreground by default, or background; independent body/edge priorities. No connector flow layer.],
)

== Geometry And Failures

Pins and hard visits stay exact. Scene avoidance and collected repair require
sharp orthogonal routes. Avoidance checks centerlines; thick strokes/heads may
extend outside them. Node behaviors are avoid, ignore, cut or cross; indicators
are always opt-in. Independent page fragments may have different continuation
positions when page dimensions change. No shaft is drawn on intermediate pages.

The numeric API returns geometry/failure records; inspect failure status before
preparing paint. Document APIs diagnose unresolved endpoints and unsupported
geometry. Budgets bound repair work; they do not guarantee global optimality.
See `connectors.md`, `document-routing.md`, and `routing-scenes.md` for details.

#for group in api.groups {
  if group.title != "Rendering Extension Points" { pagebreak() } else { v(15pt) }
  heading(level: 1, group.title)
  group.intro
  parbreak()
  text(size: 8pt, fill: muted)[Guide: #mono("docs/guides/" + group.guide, size: 7.5pt)]
  for entry in group.entries { entry-card(entry) }
}
