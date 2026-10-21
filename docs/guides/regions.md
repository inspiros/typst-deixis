# Regions And Pins

A region encloses content in a rectangle and can share an annotation's identity
with any note body. The simple form wraps its content:

<!-- deixis-example: {"id": "example-1"} -->
```typst
#show: deixis-setup-notes
#deixis-region-mark(inline: true, layer: "foreground", padding: 3pt)[$x^2 + y^2$]
```

Use `inline: true` inside text or table cells. Its inline box keeps the marked
content and its corner pins together when the surrounding text wraps. Bounds
follow the measured content, including math and code. Use the default block form
for tables, diagrams, or paragraphs that need to wrap and paginate. Regions can nest inside each other,
grids, and ordinary Typst containers. See the [small example](../../examples/nested-regions.typ).
The shape and marker preserve common declaration font/paragraph settings,
including custom shape and marker callbacks. Arbitrary surrounding show rules
are not captured.

For a highlight without an outline, use `stroke: none`. Add
`region-shape: deixis-ellipse-region` for an ellipse; `deixis-rect-region` is
the default shape. Both presets use the mark's fill and stroke.

<!-- deixis-example: {"id": "example-2"} -->
```typst
#deixis-region-mark(inline: true, layer: "background", stroke: none, fill: yellow.lighten(70%))[Rectangular highlight]
#deixis-region-mark(inline: true, layer: "background", stroke: none, fill: yellow.lighten(70%),
  region-shape: deixis-ellipse-region)[Elliptical highlight]
```

## Choosing A Layer

- `"foreground"` paints over the page content, including opaque containers.
- `"background"` paints under the content; opaque table/cell/container fills can
  cover the region.
- `"flow"` paints immediately on the declaration page. Its region must fit on
  one page; a multi-page region produces a diagnostic.

Flow regions also work inside measured margin, inset, and footnote bodies.
Detached measurement keeps their native zero-size box or `place`, including its
paragraph effect, while suppressing the position-dependent painter. Live output
still resolves pins and paints at the actual location. This covers anonymous,
registered, and repeated regions, custom single renderers/containers, inline
boxes, and block regions. See the
[small example](../../examples/flow-regions-in-notes.typ).
Inspectable originals inside a note body normally register at its declaration point,
while their geometry follows the painted passage. They share ordinary scoped
numbering and can have a separate body. See
[notes inside notes](../../examples/notes-inside-notes.typ). Preparation discovers
existing declarations without running contextual callbacks. Bodies containing
Deixis settings/counter updates, attachments, or headings retain live ordering.
Headings can generate resets through native show rules; their title/following
marks stay after those updates. See [counter boundaries](counters.md).
Dynamically generated declarations remain subject to Typst's layout-pass limit.

Foreground/background regions can enclose a breakable block over several pages.
Automatic corner pins follow its first and final fragments. Continuation shapes
use each page's content boundaries and omit adjoining top/bottom edges and corner
radii. This is one rectangular span, rather than a highlight of each text line.
Native side/axis/rest stroke dictionaries and side/rest radius shorthands retain
their outer values through those splits. For example, `stroke: (x: blue, y: red)`
keeps blue side edges on every page and red top/bottom edges only on the outer
pages. Explicit corner entries override native side/rest radius defaults.
For content moving between columns on one page, use a region per column and
explicit pins when necessary. Same-page column fragments are not inferred.

## Native Transforms

Foreground/background automatic regions use all four native box corners. A
surrounding `move`, scale, or rotation therefore follows the transformed content;
the region and its connector ports use the axis-aligned envelope of those
corners. The painted rectangle itself stays aligned to the page. Padding remains
in page axes at its declaration size, rather than rotating or scaling with the
content. Explicit pins enclose only the points you provide; two diagonal pins
cannot describe every rotated rectangle's extrema.

For flow regions, put a size-changing transform inside the region and enable
native reflow:

<!-- deixis-example: {"id": "example-3"} -->
```typst
#deixis-region-mark(inline: true, layer: "flow", padding: 3pt)[
  #rotate(20deg, reflow: true, box[Rotated content])
]
```

A surrounding scale/rotation also transforms an immediate painter's local
coordinate system. That combination is not supported. Transforms with
`reflow: false` keep their original layout extent; an outer region can only
enclose that extent. Inline-marker typography remains an approximation under
transforms; use a region mark for content whose exact transformed bounds matter.

## Explicit Pins

Pins select the geometric bounds independently of the region declaration:

<!-- deixis-example: {"id": "example-4"} -->
```typst
#deixis-pin("begin")Important content#deixis-pin("end")
#deixis-region-mark(pins: ("begin", "end"), layer: "foreground")
```

Pin names are document-wide. Each selected name contributes every occurrence;
repeating a name in `pins` does not duplicate the occurrences. Use different
names for independent regions. An explicit `id` connects the region to a body,
just as with an inline mark.

`padding: "text"` uses the declaration's typography. Length/dictionary padding
supports negative values, which shrink the bounds. Relative font lengths such as
`0.2em` resolve where the pin or region is declared. Keep the resulting rectangle's
width and height positive.

## Pins Attached To Containers

`deixis-attach` places named pins relative to a content container:

<!-- deixis-example: {"id": "example-5", "postlude": "#deixis-region-mark(pins: (\"start\", \"end\"), padding: 3pt)"} -->
```typst
#deixis-attach(prefix: none, pins: (
  start: (dx: 0%, dy: 0%),
  end: (dx: 100%, dy: 100%),
))[
  A block of content.
]
```

Missing `dx` or `dy` defaults to zero. A two-item coordinate array is also
accepted. A pin with `dy: 100%`, optionally plus a fixed offset, belongs to the
bottom of the final fragment of a breakable block. Top pins stay in the first
fragment. Other vertical ratios/absolute offsets retain their first-fragment
placement; they do not select a proportional point across the whole paginated
content.

The default attachment prefix scans text/raw content for embedded pin names.
Set `prefix: none` or `prefix: ""` to disable scanning while keeping explicit
coordinate pins. The `padding` parameter controls scanned pins; explicit pins
use their own `padding` field.

String names remain global. Optional producer scopes and structured
`(name:, scope:, select:, page:)` targets isolate reusable components and select
unique/first/last/all occurrences. Regions combine selected bounds; margin and
collection anchors need one occurrence. Prefix/postfix strings are literal; use the
explicit `pattern` option for regex scanning. Geometry metadata fields are
protected. See the [pin guide](pins.md) for padding semantics, alignment/offset
shorthand, scopes, occurrence selection, validation, and migration.

## Reusing An Annotation

`deixis-region-mark(of: id)` creates a new region for an existing annotation.
It needs its own passage or pins and shares the number/body identity and
inherited styling. Forward IDs, private automatic corners, native
overlay transforms, breakable blocks, and all three shape layers follow the
same contracts as original regions. Body placement and implicit connectors stay
with the original. See [shared notes](shared-notes.md) for return destinations
and explicit connection fragment selection.
