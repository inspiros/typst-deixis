#import "../../src/lib.typ": *
#set page(width: 320pt, height: 240pt, margin: 20pt)
#set text(size: 10pt)
#show: deixis-setup-notes
#let policy = sys.inputs.at("policy", default: "separate")
#let backwards = sys.inputs.at("direction", default: "forward") == "backward"
#let layer = sys.inputs.at("layer", default: "foreground")
#let fixed = sys.inputs.at("split", default: "auto") == "fixed"
#show: deixis-routing.with(policy: policy, weight: 8, spacing: 12pt, max-detour: 100%)
#let live = state("relay-repair-live", 0)
#let heads = state("relay-repair-heads", ())
#let head(r) = (body: [#heads.update(xs => xs + (r.endpoint,))#circle(radius: 1.5pt)],
  trim: 1.5pt, bounds: (left: -1.5pt, right: 1.5pt, top: -1.5pt, bottom: 1.5pt))
#let marker(index, r) = {
  let other = (r.counterpart)()
  if other == none { return [] }
  [#metadata((index: index, page: r.page, point: r.point,
    counterpart: other.point, destination: other.destination,
    preferred: r.allocation.preferred, shifted: r.allocation.shifted))<relay-repair-marker>]
  place(center + horizon, dx: if index == 0 { -18pt } else { 18pt }, dy: -r.normal.last() * 9pt,
    link(other.destination, box(width: 30pt, height: 12pt, fill: white,
      align(center + horizon, text(size: 7pt, [#index ↔])))))
}
#let paint(r) = {
  let d = r.route.document
  let end = r.route.origin.zip(r.route.end).map(((a, b)) => a + b)
  assert.eq(d.endpoints.mark.point, r.route.origin)
  assert.eq(d.endpoints.body.point, end)
  assert.eq(d.fragment.source, d.endpoints.mark)
  assert.eq(d.fragment.target, d.endpoints.body)
  assert.eq(d.continuation.point, if d.is-incoming { r.route.origin } else { end })
  assert.eq(d.continuation.allocation.shifted,
    d.continuation.point != d.continuation.allocation.preferred)
  if fixed { assert.eq(d.continuation.point.first(), 160pt) }
  deixis-render-connector(r)
}
#let node(id, x, y) = place(top + left, dx: x, dy: y,
  deixis-attach(id: id, [#live.update(n => n + 1)#rect(width: 30pt, height: 20pt, fill: white)]))
#for i in range(2) {
  deixis-connect(from: (node: <source>), to: (node: "target" + str(i)), connector: (
    route: "orthogonal", radius: 0pt, layer: layer,
    ports: (mark: bottom, body: top), heads: (mark: head, body: head),
    via: if fixed { (("split", "source"),) } else { auto },
    render: paint, continuation: marker.with(i)))
}
#if backwards {
  node("target0", 35pt, 80pt)
  node("target1", 215pt, 100pt)
} else { node(<source>, 125pt, 60pt) }
First Page
#pagebreak()
Middle Page
#pagebreak()
#set page(width: 360pt, height: 270pt, foreground: [Host Decoration])
#show: deixis-setup-notes
#if backwards { node(<source>, 125pt, 60pt) } else {
  node("target0", 35pt, 80pt)
  node("target1", 215pt, 100pt)
}
Last Page
#context {
  assert.eq(live.final(), 3)
  assert.eq(heads.final().sorted(), ("body", "body", "mark", "mark"))
  let markers = query(<relay-repair-marker>).map(m => m.value)
  assert.eq(markers.len(), 4)
  for m in markers {
    let other = markers.find(o => o.index == m.index and o.page != m.page)
    assert.eq(m.counterpart, other.point)
  }
  let plans = query(<deixis-routing-plan>).map(m => m.value.plan)
  if policy == "separate" and not fixed and not backwards {
    assert(markers.any(m => m.shifted))
    assert(plans.any(p => p.quality.after.exposure < p.quality.before.exposure))
  }
  // The two incoming halves now project their distinct local destinations;
  // unlike the shared outgoing source, they need no spill-socket repair.
  if policy == "avoid" or fixed or backwards { assert(markers.all(m => not m.shifted)) }
}
#let verify() = (destinations: query(<relay-repair-marker>).map(m => {
  let d = m.value.destination
  (page: d.page, x: d.x.pt(), y: d.y.pt())
}))
