#import "../../src/layout/margin.typ": _deixis-predict-cascade, deixis-margin-note-exact-layout, deixis-margin-note-adaptive-layout, deixis-margin-note-flow-layout

// Crowded notes are measured at each candidate frame's real margin width. The
// accepted plan must be used for bodies and connector ports without remeasurement.
#let body(data, ..args) = {
  if data.at("painting-only", default: false) {
    assert(not data.at("disable-links", default: false), message: "An accepted placement was measured again.")
  }
  layout(size => {
    let height = data.test-height + calc.max(0pt, 80pt - size.width) / 2
    box(width: 100%, height: height, fill: rgb("edf4fa"), stroke: 0.4pt + blue, {
      if not data.at("disable-links", default: false) {
        place(top + left, [#metadata(data.test-id)<planned-body>])
        place(bottom + right, [#metadata(data.test-id)<planned-body-end>])
      }
      text(size: 8pt, data.test-id)
    })
  })
}
#let connector(id, request) = {
  if request.route.document.endpoints.body.role == "body" {
    [#metadata((id: id, bounds: request.route.document.nodes.body.bounds))<planned-port>]
  }
  for s in request.shaft {
    place(top + left, curve(stroke: request.stroke, curve.move(s.start),
      if s.kind == "line" { curve.line(s.end) } else { curve.cubic(s.c1, s.c2, s.end) }))
  }
}

#for (mode-index, (mode, painter)) in (
  ("exact", deixis-margin-note-exact-layout),
  ("adaptive", deixis-margin-note-adaptive-layout),
  ("flow", deixis-margin-note-flow-layout),
).enumerate() {
  let frames = (
    (page: mode-index * 2 + 1, top: 20pt, bottom: 150pt, l-space: 80pt, r-space: 90pt),
    (page: mode-index * 2 + 2, top: 12pt, bottom: 200pt, l-space: 55pt, r-space: 110pt),
  )
  context {
    let notes = (30pt, 45pt, 35pt, 52pt, 32pt, 24pt).enumerate().map(((i, h)) => {
      let id = mode + "-" + str(i)
      (
        mark-page: frames.first().page, mark-x: 190pt, mark-y: 30pt + i * 7pt, marker-width: 12pt,
        note-data: (
          test-id: id, test-height: h, render-single: body,
          side: if i == 5 { left } else { right }, width: 80%, dx: if i == 5 { 20pt } else { auto },
          dy: if i == 2 { 48pt } else { 0pt }, gap: 9pt,
          mark-align: if i == 1 { horizon } else if i == 5 { bottom } else { top },
          mark-align-strictness: "loose", spillover: true,
          link: "curve", link-stroke: blue + 0.6pt, link-render: connector.with(id), link-ports: (mark: right, body: left),
        ),
      )
    })
    let plan = _deixis-predict-cascade(notes, frames, ltr, mode, min-margin-width: 40pt)
    assert.eq(plan.len(), notes.len())
    assert.eq(plan.map(n => n.note-data.test-id).sorted(), notes.map(n => n.note-data.test-id).sorted())
    if mode == "exact" {
      assert(plan.all(n => n.block-idx == 0))
    } else {
      assert(plan.any(n => n.block-idx == 1), message: "Crowded notes should spill to the second frame.")
      for (index, frame) in frames.enumerate() {
        for side in (left, right) {
          let group = plan.filter(n => n.block-idx == index and n._margin-placement.side == side)
          for (i, n) in group.enumerate() {
            let p = n._margin-placement
            assert(p.final-y >= frame.top - 0.01pt)
            assert(p.final-y + p.h <= frame.bottom + 0.01pt)
            if i > 0 {
              let prev = group.at(i - 1)._margin-placement
              assert(p.final-y >= prev.final-y + prev.h + p.gap - 0.01pt)
            }
          }
        }
      }
    }
    for (index, frame) in frames.enumerate() {
      set page(width: if index == 0 { 400pt } else { 520pt }, height: if index == 0 { 180pt } else { 230pt },
        margin: 0pt, binding: left)
      let start-x = frame.l-space
      let text-width = if index == 0 { 230pt } else { 355pt }
      let active = plan.filter(n => n.block-idx == index)
      for n in active {
        let p = n._margin-placement
        let x = if p.side == left { start-x - p.dx - p.w } else { start-x + text-width + p.dx }
        [#metadata((id: n.note-data.test-id, page: frame.page, x: x, y: p.final-y, w: p.w, h: p.h))<expected-placement>]
      }
      let painted = active.map(n => n + (note-data: n.note-data + (painting-only: true)))
      painter(painted, frame.top, frame.bottom, start-x, text-width, frame.bottom,
        frame.l-space, frame.r-space, frame.page, min-margin-width: 40pt,
        pushed-notes: plan.filter(n => n.mark-page == frame.page and n.block-idx > index))
      pagebreak(weak: true)
    }
  }
}
#context {
  let expected = query(<expected-placement>).map(n => n.value)
  let bodies = query(<planned-body>)
  let ends = query(<planned-body-end>)
  let ports = query(<planned-port>)
  assert.eq(expected.len(), 18)
  assert.eq(bodies.len(), expected.len())
  assert.eq(ends.len(), expected.len())
  assert.eq(ports.len(), expected.len())
  for e in expected {
    let b = bodies.filter(n => n.value == e.id)
    let p = ports.filter(n => n.value.id == e.id)
    assert.eq(b.len(), 1)
    assert.eq(p.len(), 1)
    assert.eq(b.first().location().page(), e.page)
    let pos = b.first().location().position()
    assert(calc.abs(pos.x - e.x) < 0.01pt, message: "Body x differs from its plan: " + e.id)
    assert(calc.abs(pos.y - e.y) < 0.01pt, message: "Body y differs from its plan: " + e.id)
    let end = ends.find(n => n.value == e.id).location().position()
    assert(calc.abs(end.x - e.x - e.w) < 0.01pt)
    assert(calc.abs(end.y - e.y - e.h) < 0.01pt)
    let bounds = p.first().value.bounds
    assert(calc.abs(bounds.left - e.x) < 0.01pt)
    assert(calc.abs(bounds.top - e.y) < 0.01pt)
    assert(calc.abs(bounds.right - e.x - e.w) < 0.01pt)
    assert(calc.abs(bounds.bottom - e.y - e.h) < 0.01pt)
  }
}
