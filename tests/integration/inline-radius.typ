#import "../../src/lib.typ": *
#set page(width: 540pt, height: 390pt, margin: 35pt)
#set text(size: 12pt)
#show: deixis-setup-notes
#let live = state("inline-radius-passages", 0)
// Inspect the actual native cap options after the painter has selected its side.
#show box: it => {
  if (it.has("radius") and type(it.radius) == dictionary and it.radius.len() >= 2
    and it.has("stroke") and type(it.stroke) == dictionary
    and (it.stroke.at("rest", default: none) != none or it.stroke.at("left", default: none) != none
      or it.stroke.at("right", default: none) != none)) {
    [#metadata(it.radius)<inline-cap-radius>]
  }
  it
}
#let corners = (top-left: 2pt, top-right: 4pt, bottom-left: 6pt, bottom-right: 8pt)
#for (i, mode) in ("box", "parentheses", "highlight", "underline", "text-fill", "none").enumerate() {
  if i > 0 { pagebreak() }
  [Mode: #mode.]
  for (j, radius) in ((:), corners, (left: 3pt, right: 7pt)).enumerate() {
    let id = mode + str(j)
    par[
      Forward #deixis-mark(of: id, radius: radius)[#live.update(n => n + 1)Repeated passage].
      Original #deixis-mark(id: id, inline-mode: mode, radius: radius)[#live.update(n => n + 1)Original passage].
    ]
  }
}
#context {
  assert.eq(live.final(), 36)
  let caps = query(<inline-cap-radius>).map(m => m.value)
  assert.eq(caps.len(), 24)
  let actual = caps.map(radius => ("top-left", "top-right", "bottom-left", "bottom-right").map(key => {
    let value = radius.at(key, default: 0pt)
    if type(value) == relative { assert.eq(value.ratio, 0%); value.length } else { value }
  }))
  for (radius, count) in (
    ((0pt, 0pt, 0pt, 0pt), 8),
    ((2pt, 0pt, 6pt, 0pt), 4), ((0pt, 4pt, 0pt, 8pt), 4),
    ((3pt, 0pt, 3pt, 0pt), 4), ((0pt, 7pt, 0pt, 7pt), 4),
  ) { assert.eq(actual.filter(value => value == radius).len(), count) }
}
