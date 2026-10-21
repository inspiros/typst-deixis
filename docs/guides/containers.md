# Body containers and their options

The body renderer formats markers/content/backlinks. A container wraps that
rendered content. Choose a name with `container-func`:

| Name | Look | Typical Use |
| --- | --- | --- |
| `"plain"` | Unframed content | Footnotes and collected notes |
| `"rect"` | Native rectangle | Framed inset callouts |
| `"alert"` | Doubled left stroke | Inline callouts |
| `"stripe"` | Left accent rule over a light accent tint, square corners | Margin and inset asides, callouts |
| `"tinted"` | Light accent background, small radius and padding | Quiet inset callouts |

Names work in local options and type/component settings:

```typst
#deixis-set(container-func: (margin-note: "stripe", inset-note: "tinted"))
```

The first three names select the existing `deixis-plain-container`,
`deixis-rect-container` and `deixis-alert-container` functions. `"stripe"` and
`"tinted"` are named presets without additional public functions. Their accent
comes from the annotation's palette, then its resolved stroke paint, then the
default accent. The tinted background uses 90% transparency and the stripe tint 94%; gradient strokes
use their midpoint color, while tiling strokes fall back to the default accent. Explicit body
`stroke`, `fill` and `radius` settings win, including `none`; a scalar stripe
stroke paints only the left edge, while an edge dictionary is used literally.
The stripe's default corners are square. Put extra native options such as
`inset` and `outset` in `container-args`:

```typst
#deixis-inset-note(
  container-func: "rect",
  container-args: (inset: 6pt, outset: 2pt),
  stroke: (mark: blue, body: teal),
  width: 120pt,
)[A passage][Its annotation]
```

Container arguments apply only to the body container. They do not participate in
the mark/body/connector style cascade: a custom key named `mark` is just data passed to
your function. The common `stroke`, `fill`, and `radius` options stay on the note,
where component dictionaries select the right node; those keys are rejected
inside `container-args` to avoid two competing style sources.

All five body adapters and the footnote/endnote/margin/inset wrappers accept the
dictionary. `deixis-sidenote` uses the same margin adapter. Options travel with
each body through built-in measurement and live rendering, so container insets
are included in native reservation/placement measurements. The container function
owns validation of its own options; a permissive custom function may deliberately
ignore a key inside that explicit dictionary.
See [the small editable example](../../examples/containers.typ).

Native rectangular edge strokes also work in containers: `stroke: (left: blue +
2pt, rest: none)` draws one border. The alert preset keeps its doubled left bar
for a scalar stroke; an explicit edge dictionary is used as supplied, without
doubling or adding a left edge. Scalar colors also work when calling the alert
container directly. Custom shapes/containers decide which native styles they
support. See [native styles](configuration.md#native-values-and-incremental-updates).

## Group and inline contracts

Native/aligned groups invoke the single-note renderer and container. The default
endnote grid paints cells directly and bypasses per-note containers. Choose a
stacked renderer when the container should appear:

```typst
#deixis-print-endnotes(render-group: deixis-native-render-group)
```

The printer can replace its selected bodies' container options explicitly:

```typst
#deixis-print-endnotes(
  render-group: deixis-native-render-group,
  container-args: (inset: 4pt),
)
```

Omitted/auto printer options preserve each body's dictionary. An explicit
dictionary replaces it, including an empty dictionary to clear the options.
This does not merge unknown native values or reinterpret them as component styles.

`deixis-inline-note-body(inline: true)`, and the `deixis-inline-note` wrapper by
default, use breakable inline decoration,
bypassing a custom single renderer and block container. Nonempty container options on that path are
rejected; use `inline: false` for a container, or use the inline decoration options.
Custom single renderers receive `data.container-args`; if they replace the built-in
renderer, they own forwarding those options to their chosen container.

`deixis-inline-note-body(breakable: false)` wraps the finished renderer in one
native frame, using an inline box or nonbreaking block according to `inline:`.
The frame includes the container and supplies explicit connection ports. The
default keeps the existing flow. See [inline body endpoints](independent-connections.md#connect-to-a-body-in-normal-flow).

## Long Bodies

The `"rect"`, `"alert"`, `"stripe"` and `"tinted"` presets use native `rect`
and are unbreakable. `"plain"` preserves the body's native flow. Long page footnotes and
collected bodies need a breakable container such as `block` with
`container-args: (breakable: true, inset: 5pt)`. Native weak marker spacing folds
source indentation; explicit line/paragraph breaks survive. See
[footnotes and long bodies](footnotes.md) for examples and native clipping limits.

## Migration and diagnostics

Previously arbitrary named note arguments were forwarded to the container.
Typos such as `backlnk: true` could disappear into a plain container. Unknown
note keywords now fail with a diagnostic pointing to `container-args`.

Move custom/native container keys such as `inset`, `outset`, or a callback's
`token` from the note's top level into that dictionary. Existing valid note
options, component styles, and calls with no extra container options are unchanged.
`container-func` remains configurable through `deixis-set`; `container-args` is
an explicit per-body or printer option in this slice.

Functions remain supported for custom containers, with signature
`(body, ..args) => content`. For example, `container-func: block` with
`container-args: (breakable: true, inset: 5pt)` keeps a long body breakable.
Unknown preset names fail with a diagnostic listing the five valid names.

See [configuration and callbacks](configuration.md) for component selection,
incremental native/scoped dictionary updates, and callback arguments.
