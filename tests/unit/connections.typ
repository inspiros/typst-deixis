#import "../../src/routing/connections.typ": *
#import "../../src/routing/notes.typ": _deixis-paint-note-connections
#import "../../src/layout/geometry.typ": _deixis-box-bounds
#set page(width: 200pt, height: 180pt, margin: 0pt)
#context {
  // Sparse port candidates must retain the full node geometry. Two independently
  // styled routes reuse those nodes without selecting ports on the node itself.
  let source = _deixis-connection-node("mark", 1,
    ((x: 45pt, y: 30pt, dir: "vertical", id: "top"),),
    bounds: _deixis-box-bounds(20pt, 30pt, 70pt, 60pt), identity: "shared")
  let target = _deixis-connection-node("body", 1,
    ((x: 140pt, y: 90pt, dir: "vertical", id: "top"),),
    bounds: _deixis-box-bounds(120pt, 90pt, 160pt, 130pt), identity: "shared")
  let painter(name, request) = {
    let doc = request.route.document
    assert.eq(doc.nodes.mark.bounds, source.bounds)
    assert.eq(doc.nodes.body.bounds, target.bounds)
    if name == "side" {
      assert.eq(doc.endpoints.mark.point, (72pt, 37.5pt))
      assert.eq(doc.endpoints.body.point, (120pt, 100pt))
      assert(request.heads.mark == none and request.heads.body != none)
      assert.eq(request.stroke.paint, blue)
    } else {
      assert.eq(doc.endpoints.mark.point, (70pt, 60pt))
      assert.eq(doc.endpoints.body.point, (120pt, 90pt))
      assert(request.heads.mark != none and request.heads.body == none)
      assert.eq(request.stroke.paint, red)
    }
    [#metadata(name)<connection-event>]
  }
  let first = _deixis-prepared-connection(source, target,
    _deixis-connection-options((link: "straight-line", link-stroke: blue + 0.6pt,
      link-ports: (mark: (side: "right", at: 25%, gap: 2pt), body: (side: "left", at: 25%)),
      link-heads: (body: "triangle"), link-render: painter.with("side"))))
  let second = first + (options: first.options + (
    ports: (mark: "bottom", body: "top"), stroke: red + 0.8pt,
    heads: (mark: "circle"), render: painter.with("vertical"),
  ))
  let prepared(edge) = (edge: edge, highlight: none)
  _deixis-paint-note-connections((prepared(first), prepared(second)), 1).join()
  assert.eq(first.source, second.source)
  assert.eq(first.target, second.target)
  assert.eq(first.source.ports.len(), 1)
  // Disabled edges and pages without an endpoint do not invoke custom painters.
  assert.eq(_deixis-paint-note-connections((prepared(first),), 2), ())
  let disabled = first + (options: first.options + (route: "none"))
  assert.eq(_deixis-paint-note-connections((prepared(disabled),), 1), ())
}
#context assert.eq(query(<connection-event>).map(m => m.value), ("side", "vertical"))
