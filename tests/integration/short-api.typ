#import "@preview/deixis:0.2.0": short, deixis-configure, deixis-set, deixis-block
#import short: *
#import "@preview/deixis:0.2.0": short as dx
#set page(width: 340pt, height: 330pt, margin: 30pt)
#set block(above: 5pt, below: 5pt)
#assert.eq(block, std.block)
#assert.eq(configure, deixis-configure)
#assert.eq(configure, deixis-set)
#assert.eq(note-block, deixis-block)
#show: setup-notes
#configure(stroke: teal)
Native #block[Native Block Remains Available.]
Outside#footnote(id: <outside>)[Document Footnote.]
#note-block(id: <local>)[
  #configure(stroke: orange)
  Local#footnote(id: <inside>)[Local Collection.]
  #context assert.eq(note-counter(), 1)
]
#minipage[
  Mini#footnote[Minipage Collection.]
]
#context assert.eq(note-counter(), 1)
See #ref(<outside>) and #ref(<inside>).
Native footer#std.footnote[Native Footnote Remains Available.]
#context {
  assert.eq(query-notes().len(), 4)
  assert.eq(query-notes().find(n => n.id == <outside>).count, 1)
}
#pagebreak()
Qualified#dx.footnote[A Qualified Footnote.]
#context {
  assert.eq(dx.note-counter(), 2)
  assert.eq(dx.query-notes().len(), 4)
}
