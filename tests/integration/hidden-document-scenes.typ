#import "../../src/lib.typ": *
#set page(width: 320pt, height: 240pt, margin: 30pt)
#show: deixis-setup-notes
#let kind = sys.inputs.at("kind", default: "mark")
#hide[
  #deixis-inset-note(id: <covered>, connector: none, width: 60pt)[Covered][Body]
  #deixis-mark(of: <covered>, occurrence: <again>)[Covered Repeat]
  #deixis-mark(of: <covered>, occurrence: <region>, mark-type: "region")[Covered Region]
  #deixis-pin(<covered-pin>)
]
#place(top + left, dx: 200pt, dy: 100pt, deixis-pin(<live-pin>, padding: 0pt))
#context {
  let spec = if kind == "body" { (body: <covered>) }
    else if kind == "pin" { (pin: <covered-pin>) }
    else if kind == "pins" { (pins: (<covered-pin>, <live-pin>)) }
    else if kind == "repeat" { (mark: <covered>, occurrence: <again>) }
    else if kind == "region" { (mark: <covered>, occurrence: <region>) }
    else { (mark: <covered>) }
  let scene = deixis-routing-scene(nodes: (spec + (id: <covered-node>), (id: <live>, pin: <live-pin>)))
  assert(scene.nodes.at(scene.ids.at("covered-node")).hidden)
  assert(scene.planes.all(p => p.nodes.all(n => n.id != "covered-node")))
  let r = deixis-route(scene: scene, from: <covered-node>, to: <live>, route: "orthogonal")
  assert.eq((r.status, r.detail), ("endpoint-hidden", "source"))
  assert.eq(deixis-route(scene: scene, from: <live>, to: <covered-node>, route: "orthogonal").detail, "target")
}
