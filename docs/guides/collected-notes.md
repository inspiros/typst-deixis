# Collected Layouts And Pagination

Endnotes are declared with the text and printed later. The default collection
uses a grid with aligned markers:

<!-- deixis-example: {"id": "collected-explanation", "setup": false} -->
```typst
#show: deixis-setup-notes
Text#deixis-endnote[A collected explanation.]
#deixis-print-endnotes()
```

See [the small styled example](../../examples/collected-styles.typ). Endnotes
preserve the declaration's common font and paragraph settings, as margin and
inset bodies do; page footnotes follow the native footer instead. A printer's `body-style` or `marker-style` can override
those settings inside the renderer. Arbitrary surrounding show rules are not
captured.

## Choosing A Group Renderer

| Renderer | Behavior |
| --- | --- |
| `deixis-grid-render-group` | One marker/body grid; default endnote layout |
| `deixis-aligned-render-group` | Stacked single renderers with a shared marker width |
| `deixis-native-render-group` | Stacked single renderers with independent marker widths |
| Custom function | Receives the selected note records and the `gap` argument |

The grid paints cells directly for the default aligned single renderer. If any
note in a series uses another single renderer, the grid stacks the whole series
with `deixis-native-render-group`, preserving each renderer and the configured
`gap`. For a custom container with the default single renderer, select a stacked
renderer:

<!-- deixis-example: {"id": "stacked-group", "prelude": "Text#deixis-endnote[A collected explanation.]"} -->
```typst
#deixis-print-endnotes(render-group: deixis-native-render-group)
```

An explicit printer `render-single` therefore works with the default group.
A `container-func` alone does not replace the default grid.

Groups preserve the first-seen series order and source order within each series.
With `render-group: auto`, the first note in **each series** supplies that series'
group renderer. An explicit printer renderer applies to all its series. Within
one series, choose a common group policy or collect separate subsets explicitly.
A custom group function can delegate to a built-in renderer after modifying the
records, or use native layout such as columns.

## Chicago Endnotes

Use the Chicago single renderer with the ordinary printer:

<!-- deixis-example: {"id": "chicago-endnotes", "prelude": "Text#deixis-endnote[A collected explanation that continues beyond a short first line to show the hanging paragraph layout.]"} -->
```typst
#deixis-print-endnotes(render-single: deixis-chicago-render-single)
```

To select it throughout the document, configure endnotes before declaring them:

```typst fragment
#deixis-set(render-single: (endnote: deixis-chicago-render-single))
```

Each note starts with a first-line indent of `0.5in`, a full-size linked marker
and a period. Continuation lines return to the margin. An explicit `indent` setting or printer override
replaces the default; unnumbered notes have no marker or period. The renderer
preserves the declaration's paragraph settings, including leading and spacing,
and retains configured backlinks, body styling and containers. Set the document's
own paragraph leading for single-spaced notes; the renderer does not force a
line height. The printer's `gap` controls space between notes, and its separator
and clearance options continue to apply. HTML export uses the semantic note
list without Chicago paragraph indentation; see [output formats](compatibility.md#output-formats).

See [the Chicago endnotes example](../../examples/chicago-endnotes.typ) for a
short humanities text with Chicago-style citations. Citation wording and
bibliographic details remain ordinary note content.

## Spacing

With `gap: auto`, each incoming note supplies its own gap. Relative font lengths
such as `2em` resolve in that note's declaration typography; all three built-in
group renderers follow this rule. An explicit printer/group gap applies uniformly
and resolves in the printer's context.

The first note still supplies the separator and default collection clearance.
The default clearance resolves in that note's declaration context. An explicit
printer clearance overrides it. A separator is emitted once for the collection;
series retain the smaller existing inter-series clearance.

## Long Bodies

Native, aligned, and grid endnotes can continue across pages. A custom group can
also use native columns and pagination. The first eligible printer owns a body;
repeated or overlapping collections do not print it again. Native continuation
headers can use `deixis-query-notes(page: here().page(), include-types: "endnote")` to find active bodies.
It preserves native body order, including continuations and reset numbering.
See [selection and queries](queries.md) for body-declaration versus original-mark
bounds, rendering-scope filters, and first-printer ownership with forward bounds.

Block footnotes use collected native flow. Page footnotes with `layer: "flow"`
use native footnote pagination. Foreground/background page footnotes reserve
individual numeric slots; a compatible group can paint inside that reservation.
A custom overlay group must keep dimensions consistent with those slots. For
arbitrary reflow or long splittable bodies, use native flow or endnotes.

## Connections To Printed Bodies

Explicit connections can select `(body: <note>, point: "start")` or `"end"`.
The start uses the native location before live content; the end follows the
final printed page. All built-in group renderers and native page/block footnotes
retain pagination and print-once ownership. No framing flag or extra reservation
is needed. The body must actually be printed, with one complete live span and
destination. These are content points, not continuation rectangles or glyph
bounds. See [body point connections](independent-connections.md#connect-to-a-collected-or-paginated-body)
and the [small example](../../examples/collected-connections.typ).

## Pages With An Automatic Dimension

Page frames record the final numeric width/height, including `height: auto` and
`width: auto`. Placement, margin packing, region continuation bounds, and
page-relative connector waypoints use those physical dimensions. Native page
footnote reservation can increase an intrinsic page's height.

Overlays do not enlarge an intrinsic page. Keep its note bodies within the
native content extent, add ordinary content/space, or choose a fixed page height.
This is the same overlay ownership rule used for fixed pages.

Automatic margins follow Typst's shorter finite configured page axis. Percentage
margins on an automatic axis resolve against zero; a relative value such as
`10% + 12pt` therefore contributes `12pt` on that axis. These are native layout
rules, separate from the page's final measured size.
