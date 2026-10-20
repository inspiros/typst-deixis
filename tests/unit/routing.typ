#import "../../src/routing/path.typ": *
#import "../../src/layout/margin.typ": _deixis-rubber-band
#context {
  let points = ((0pt, 0pt), (0pt, 0pt), (10pt, 0pt), (10pt, 10pt))
  let commands = _deixis-orthogonal-cmds(points, radius: 2pt)
  assert(commands.len() > 1)
  let box = (left: 10pt, right: 30pt, top: 20pt, bottom: 40pt, center-x: 20pt, center-y: 30pt)
  assert.eq(_deixis-resolve-waypoints((("mark-right", "body-bottom"),), 0pt, 0pt, box, box), ((30pt, 40pt),))
  let notes = ((y: 20pt, h: 15pt, gap: 0pt), (y: 22pt, h: 15pt, gap: 3pt))
  let positions = _deixis-rubber-band(notes, 0pt, 45pt)
  assert(positions.at(1) >= positions.at(0) + 18pt)
  assert(positions.last() + 15pt <= 45pt)
}
