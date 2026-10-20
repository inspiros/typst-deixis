#import "../../src/lib.typ": *
#set page(width: 240pt, height: 180pt, margin: 20pt)
#show: deixis-setup-notes
// Document pins use setup; no note declarations are needed.
#context {
  let scene = deixis-routing-scene(nodes: ((id: <a>, pin: "a"), (id: <b>, pin: <b>)))
  let path = deixis-route(scene: scene, from: <a>, to: <b>)
  assert.eq(path.page, 1)
  assert.eq(path.status, "ok")
  assert.eq(path.origin, (40pt, 50pt))
  assert.eq(path.end, (140pt, 60pt))
  assert.eq(scene.nodes.map(n => n.behavior), ("ignore", "ignore"))
  place(top + left, dx: path.origin.first() - 20pt, dy: path.origin.last() - 20pt,
    deixis-render-connector(deixis-prepare-connector(path)))
}
#place(top + left, dx: 20pt, dy: 30pt, deixis-pin(<a>, padding: 10pt))
#place(top + left, dx: 160pt, dy: 90pt, deixis-pin(<b>, padding: 10pt))
