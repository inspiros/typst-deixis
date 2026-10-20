# Configuration and renderer callbacks

`deixis-configure` and `deixis-set` are identical aliases. Existing calls remain
valid; the optional [short API](getting-started.md#optional-short-names) uses
`configure` and names the scoped container `note-block`, preserving native `block`.

Start with direct options on a note. Use `deixis-set` for defaults shared by
subsequent declarations, and put it inside a `deixis-block` to keep it local:

```typst
#deixis-set(stroke: blue)
A point#deixis-footnote[An explanation.].

#deixis-block[
  #deixis-set(stroke: orange)
  A local point#deixis-footnote[A locally styled explanation.].
]
```

A small function can serve as a reusable preset; there is no additional preset
registry. See [the editable example](../../examples/configuration.typ).

For a final copy without editorial annotations, use
`deixis-set(omit: (series: ("todo",)))`. This creation policy preserves passages
and skips the selected annotations entirely; `omit: none` includes all series.
See [review comments and final builds](review-comments.md).

Settings follow **Deixis block scopes**. Ordinary Typst content brackets do not
restore them. Leaving a `deixis-block` restores its parent's settings. A top-level
`auto` argument leaves the current setting unchanged; it does not reset a value
to its factory default. Use `none` only where that option supports it (for
example, disabling a stroke). Empty dictionaries have the rules described below.

## Type and component dictionaries

Shared visual values such as stroke/fill/radius can select a note type in
`deixis-set`, then a component within that type:

```typst
#deixis-set(
  stroke: (inline-mark: blue, inset-note: (body: teal, connector: gray), rest: red),
  radius: (mark: 2pt, body: 0pt),
)
```

`mark`, `body`, and `connector` name components; `connector` is the line drawn
between them. `nodes` supplies both mark and body;
an explicit component takes precedence over `nodes`. `rest` supplies unmatched
types/components at its level. Keep note-type and component keys at different
levels, including when using `nodes`. Local note options accept component scope;
note-type scoping belongs in `deixis-set`.

Type keys select the component's actual adapter. An inset note with an inline
mark uses `inline-mark` for its mark and `inset-note` for its body/connector.
Likewise, `numbering: (footnote: "i")` does not configure an inline mark's
numbering: use `numbering: "i"` or `numbering: (inline-mark: "i")`. Region and
phantom originals have their own mark types. To style both halves of just one
note family, a small wrapper preset with local component options is usually
clearer than document-wide mark defaults.

Single-role options choose the relevant component automatically:

| Options | Component |
| --- | --- |
| `numbering`, `marker-position`, `inline-mode`, `region-shape` | `mark` |
| Body styling, backlinks, body/group spacing, renderers, containers, margin placement policy | `body` (also accepts `nodes`) |
| `connector` | `connector` |
| `marker-style`, shared stroke/fill/radius/layer | The component being rendered |

For example, `render-single: (body: my-renderer)` and `container-func: (nodes:
my-container)` work without returning an unresolved dictionary to the painter.
The simpler `render-single: my-renderer` also works. Sidenotes use the
`margin-note` type; see the preset details below.

## Native values and incremental updates

A dictionary containing native value keys stays a value. In particular,
`radius: (top-left: 3pt, bottom-right: 6pt)` supplies native corner values. Inline
box/parentheses end caps retain those outer corners and square their inner edges.
`radius: (:)` explicitly requests square corners, including in inline marks.

Rectangular regions, body containers, and inline box/parentheses/underline marks
also accept native per-edge strokes:

```typst
#deixis-inset-note-body(layer: "flow", container-func: deixis-rect-container,
  stroke: (left: blue + 2pt, bottom: gray, rest: none),
)[An explanation with two borders.]
```

`top`, `right`, `bottom`, `left`, `x`, `y`, and `rest` follow native rectangle
semantics. Missing edges are absent; an explicit `stroke: (:)` suppresses all
borders. Each edge accepts a stroke/color/length or `none`, with a default 1pt
thickness for color-only strokes. A stroke-attribute dictionary such as
`(paint: blue, thickness: 2pt)` remains a single stroke. Region radius
`top`/`bottom`/`left`/`right`/`rest` shorthands also survive page fragmentation;
only adjoining edges and corners are removed at page joins.

For connectors, select a single link stroke and radius independently of the
rectangular node styles:

```typst
#deixis-set(
  stroke: (nodes: (left: blue, rest: none), connector: gray + 0.7pt),
  radius: (nodes: (top: 4pt, bottom: 6pt), connector: 2pt),
)
```

Enabled connectors diagnose an edge/corner dictionary used as a line stroke or
turn radius; `connector.stroke`/`connector.radius` can also supply the scalar
override. `inline-mode: "text-fill"` needs a single stroke paint; `stroke: none`
or a colorless stroke such as `1pt` preserves the passage's inherited color. Edge maps are ambiguous for text paint
and receive a focused diagnostic. Custom containers/shapes own the native styles
they accept; per-edge borders apply to rectangles, while ellipses require a
single stroke. See the [small native-style example](../../examples/native-styles.typ).

Compatible dictionaries merge recursively across repeated settings updates, so
separate component/type branches and native corner updates can be incremental.
Changing representation replaces the old dictionary at that level:

```typst
#deixis-set(radius: (body: 3pt))
#deixis-set(radius: (top-left: 6pt)) // Replaces the component map.
#deixis-set(radius: (:)) // Clears it to an empty native radius.
```

The same rule prevents type scopes and component scopes from being combined by
separate updates. An empty dictionary clears its current level. For options
without literal dictionary values, an empty scope map has no matching branch
and falls through the normal cascade. `auto` on a local component override keeps
the inherited value; `auto` within a settings map clears that branch so lower
configuration levels can supply it.

Connector dictionaries and head specifications keep their own meanings. For
example, `connector: (heads: (mark: "circle", body: "triangle"))` selects
endpoints, and `connector: (heads: (:),)` explicitly clears heads instead of
inheriting earlier defaults. Margin `mark-align: (mark: bottom, body: top)` likewise describes an
anchor pair; it stays intact rather than selecting the body's branch. These are
distinct from component-scoped visual styles. See
[connectors](connectors.md). `container-args` and annotation `data` remain opaque
explicit dictionaries outside this cascade.

## Declaration-Time Defaults

The original mark captures its marker style when it is declared; references and
reused marks retain that style. A body resolves its own marker-style branch,
renderer and layout defaults where its body declaration occurs. This also holds
when the body precedes its original. Changing defaults between declarations does
not retroactively restyle earlier components. An inline body follows the same
body-marker cascade as footnote, endnote, margin and inset bodies:

```typst
#deixis-set(marker-style: (mark: it => super(it), body: it => strong(it)))
#deixis-mark(id: <detail>)[A passage]
#deixis-inline-note-body(of: <detail>)[An explanation with a bold marker.]
```

Explicit local body options take precedence. Shared stroke/fill/radius also
inherit explicit options from the original beneath the body's own overrides;
the original's resolved marker callback is reserved for mark reuse. Collected
endnotes retain their body defaults until printed, unless the printer explicitly
overrides them.

Independent connections have their own route defaults: straight outside
`deixis-routing`, sharp orthogonal inside it. Configure them with
`connector: (connection: (route: "curve"))` in `deixis-set`, or a local
`connector.route`. A `margin-note`/`inset-note` connector default configures note
shorthand and does not replace that independent default. See [routing policies](document-routing.md).

## Rendering extension points

Use a container for a simple border/background around the built-in output. Use
a single-note renderer to inspect annotation data or replace marker/body layout:

```typst
#let my-renderer(note, ..args) = {
  // note.id, note.data, note.styles, and note.container-args are available.
  deixis-native-render-single(note, ..args.named())
}
#deixis-set(render-single: my-renderer)
```

Renderer callbacks should accept `..args`: adapters can supply `inner-width`,
group `gap`, or aligned marker metrics. Forward named arguments when delegating.
Keep live annotation content in the supplied record. Use
`deixis-generate-body-marker(note)` (or `deixis-generate-body-meta`) for the
single native destination, and `deixis-generate-body-content(note)` for live
start/end locations. See [custom renderers](custom-renderers.md) for the complete
recipe and partial-output behavior. Renderers may be called for measurement;
live content should not be independently executed again inside a callback.

Normal inline bodies use the same shared renderer entry as other adapters and
include the selected `render-single` in their record, including standalone
bodies. No unnecessary geometry arguments are added when there is no width to
constrain. All six configurable function hooks (single/group renderer,
container, body style, marker style, region shape) validate function values after
scope selection and report the parameter name on invalid input.
Ordinary style validation happens when a declaration selects the value; unused
type branches are not eagerly resolved. Palette validation is eager because it
defines a creation policy rather than a component style.

Endnote printer single/group renderer, container, and body-style overrides accept
`auto` or a function and validate before collecting bodies. Its marker-style
override also retains component selection and validates the resolved callback.
Omitting printer overrides preserves the callbacks captured by each body.

The default endnote grid paints cells directly, bypassing single renderers and
containers; choose `deixis-native-render-group` or `deixis-default-render-group`
when those hooks should run. Inline-decoration bodies (`inline: true`) also
retain their native formatting path. Body containers, custom renderer forwarding,
and these bypass rules are described in [containers](containers.md).

## Sidenote presets

`deixis-sidenote` and `deixis-sidenote-body` are margin presets with
`side: "outside"` and `mark-align-strictness: "loose"`. They share margin packing,
counters, styles, body records, and query type. Configure them with
`margin-note: (...)`; there is no separate `sidenote` type. The old unused
`sidenote:` configuration key now produces a migration diagnostic instead of
silently selecting nothing. Type filters continue to use `"margin-note"`.

Preset values behave like native function `.with(...)` defaults: an explicit call
overrides them. The preset's `"loose"` value takes precedence over global alignment
strictness; pass `mark-align-strictness: auto` to inherit settings deliberately:

```typst
#deixis-set(mark-align-strictness: (margin-note: "strict"))
#deixis-sidenote(mark-align-strictness: auto)[Inherit strict alignment.]
```

For a separately styled family, define a small function preset with explicit
options and use annotation data/series when a custom catalogue should distinguish
it. This keeps presentation presets separate from annotation identity and layout
engine types.

For factory appearance and a consistent accent across components, see
[appearance and color](appearance.md) and the
[annotation-colors recipe](../../examples/annotation-colors.typ).

`palette` is a dedicated creation policy: a nonempty color array starts a new
cycle, `none` disables it, and `auto` leaves it unchanged. Unlike style values,
it does not take type/component dictionaries. See [automatic palettes](appearance.md#automatic-palettes)
for scope restoration, forward/reused identities and explicit-style precedence.
