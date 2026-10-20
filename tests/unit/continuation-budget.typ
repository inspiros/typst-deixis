#import "../../src/lib.typ": deixis-routing-scene
#import "../../src/routing/connector-scene.typ": _deixis-connector-scene-plan
#let s = deixis-routing-scene(nodes: ((page: 1, bounds: (left: 170pt, right: 190pt, top: 0pt, bottom: 260pt)),),
  pages: ((page: 1, bounds: (left: 0pt, right: 400pt, top: 0pt, bottom: 260pt)),))
#let p = (scene: s, plane: s.planes.find(p => p.page == 1))
#let start = (point: (70pt, 100pt), normal: (0, 0))
#let end = (point: (330pt, 230pt), normal: (0, -1))
#let doc = (page: 1, is-incoming: false, is-outgoing: true,
  fragment: (logical: (source: none, target: none)))
#let boundary = (left: 0, right: 400, top: 0, bottom: 260, preferred: 330)
#let preferred = _deixis-connector-scene-plan(p, start, end, (), doc, "right-angle", 0pt)
#assert.eq(preferred.status, "no-path")
#let spent = preferred.stats.expanded
#let allocated = _deixis-connector-scene-plan(p, start, end, (), doc, "right-angle", 0pt, boundary: boundary)
#assert.eq(allocated.status, "ok")
#assert.eq(allocated.search.attempts, 2)
#assert(allocated.search.expanded > spent)
// The retry shares one expansion allowance with the unreachable preferred
// route. Resetting that allowance would incorrectly let these calls succeed.
#for extra in (0, 1) {
  let limited = p + (scene: s + (max-expansions: spent + extra))
  let result = _deixis-connector-scene-plan(limited, start, end, (), doc, "right-angle", 0pt, boundary: boundary)
  assert.eq(result.status, "budget")
  assert(result.stats.expanded <= spent + extra + 1)
}
