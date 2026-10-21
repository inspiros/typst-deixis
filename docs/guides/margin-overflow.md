# Checking margin overflow

Examples use the [standard import and setup](getting-started.md#1-start-with-native-footnotes).
Excerpts with existing IDs or callback variables extend the surrounding example.

Margin bodies can now check their final placement against their assigned frame:

```typst
#deixis-margin-note(overflow: "error")[An explanation.]
```

Use `#deixis-set(overflow: "error")` to enable this throughout a scope. The
default, `"allow"`, preserves existing placement, including intentional overflow.
A local `overflow: "allow"` overrides a strict inherited setting. The same option
works on `deixis-margin-note-body` and the sidenote presets; component/type
settings follow the normal body configuration cascade.

See the small [two-page example](../../examples/margin-overflow.typ).

## What is checked

The check uses the accepted logical body rectangle after the built-in layout has
chosen its side, offsets, packing, and spillover frame. A rejected provisional
placement on an earlier page is not an error. Both the horizontal margin width
and the vertical frame bounds are checked, with a 0.1pt tolerance for rounding.
The diagnostic identifies the note and physical page and reports horizontal and
vertical excess.

This works for foreground/background margin bodies and immediate `layer: "flow"`
bodies. A flow body still stays on its declaration page, without packing or
spillover. Strict overflow detects an out-of-frame body; it does not detect two
bodies overlapping inside that frame. Hidden overlay notes do not claim a frame
or produce an overflow error.

For scoped notes the assigned frame is the scope's recorded margin frame. That
frame does not promise clearance from native page footers or arbitrary page
objects. Glyph ink, shadows, connector heads, and painting beyond a custom
renderer's logical box are outside the check.

## What happens on overflow

`"error"` stops compilation when the final rectangle exceeds its frame. Shorten
the body, adjust its width/offset, or provide another eligible frame for overlay
spillover. The check does not create pages, clip content, shrink text, or reroute
connectors. An overlarge first body or a terminal spillover body can still be
accepted by the placement engine; strict mode then diagnoses that final overflow.

A custom margin-layout callback owns its output geometry. It supports
`overflow: "allow"`; strict mode receives a diagnostic because the built-in
planner cannot verify that callback's final rectangles. Direct layout helpers
without `deixis-setup-notes` do not run the document's final validation pass.

The two policies keep the API compact. There is no package warning mode or
silent fallback from strict checking to a different placement algorithm.
