#import "../../src/lib.typ": *
#set page(width: 280pt, height: 255pt, margin: 34pt)
#set text(size: 9pt)
// The setup option makes overlays the default for unspecified footnote layers.
#show: deixis-setup-notes.with(override-page-footnotes: true)
// An overlay footnote too tall for the rest of its page migrates like a native
// unbreakable entry: its reference line moves with it. No native entry prefix
// (and therefore no separator) may remain on the previous page.
#lorem(95) Last line note#deixis-footnote(id: <late>)[#lorem(45)] here. #lorem(30)

#pagebreak()
// Configured body gaps do not move bodies away from native reservations.
#deixis-set(gap: 1.5em)
A#deixis-footnote(id: <a>)[First body.] b#deixis-footnote(id: <b>)[Second body that wraps onto another line in this column.] c.

#context {
  let mark = query(<deixis-inline-mark>).find(m => m.value.id == <late>)
  let slot = query(<deixis-reserver-left>).find(p => p.value.id == <late>)
  assert.eq(mark.location().page(), slot.location().page())
  let entries = query(footnote.entry)
  assert(entries.all(e => e.location().page() != 1), message: "A native entry fragment stayed behind.")
  let slots = query(<deixis-reserver-left>).filter(p => p.value.id in (<a>, <b>))
  assert.eq(slots.len(), 2)
  let (first, second) = slots
  assert(second.location().position().y > first.location().position().y + first.value.reserved-height)
}
