#import "../../src/layout/geometry.typ": _deixis-segment-bounds
#context {
  let pad = (left: 1pt, right: 2pt, top: 3pt, bottom: 4pt)
  let points = ((page: 1, x: 10pt, y: 25pt, padding: pad), (page: 3, x: 40pt, y: 80pt, padding: pad))
  let start = _deixis-segment-bounds(points, 1, 10pt, 90pt, padding: 2pt)
  let middle = _deixis-segment-bounds(points, 2, 10pt, 90pt, padding: 2pt)
  let end = _deixis-segment-bounds(points, 3, 10pt, 90pt, padding: 2pt)
  assert.eq((start.left, start.right, start.top, start.bottom), (7pt, 44pt, 20pt, 90pt))
  assert.eq((middle.top, middle.bottom), (10pt, 90pt))
  assert.eq((end.top, end.bottom), (10pt, 86pt))
}
