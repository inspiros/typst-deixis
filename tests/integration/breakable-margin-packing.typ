#import "../../src/lib.typ": *
#set page(width: 500pt, height: 300pt, margin: (inside: 45pt, outside: 30pt, y: 30pt))
#set text(size: 10pt)
#show: deixis-setup-notes
#let body(data, ..args) = box(width: 100%, height: 70pt, {
  if not data.at("disable-links", default: false) {
    place(top + left, [#metadata((id: data.id, mode: data.series))<fragment-top>])
  }
  deixis-native-render-single(data, ..args.named())
})
#for mode in ("adaptive", "flow") {
  pagebreak(weak: true)
  deixis-set(margin-layout: mode, min-margin-width: 30pt, gap: 8pt)
  deixis-block(id: mode, breakable: true, inset: (x: 70pt, y: 10pt), stroke: gray)[
    Anchors.
    #for i in range(8) {
      deixis-margin-note(marker: none, side: right, series: mode, width: 50pt, dx: 4pt,
        render-single: body, id: label(mode + str(i)))[Spilled body #i.]
    }
    #for i in range(20) {
      [Content paragraph #i.]
      v(42pt)
    }
  ]
}
#context {
  let tops = query(<fragment-top>)
  assert.eq(tops.len(), 16)
  let frames = query(<deixis-page-frame>)
  for mode in ("adaptive", "flow") {
    let notes = tops.filter(n => n.value.mode == mode)
    assert.eq(notes.map(n => n.location().page()).dedup().len(), 4)
    assert.eq(notes.map(n => n.value.id), range(8).map(i => label(mode + str(i))))
    for frame in frames {
      let local = notes.filter(n => n.location().page() == frame.value.page)
      if local.len() == 0 { continue }
      assert.eq(local.len(), 2)
      for (i, note) in local.enumerate() {
        let pos = note.location().position()
        assert(pos.y >= 40pt - 0.01pt and pos.y + 70pt <= 260pt + 0.01pt)
        let expected-x = frame.value.margins.left + 70pt + 285pt + 4pt
        assert(calc.abs(pos.x - expected-x) < 0.01pt)
        if i > 0 { assert(pos.y >= local.at(i - 1).location().position().y + 78pt - 0.01pt) }
      }
    }
  }
}
