#import "../../src/lib.typ": deixis-routing-scene
#import "../../src/routing/group-plan.typ": _deixis-plan-group
#let scene = deixis-routing-scene()
#let edges = (
  (id: none, from: (point: (0, 0), normal: none, owner: none), to: (point: (100, 0), normal: none, owner: none)),
  (id: none, from: (point: (0, 1), normal: none, owner: none), to: (point: (100, 1), normal: none, owner: none)))
#let independent = _deixis-plan-group(scene, edges, independent: true)
#let separate = _deixis-plan-group(scene, edges)
#assert.eq(independent.records, separate.baseline)
#assert.eq(independent.metrics, none)
#assert.eq(independent.baseline-metrics, none)
#assert.eq(independent.history, ())
#assert.eq(independent.rounds-run, 0)
#assert.eq(independent.searches.len(), 2)
#assert(independent.searches.all(s => s.against == ()))
#assert.eq(independent.expanded, independent.records.map(r => r.stats.expanded).sum())
#let limited = _deixis-plan-group(scene, edges, independent: true, max-searches: 1)
#assert.eq(limited.records.map(r => r.status), ("ok", "budget"))
#assert.eq(limited.limits-hit, ("searches",))
#let empty = _deixis-plan-group(scene, (), independent: true)
#assert.eq(empty.searches, ())
#assert.eq(empty.expanded, 0)
#assert.eq(empty.metrics, none)
