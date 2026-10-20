#import "../../src/lib.typ": deixis-routing-scene
#import "../../src/routing/connector-scene.typ": _deixis-connector-scene-plan, _deixis-scene-entity
#let identity = (annotation: "private-note", occurrence: "again")
#let scene = deixis-routing-scene(nodes: ((bounds: (left: 0.1pt, top: 20pt, right: 40pt, bottom: 40pt)),))
#let plane = scene.planes.first()
#let entity = _deixis-scene-entity("mark", identity)
#let _ = plane.nodes.at(0).insert("entity", entity)
#let prepared = (scene: scene, plane: plane)
#let doc = (page: 1, is-incoming: false, is-outgoing: false,
  fragment: (logical: (source: (identity: identity), target: none)))
#for (normal, border) in (((1, 0), (40pt, 30pt)), ((-1, 0), (0.1pt, 30pt)),
  ((0, 1), (30pt, 40pt)), ((0, -1), (30pt, 20pt))) {
  for gap in (0pt, 1.5pt, 4pt, 8pt) {
    let point = border.zip(normal).map(((v, n)) => v + n * gap)
    let end = border.zip(normal).map(((v, n)) => v + n * 100pt)
    let route = _deixis-connector-scene-plan(prepared, (point: point, normal: normal),
      (point: end, normal: (0, 0)), (), doc, "right-angle", 0pt)
    assert.eq(route.status, "ok")
    assert.eq(route.origin, point)
    assert(calc.abs(route.length - (100pt - gap)) < 0.000001pt)
    assert.eq(route.start-tangent, normal)
  }
  // An interior socket must not obtain the endpoint owner's exemption.
  let point = border.zip(normal).map(((v, n)) => v - n * 1pt)
  let end = border.zip(normal).map(((v, n)) => v + n * 100pt)
  let route = _deixis-connector-scene-plan(prepared, (point: point, normal: normal),
    (point: end, normal: (0, 0)), (), doc, "right-angle", 0pt)
  assert.eq(route.status, "endpoint-blocked")
  // Geometric containment alone cannot confer ownership on another identity.
  let foreign = doc + (fragment: (logical: (source: (identity: "other"), target: none)))
  route = _deixis-connector-scene-plan(prepared, (point: border, normal: normal),
    (point: end, normal: (0, 0)), (), foreign, "right-angle", 0pt)
  assert.eq(route.status, "endpoint-blocked")
}
#assert.eq(_deixis-scene-entity("body", "private-note"),
  _deixis-scene-entity("body", (annotation: "private-note")))
