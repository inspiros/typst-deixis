#import "../../src/lib.typ": *
#set page(width: 360pt, height: 250pt, margin: 30pt)
#show: deixis-setup-notes
#let policy = sys.inputs.at("policy", default: "native")
#let layer = sys.inputs.at("layer", default: "foreground")
#show: body => if policy == "native" { body } else { deixis-routing(policy: "manual", body) }
#let scene(doc) = {
  assert("counterpart" not in doc.continuation,
    message: "Accepted remote geometry must not enter speculative scene construction")
  let p = doc.continuation.point
  deixis-routing-scene(nodes: ((page: doc.page, bounds: (left: p.first() - 10pt, right: p.first() + 10pt,
    top: p.last() - 10pt, bottom: p.last() + 10pt)),))
}
#let marker(r) = {
  assert(r.allocation.shifted)
  let other = (r.counterpart)()
  if other != none {
    [#metadata((page: r.page, point: r.point, other: other))<scene-counterpart>]
    link(other.destination, [Other])
  }
}
#deixis-connect(from: (pin: <a>), to: (pin: <b>), connector: (
  route: "orthogonal", radius: 0pt, layer: layer, scene: scene, continuation: marker))
#place(top + left, dx: 40pt, dy: 60pt, deixis-pin(<a>, padding: 0pt))
First Page
#pagebreak()
#set page(width: 280pt, height: 290pt)
#place(top + left, dx: 160pt, dy: 80pt, deixis-pin(<b>, padding: 0pt))
Second Page
#context {
  let records = query(<scene-counterpart>).map(m => m.value)
  assert.eq(records.map(r => r.page).sorted(), (1, 2))
  for r in records { assert.eq(r.other.point, records.find(p => p.page != r.page).point) }
}
