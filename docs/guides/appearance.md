# Annotation Appearance

Examples use the [standard import and setup](getting-started.md#1-start-with-native-footnotes).
Excerpts with existing IDs or callback variables extend the surrounding example.

Factory marks and decorated bodies use a muted blue-gray accent (`#496579`),
0.5pt borders and lightly tinted mark backgrounds. Passage and body text keep
the document's text color. Margin bodies are plain by default; inset bodies use
a rectangular container. Connectors remain opt-in. Marker-to-body spacing is
0.25em for margin/inset/inline notes, 0.05em for native-style footnotes, and
0.75em for collected endnotes.

Use ordinary configuration for another accent:

```typst
#let accent = rgb("387C69")
#deixis-set(
  stroke: 0.5pt + accent,
  fill: (inline-mark: accent.transparentize(94%),
         region-mark: accent.transparentize(94%), rest: none),
)
```

`stroke`, `fill` and `marker-style` can be set separately per component/type or
on one note. A plain margin container does not paint a border even when a
stroke is configured; choose a container if a body rule/border is wanted.
See [configuration](configuration.md), [native styles](../../examples/native-styles.typ)
and [containers](containers.md).

For automatic sequences, use the palette setting below. The earlier
[Annotation Colors recipe](../../examples/annotation-colors.typ) remains useful
when you want to choose the index and style each component explicitly.

The [default specimen](../../examples/default-appearance.typ) shows all current
factory adapters. To reproduce the earlier red appearance:

```typst
#deixis-set(
  stroke: red + 0.5pt,
  fill: (inline-mark: red.transparentize(95%),
         region-mark: red.transparentize(95%), rest: none),
  marker-gap: (endnote: 0.75em, rest: 0.05em),
)
```

Changing marker gaps may change wrapping and packed body heights. Explicit
settings and custom renderer/container choices keep their existing precedence.

## Marker Alignment And Padding

Factory body markers use compact superscripts, except the plain endnote body
marker. The aligned overlay footnote group shares marker-column width across its
notes, so longer numerals do not shift the neighboring body text independently.
Margin/inset body text defaults to 0.85em; page footnotes use the native footer
size, which is the same 0.85em of the document text. Inline bodies and endnotes
inherit the surrounding size. A custom `body-style` replaces that default style.

Plain margin/footnote containers add no padding. Rectangular/alert containers
use a 5pt inset unless customized. To make a callout's padding scale with slide
text, set it explicitly:

```typst
#deixis-inset-note(width: 130pt,
  container-args: (inset: 0.5em),
)[A passage][An explanation with proportional padding.]
```

Built-in marker wrappers align to the body's cap height. Ordinary superscript
and plain text markers work within that convention; a very tall custom marker
can extend outside it. Use a custom single-note renderer when oversized symbols
or multiline labels need their own reserved space. See
[containers](containers.md) and [custom renderers](custom-renderers.md).

## Automatic Palettes

```typst
#deixis-set(palette: "okabe-ito")
#deixis-margin-note[First passage][First explanation.]
#deixis-margin-note[Second passage][Second explanation.]
```

A palette name or a nonempty array of colors starts a fresh cycle in the current
Deixis scope. The built-in names resolve to these colors, in order:

| Name | Intended Use | Hex Values |
| --- | --- | --- |
| `okabe-ito` | Colorblind-safe categorical accents; omits yellow and black | `E69F00`, `56B4E9`, `009E73`, `0072B2`, `D55E00`, `CC79A7` |
| `tol-bright` | Paul Tol's bright colorblind-safe accents; omits grey | `4477AA`, `EE6677`, `228833`, `CCBB44`, `66CCEE`, `AA3377` |
| `tol-muted` | Paul Tol's muted colorblind-safe accents; omits pale grey | `CC6677`, `332288`, `DDCC77`, `117733`, `88CCEE`, `882255`, `44AA99`, `999933`, `AA4499` |
| `tableau` | Familiar categorical colors from matplotlib's `tab10` | `1F77B4`, `FF7F0E`, `2CA02C`, `D62728`, `9467BD`, `8C564B`, `E377C2`, `7F7F7F`, `BCBD22`, `17BECF` |
| `deixis` | Muted house accents; each has at least 3:1 contrast against white | `3B6D9A`, `387C69`, `9A663F`, `7D5A87`, `397D86`, `A05268`, `73783E` |

To copy or extend a set, wrap its hex values in `rgb` and pass an array:

```typst
#deixis-set(palette: (rgb("3B6D9A"), rgb("387C69"), rgb("9A663F")))
```

Typst's `color.map.*` gradients are poorly suited to categorical annotations:
neighboring samples can become nearly identical. These palettes use discrete
colors, although the lighter published colors can still be faint as thin strokes
or pale tints.

`palette: none` disables it for later originals; `auto` leaves the current
setting unchanged. Names and equivalent arrays behave identically. A new explicit
name or array restarts even if it equals the previous setting. Inside
`deixis-block`, inherited palettes share the outer cycle; a local
palette starts its own cycle, and leaving the block restores the outer cycle
at its saved position. These are Deixis configuration scopes, not ordinary Typst
content brackets. Numbering resets and page breaks do not restart a palette.
No palette is enabled by default.

Each original annotation takes one accent in semantic declaration order. Its
marks, default marker numerals, body decoration and shorthand connector reuse
that color. Reused marks, references, attached bodies and additional explicit
connections do not take another slot. Forward attachments inherit the original's
accent even if their own declaration sees another palette. An anonymous one-call
note needs no public ID. Standalone bodies and unpaired visual marks also take
one color each; a phantom without an identity draws nothing and takes no slot.
Hidden originals retain their slot.

The palette supplies only missing factory appearance. Explicit note options,
scoped/global `stroke`, `fill` and `marker-style`, including `none`, still win.
Reading text keeps its inherited color; body fills remain absent by default.
A plain margin body shows the accent through its marker, not a new border.
Footnote/endnote markers can carry the accent; their reading text and separators
keep their ordinary styling.

A default explicit connection prefers its destination annotation's accent,
then its source annotation's accent when the destination has none. Edges between
ordinary pins/attached nodes keep their configured stroke and consume no color.
Explicit edge strokes, heads and continuation styles remain authoritative.

Anonymous decorations and anonymous bodies **inside another note body** inherit
the containing annotation's accent without advancing the outer cycle. A named
original or standalone body there remains a separate annotation, in its existing
semantic registration order. Palettes do not pre-evaluate arbitrary contextual
content to assign an index from the raw source tree. Custom body
renderers preserve this behavior through `deixis-generate-body-content(data)`,
which also preserves live body spans; directly replaying raw content owns its
own effects. Native measurement and repeated layout do not consume extra slots.
Existing finite-pass limits for deeply deferred content still apply.

`deixis-query-notes` and body-renderer records expose `accent` (a color or `none`)
for custom catalogues, swatches and renderers. Connector paint records expose it
as `request.route.document.accent`. A plain reference inherits its original's
marker style; an explicit reference marker style overrides that formatting.
Mixed accent styles retain the existing mixed-style reference ordering.

For Touying, put a palette setting in the authored slide content/callback when
you want each subslide to restart with the same sequence. Keep hidden annotation
creation in that sequence; conditionally removing a declaration also removes its
slot. A single setting outside the presentation continues one stream through
its native annotation declarations. Existing frame-ID/reveal ownership applies.

See [Automatic Annotation Colors](../../examples/automatic-palette.typ) for a
small example with wraparound, reuse, a new palette and a forward body.
