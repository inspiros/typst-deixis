#import "../../src/lib.typ": *
#set page(width: 560pt, height: 430pt, margin: 35pt)
#set text(fill: green)
#show: deixis-setup-notes
#let edge = (top: blue + 2pt, bottom: red + 3pt, left: orange + 4pt, right: purple + 5pt)
#let live = state("native-inline-passages", 0)
#show box: it => {
  if it.has("height") and it.height == 0pt and it.has("stroke") and type(it.stroke) == dictionary {
    if it.stroke.at("left", default: none) == none and it.stroke.at("right", default: none) == none {
      [#metadata(it.stroke)<inline-edge-cell>]
    } else {
      [#metadata(it.stroke)<inline-edge-cap>]
    }
  }
  it
}
#show underline: it => [#metadata(it.stroke)<inline-edge-line>#it]
#for mode in ("box", "parentheses", "underline", "highlight", "none") {
  par[
    #deixis-mark(of: mode, stroke: edge)[#live.update(n => n + 1)Reused passage]
    #deixis-mark(id: mode, stroke: edge, inline-mode: mode)[#live.update(n => n + 1)Original passage]
  ]
}
#deixis-mark(of: <plain>, stroke: none)[#live.update(n => n + 1)Uncolored repeat]
#deixis-mark(id: <plain>, stroke: none, inline-mode: "text-fill")[
  #context assert.eq(text.fill, green)
  #live.update(n => n + 1)Uncolored original
]
#deixis-mark(of: <thickness>)[#live.update(n => n + 1)Colorless repeat]
#deixis-mark(id: <thickness>, stroke: 1pt, inline-mode: "text-fill")[
  #context assert.eq(text.fill, green)
  #live.update(n => n + 1)Colorless stroke
]
#context {
  assert.eq(live.final(), 14)
  let caps = query(<inline-edge-cap>).map(m => m.value)
  assert.eq(caps.len(), 8)
  assert.eq(caps.filter(s => s.left == none).len(), 4)
  assert.eq(caps.filter(s => s.right == none).len(), 4)
  for s in caps {
    assert.eq(s.top.thickness, 2pt)
    assert.eq(s.bottom.thickness, 3pt)
    if s.left != none { assert.eq(s.left.thickness, 4pt) }
    if s.right != none { assert.eq(s.right.thickness, 5pt) }
  }
  let cells = query(<inline-edge-cell>).map(m => m.value)
  assert.eq(cells.len(), 8)
  assert.eq(cells.filter(s => s.top != none).len(), 2)
  assert.eq(cells.filter(s => s.bottom != none).len(), 4)
  for s in cells {
    if s.top != none { assert.eq(s.top.thickness, 2pt) }
    if s.bottom != none { assert.eq(s.bottom.thickness, 3pt) }
  }
  let lines = query(<inline-edge-line>).map(m => m.value)
  assert.eq(lines.len(), 6)
  assert.eq(lines.filter(s => s.thickness == 2pt).len(), 2)
  assert.eq(lines.filter(s => s.thickness == 3pt).len(), 4)
}
