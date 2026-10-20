#import "../../src/lib.typ": *
#set page(width: 360pt, height: 300pt, margin: 30pt)
#show: deixis-setup-notes

= Public Anchored Placement

// Bounds include the selected pins' padding, and target/body alignments can differ.
#place(top + left, dx: 80pt, dy: 90pt, deixis-pin("first", padding: 4pt))
#place(top + left, dx: 140pt, dy: 120pt, deixis-pin("last", padding: 6pt))
#deixis-place-anchored(
  pin: ((name: "first"), (name: "last")),
  anchor: (target: bottom + right, body: top + left), dx: 7pt, dy: 9pt,
)[#box(width: 64pt, height: 24pt, fill: blue.lighten(85%))[
  #place(top + left)[#metadata(none)<placement-pinned>]Pinned
]]

// No pin uses the native declaration point, with the same body alignment rules.
#box(width: 0pt, height: 0pt)[
  #metadata(none)<placement-origin>
  #deixis-place-anchored(anchor: top + left, dx: 10pt, dy: 24pt,
    body-size: (width: 64pt, height: 24pt),
  )[#box(width: 64pt, height: 24pt, fill: green.lighten(85%))[
    #place(top + left)[#metadata(none)<placement-local>]Local
  ]]
]

#context {
  let pos(lbl) = query(lbl).first().location().position()
  let last = query(<deixis-pin>).find(p => p.value.name == "last").location().position()
  let pinned = pos(<placement-pinned>)
  assert.eq(pinned.page, last.page)
  assert.eq(pinned.x, last.x + 6pt + 7pt)
  assert.eq(pinned.y, last.y + 6pt + 9pt)
  let origin = pos(<placement-origin>)
  let local = pos(<placement-local>)
  assert.eq(local.page, origin.page)
  assert.eq(local.x, origin.x + 10pt)
  assert.eq(local.y, origin.y + 24pt)
}
