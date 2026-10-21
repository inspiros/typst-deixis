# What A Body Declaration Controls

A mark owns the annotation's number and logical identity. A body owns its content,
formatting, and placement policy. Its declaration captures body settings and
typography; the declaration's physical location matters differently for each
adapter. A connection owns how two prepared endpoints are joined.

Use `id:` to create a named annotation and `of:` to attach a body to an original
mark. A body-only `id:` creates a standalone body, while a wrapper `id:` creates
both the original mark and its body. The public ID is also the body's native
Typst destination. See [annotation identities](identities.md).

An attached body or wrapper inherits the original's exact rendering scope and
block instance by default, even with forward declarations or threaded blocks.
Its explicit `target:` can override that rendering scope; the original keeps
its counter owner, number, and series. Use `target: 0` for the calling scope.
This scope selection does not replace the adapter's page/position policy below.
Set `series:` and mark geometry on the original; attached calls reject settings
that would otherwise be silently ignored. Body styling and placement remain
local to the attachment. Standalone bodies can choose their collection series.

For multi-page local scopes, see [breakable blocks](blocks.md): margins use
per-page inset frames, whereas footnotes collect at the whole block's end.

Ignoring blocks/minipages, the current rules are:

| Body | What determines its page and position? | Does moving the body declaration matter? |
| --- | --- | --- |
| Margin, foreground/background body | Original mark or `anchor-pin` supplies the initial page/anchor; margin policy aligns/packs it and may spill to existing later pages | Normally no geometric effect for an attached body; declaration settings/typography and ordering still matter. An unanchored standalone body falls back to its declaration |
| Margin, flow body | Immediate placement on the declaration page, using a mark/pin on that page; otherwise the declaration position is the fallback | Yes: it cannot move to the original mark's other page and has no collision packing |
| Page footnote, all body layers | Native footer allocation at the body declaration; a long flow footnote can continue across pages | Yes: the body declaration reserves the footer slot, even if the original mark is elsewhere |
| Inset, foreground/background body | Declaration selects the page by default; `anchor-pin` can select another page. A mark/pin plus offsets/anchor, or a placement callback, selects the position | Yes for page selection; its in-text position need not be the positioning anchor |
| Inset, flow body | Immediate rendering on the declaration page; without placement/offset/pin options it occupies native flow at the call | Yes, even when coordinates are derived from a mark |
| Inline body | Native flow at the body call; the `deixis-inline-note` wrapper places it right after its passage | Yes |
| Endnote body | An eligible `deixis-print-endnotes` call owns the actual output | Declaration controls content/settings and collection eligibility/order, while the printer controls where it appears |

For example, place marks on page 1 and most bodies on page 2: the overlay margin stays on
page 1, the immediate margin/footnote/inline/inset bodies appear on page 2, and
the endnote prints on page 3. Bodies are painted exactly once.

An inline body with `breakable: false` stays in one native inline/block frame at
its declaration. Explicit connections can target that frame without changing
its placement. The frame may move as a unit to fit native flow; it does not
follow the original mark to another page.

Explicit start/end point targets follow the live body wherever its adapter
prints it, including a collected body's final continuation page. They do not
change printer ownership, footnote reservation, or body placement. A connection
to an unprinted collection is an error, not a request to print it.

## Layers And Placement Are Separate Decisions

`layer: "flow"` currently chooses immediate/native behavior for a body. Overlay
body layers allow document-wide geometry lookup. This is a rendering-path choice
as well as a paint choice; changing it can therefore change placement behavior.

Connections now always use a page overlay. For both margin and inset notes,
`connector.layer: auto` or an omitted layer means `"foreground"`; an explicit
`"background"` paints behind page content. Neither follows the body's layer.
Both support cross-page routing. There is no connector `"flow"` layer, since a
connection must be able to resolve its endpoints elsewhere in the document.
See [connectors](connectors.md#connection-layer).

## Placement And Connection Sources

A body declaration is not universally a positioning command, and a mark does not
universally select the body's page. Keep a native footnote body declaration on
the page where it should reserve footer space. Use a margin body when the
explanation should follow a distant mark.

`deixis-connect` can select a repeated occurrence as its source without moving
the body. Scopes control rendering ownership, counters and available placement
frames; connection endpoints control only the drawn edge.
