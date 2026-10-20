#import "../../src/routing/spill.typ": *
#context {
  let frame = (page: 1, width: 400pt, height: 260pt,
    margins: (left: 60pt, right: 90pt, top: 25pt, bottom: 35pt))
  let region(spec, margin: none) = _deixis-spill-region(_deixis-spill-spec(spec), frame, margin: margin)
  assert.eq(region(auto), (left: 60pt, right: 310pt, top: 25pt, bottom: 225pt, kind: "content"))
  assert.eq(region(auto, margin: (side: left, scope: none)).left, 0pt)
  assert.eq(region(auto, margin: (side: right, scope: none)).right, 400pt)
  assert.eq(region("content", margin: (side: left, scope: "absent")).left, 60pt)
  assert.eq(region("page").right, 400pt)
  assert.eq(region((left: 10%, right: 90%)).left, 40pt)
  assert.eq(region((left: 5pt + 10%, right: 90%)).left, 45pt)
  let local = (left: 100pt, right: 280pt, top: 50pt, bottom: 190pt, left-space: 40pt, right-space: 50pt)
  let scoped = region(auto, margin: (side: left, scope: none, frame: local))
  assert.eq(scoped, (left: 60pt, right: 100pt, top: 50pt, bottom: 190pt, kind: "margin"))
  // An accepted destination frame is local to its own physical page.
  let remote = region(auto, margin: (side: left, scope: none, page: 2, frame: local))
  assert.eq((remote.left, remote.right), (0pt, 60pt))
  {
    set text(size: 20pt)
    context {
      let frozen = _deixis-spill-spec((left: 1em, right: 50% + 2em))
      assert.eq(frozen.left, 20pt + 0%)
      assert.eq(frozen.right, 50% + 40pt)
      assert.eq(_deixis-spill-region(frozen, frame).right, 240pt)
    }
  }
}
