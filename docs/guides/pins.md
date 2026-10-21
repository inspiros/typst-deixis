# Pins, Coordinates, And Padding

A pin is a named point with optional geometric padding. Use it to define region
bounds or anchor a note. Simple names are document-wide strings or label values; repeated names
produce several occurrences. Add `scope:` when a component needs its own pins.

Pins also supply [connection endpoints](independent-connections.md#connect-pins-without-creating-notes),
exact [waypoints and custom ports](connectors.md#pins-as-custom-ports). These use
the recorded point, without region padding, and require one selected occurrence.

<!-- deixis-example: {"id": "example-1"} -->
```typst
#deixis-pin("start", padding: 0pt)Marked text#deixis-pin("end", padding: 0pt)
#deixis-region-mark(pins: ("start", "end"), padding: 3pt)
```

The [small editable example](../../examples/pins.typ) attaches corners to a box.
For exact math/image/content bounds, prefer an automatic `deixis-region-mark`
wrapper. Bare inline points sit on the text baseline and do not measure glyphs.

To register an entire object for [document routing](document-routing.md), add
`id:` or explicit `behavior:` to `deixis-attach`. It captures one nonbreaking
native frame, while the existing `pins:` still provides custom sockets. Pin
padding/scanning behavior is unchanged.

Attachment IDs, pin names and note IDs are independent namespaces; the same
spelling may coexist in all three. Attachment `scope:` does not change note
identity. See [identity selection and wrapped notes](identities.md#note-attachment-and-pin-names).

## Reusable Components And Private Pins

`deixis-pin` and `deixis-attach` accept an optional `scope:`. A scope can be a
nonempty string or native label for deliberate sharing, or a native location for
a private instance. A string and label with the same spelling name the same
scope. Omitted/`none` means the global namespace.

Pin names also accept both spellings: `deixis-pin(<anchor>, scope: <diagram>)`
matches `(name: "anchor", scope: "diagram")`, and conversely. Names normalize
to strings internally. A label-valued pin name does not publish a native Typst
label or an annotation reference destination.

Use `here()` once inside a component's `context` to give each invocation a
different scope. Select those pins with ordinary dictionary values:

<!-- deixis-example: {"id": "example-2"} -->
```typst
#let card(body) = context {
  let local = here()
  let pin(name) = (name: name, scope: local)
  deixis-attach(scope: local, prefix: none, pins: (
    begin: (anchor: top + left),
    end: (anchor: bottom + right),
  ))[#body]
  deixis-region-mark(pins: (pin("begin"), pin("end")))
}
#card[First instance]
#card[Second instance]
```

The two highlights use separate `begin` and `end` pins. No extra public helper
is needed; store the target dictionaries when an outside consumer needs access.
The [scoped-pins example](../../examples/scoped-pins.typ) is a small demonstration.

An attachment's scope applies to its scanned and coordinate pins. A direct pin
uses `deixis-pin("anchor", scope: local)`. This is explicit pin isolation: it does
not change annotation IDs, counters, or note scopes, and it does not implicitly
scope independent pin calls or nested attachments in the body.

## Select Occurrences Consistently

Every pin consumer accepts a structured target:

```typst fragment
(name: "anchor", scope: "diagram", select: "last", page: 2)
```

Only `name` is required. `scope` defaults to the global namespace and `page` to
all pages. `page` is a positive physical page number, independent of displayed
page numbering. Page restrictions apply **before** occurrence selection.

| `select` | Meaning |
| --- | --- |
| `"unique"` (record default) | Require exactly one matching occurrence |
| `"first"` | First match in document query order |
| `"last"` | Last match in document query order |
| `"all"` | All matching occurrences |

Structured targets report missing matches, including wrong scopes/pages.
`"unique"` also reports ambiguity. Overlapping region selections do not duplicate
the same physical pin. Targets may precede their pin declarations.

Consumers retain their placement roles:

| Consumer | Selection and placement |
| --- | --- |
| Region `pins: (...)` | Combines selected bounds; `"all"` may span pages |
| Margin `anchor-pin:` | Needs one selected occurrence. Overlay placement follows it; flow first restricts lookup to the declaration page |
| Inset `anchor-pin:` | Combines selected bounds. Overlays use the first selected pin's page; flow restricts lookup to its declaration page |
| `deixis-place-anchored(pin: ...)` | Combines selected bounds and places on the call's page |
| Endnote/outline `after:` and `before:` | Needs one selected occurrence as a source-order boundary |

Insets and anchored placement accept one target or an array of targets. With an
array, the first target with matches supplies the first selected pin. Region
pins always use an array. Margin and collection boundaries reject `"all"` when
it selects multiple occurrences; choose first/last/unique for a single anchor.
An explicit `page:` intersects a flow consumer's declaration page; it cannot
move native flow output to another page.

Simple **string/label** targets use the existing defaults: regions and anchored placement
combine all matches, margins and collection boundaries use the first, and
insets use combined bounds with the first match selecting their overlay page.
Missing strings keep their previous fallback/empty behavior, except collection
boundaries, which require a match. Flow inset lookup now consistently uses local
matches, as flow margins do. Use a record when a missing or ambiguous pin should
be diagnosed.

Collection boundaries retain their native-label shorthand: `after: <anchor>`
selects a native Typst label. To select a pin by label-valued name, use
`after: (name: <anchor>)`, optionally with scope/selection/page fields.

## Padding Is Geometry

Pin padding is preserved. It expands the point used by a region, without adding
space or moving content. A pin at `(x, y)` contributes these bounds:

| Edge | Coordinate |
| --- | --- |
| Left | `x - padding.left` |
| Right | `x + padding.right` |
| Top | `y - padding.top` |
| Bottom | `y + padding.bottom` |

A region takes the extrema of its selected pins and then adds its own padding.
Positive padding expands; negative padding shrinks the relevant bounds. Keep the
final rectangle's width/height positive. Pin padding is not an invisible object
for collision avoidance, and it is not a movement offset.

- `0pt`, `none`, or `auto` means an exact point with zero padding.
- A signed length such as `-2pt` or `0.2em` applies to all four edges.
- An edge dictionary accepts `left`, `right`, `top`, `bottom`, `x`, `y`, and `rest`.
  Specific edges override axis values, which override `rest`. An edge's `none`
  explicitly means zero; `auto` inherits that edge's fallback. An empty dictionary
  means zero on every edge.
- `"text"`, the default for direct/scanned pins, is the existing baseline preset:
  top `0.9em`, bottom `0.2em`, horizontal `0.1em`. It remains an approximation,
  especially for tall equations, descenders, or mixed fonts.

Lengths resolve in the declaration's typography. Percentages are rejected: a
point has no width/height to supply their basis. Use percentage coordinates on
an attached container instead. Transformed overlay padding remains in page axes,
as explained in [regions](regions.md#native-transforms).

## Attach Points To A Container

<!-- deixis-example: {"id": "example-4"} -->
```typst
#deixis-attach(prefix: none, pins: (
  corner: (anchor: top + right, offset: (2pt, -1pt)),
  center: (anchor: center),
))[
  #rect(width: 100pt, height: 50pt)[Content]
]
```

Native alignments locate a point in the box. `offset` is an optional two-item
coordinate pair. Positive x goes right; positive y goes down. Percentages in
offsets use the container's dimensions. Existing `(dx: ..., dy: ...)` records
and two-item coordinate pairs still work; omitted coordinates are zero. Choose
anchor/offset or dx/dy in a record, rather than mixing the two representations.
Attached pins default to zero padding, independently of scanned pins.
Dictionary keys are strings; a coordinate pair array can use labels, for example
`pins: ((<corner>, (anchor: top + left)),)`. Text scanning and `pin-padding`
dictionary keys remain strings, matching the normalized pin names.

A bottom attachment follows the last native fragment of a breakable block;
an offset such as `(0pt, -3pt)` stays relative to that bottom. Intermediate
vertical ratios retain the first-fragment behavior. The coordinate form does
not infer proportional positions across a whole paginated body or columns on
one page.

## Scan Text And Raw Code

Delimiter strings are now literal, so punctuation is safe:

<!-- deixis-example: {"id": "example-5", "postlude": "#deixis-region-mark(pins: (\"begin\", \"end\"))"} -->
```typst
#deixis-attach(prefix: "[", postfix: "]", padding: 0pt)[
  #text("[begin]Marked text[end]")
]
```

The default opening delimiter is `deixispin`, with no closing delimiter. Names
captured by delimiter scanning contain ASCII letters, digits, `_`, and `-`.
Set `prefix:`/`postfix:` per call, or bind a reusable preset with
`#let attach = deixis-attach.with(prefix: "[", postfix: "]")`.
`prefix: none`/`""` disables delimiter scanning; coordinate pins still work.

For intentional regex scanning, use `pattern` with exactly one capture for the
pin name. Use noncapturing groups for other grouping. The capture must be nonempty
when it matches; custom regex captures can include Unicode names.

<!-- deixis-example: {"id": "example-6", "postlude": "#deixis-region-mark(pins: (\"begin\", \"end\"))"} -->
```typst
#deixis-attach(pattern: regex("@([a-z]+)!"), padding: 0pt)[
  #text("@begin!Text@end!")
]
```

`pattern` overrides delimiter scanning; `pattern: none` disables all scanning.
The attachment's `padding` applies to scanned pins only. Each explicit coordinate
pin carries its own `padding` field.

Use `pin-padding` for per-name overrides and `padding` for the uniform default:

<!-- deixis-example: {"id": "example-7", "postlude": "#deixis-region-mark(pins: (\"left\", \"rest\", \"end\"))"} -->
```typst
#deixis-attach(prefix: "[", postfix: "]", padding: 2pt,
  pin-padding: (left: 5pt, rest: none),
)[#text("[left]Text[rest]More text[end]")]
```

Names are literal keys here: `left` is the pin named left and `rest` is the pin
named rest. Neither is an edge or wildcard. Unlisted names use the uniform
`padding`; in this example end gets 2pt. Overrides replace the selected pin's
padding value, rather than merging its edges with the uniform default. Coordinate
pins are unaffected. Legacy unambiguous per-name maps in `padding` remain accepted,
but cannot be combined with `pin-padding`; migrate them to the explicit spelling.

## Custom Metadata And Migration

`extra-data` accepts custom fields such as `(role: "diagram-input")`. `name`,
`scope`, `padding`, `dx`, `dy`, `type`, and `hidden` belong to the pin engine and cannot be replaced.
Input mistakes now produce Deixis diagnostics instead of silently changing
geometry or failing later in native placement.

In the old API, string delimiters were injected into a regex. Plain alphanumeric
delimiters keep their behavior. Migrate intentional regex delimiters to an
explicit `pattern` capturing the name. Remove accidental overrides of reserved
metadata fields, misspelled coordinate/edge keys, and percentage padding.
Valid signed-length padding and existing coordinate forms are preserved. Move a
legacy custom `extra-data.scope` to a different custom key; use the explicit
`scope:` argument to namespace the pin itself.
