#import "../../src/lib.typ": *
#set page(width: 360pt, height: 320pt, margin: 30pt)
#show: deixis-setup-notes

= Minipage Internal Margin

// Preserve the 0.1.1 wrapper contract: margin is internal padding, not outset.
#let padding = (left: 12pt, right: 18pt, top: 8pt, bottom: 10pt)
#deixis-attach(prefix: none, pins: (
  minipage-tl: (anchor: top + left), minipage-br: (anchor: bottom + right),
))[
  #deixis-minipage(width: 150pt, height: 70pt, margin: padding,
    fill: blue.lighten(85%), above: 0pt, below: 0pt,
  )[
    #place(top + left)[#metadata(none)<minipage-content>]
    Padded minipage.
  ]
]
#v(12pt)
#deixis-attach(prefix: none, pins: (
  block-tl: (anchor: top + left), block-br: (anchor: bottom + right),
))[
  #deixis-block(width: 150pt, height: 70pt, inset: padding, outset: 0pt,
    fill: green.lighten(85%), above: 0pt, below: 0pt,
  )[
    #place(top + left)[#metadata(none)<block-content>]
    Equivalent block.
  ]
]

#context {
  let pins = query(<deixis-pin>)
  let pos(name) = pins.find(p => p.value.name == name).location().position()
  let content(lbl) = query(lbl).first().location().position()
  let mt = pos("minipage-tl")
  let mb = pos("minipage-br")
  let bt = pos("block-tl")
  let bb = pos("block-br")
  assert.eq(mb.x - mt.x, 150pt)
  assert.eq(mb.y - mt.y, 70pt)
  assert.eq(mb.x - mt.x, bb.x - bt.x)
  assert.eq(mb.y - mt.y, bb.y - bt.y)
  assert.eq(content(<minipage-content>).x - mt.x, padding.left)
  assert.eq(content(<minipage-content>).y - mt.y, padding.top)
  assert.eq(content(<block-content>).x - bt.x, padding.left)
  assert.eq(content(<block-content>).y - bt.y, padding.top)
}
