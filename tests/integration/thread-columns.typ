#import "../../src/lib.typ": *
#set page(width: 580pt, height: 340pt, margin: 35pt)
#show: deixis-setup-notes
#deixis-set(margin-layout: "exact")
#let renderer(data, ..args) = box(width: 100%, height: 22pt, {
  if not data.at("disable-links", default: false) {
    place(top + left, [#metadata(data.inst-id)<thread-column-note>])
  }
  deixis-native-render-single(data, ..args.named())
})
// Two separate blocks can share a thread in side-by-side columns. Their initial
// frame must come from instance ownership rather than just matching page/y.
#grid(columns: (1fr, 1fr), gutter: 15pt,
  deixis-block(id: "left-column", thread: "columns", height: 160pt, inset: (left: 8pt, right: 62pt, y: 8pt), stroke: gray)[
    Left#deixis-margin-note(side: right, dx: 3pt, render-single: renderer)[Left body.]
    Local#deixis-footnote[Left footer.]
  ],
  deixis-block(id: "right-column", thread: "columns", height: 160pt, inset: (left: 8pt, right: 62pt, y: 8pt), stroke: gray)[
    Right#deixis-margin-note(side: right, dx: 3pt, render-single: renderer)[Right body.]
    Local#deixis-footnote[Right footer.]
  ],
)
#context {
  let notes = query(<thread-column-note>)
  assert.eq(notes.len(), 2)
  let right-edges = query(<deixis-block-right>)
  for note in notes {
    let edge = right-edges.find(n => n.value.id == note.value)
    assert(calc.abs(note.location().position().x - edge.location().position().x - 3pt) < 0.01pt)
  }
  let footnotes = query(<deixis-rendered-start>).filter(n => n.value.body-type == "footnote")
  assert.eq(footnotes.len(), 2)
  assert.eq(footnotes.map(n => n.value.inst-id), ("left-column", "right-column").map(name => repr(("block", name))))
}
