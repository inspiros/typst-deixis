#import "../../src/lib.typ": *
#let font-page = sys.inputs.at("units", default: "pt") == "em"
#set text(size: if font-page { 10pt } else { 11pt })
#set page(width: if font-page { 50em } else { 500pt }, height: if font-page { 26em } else { 260pt },
  margin: if font-page { (x: 11em, y: 3em) } else { (x: 110pt, y: 30pt) })
#show: deixis-setup-notes
#let mode = sys.inputs.at("mode", default: "custom")
#let layer = sys.inputs.at("layer", default: "foreground")
#let scene-mode = sys.inputs.at("scene", default: "off")
#let scenes = scene-mode != "off"
#let live = state("margin-continuation-bodies", 0)
#let marker(id, request) = {
  assert(request.relay)
  let region = request.allocation.region
  assert.eq(region.kind, "margin")
  assert((region.left, region.right) in ((0pt, 110pt), (390pt, 500pt)))
  assert(region.left <= request.point.first() and request.point.first() <= region.right)
  assert.eq(request.normal, if request.direction == "incoming" { (0, -1) } else { (0, 1) })
  assert.eq(request.status, "resolved")
  let destination = if id == 4 { 3 } else { 2 }
  assert.eq(request.source-page, 1)
  assert.eq(request.target-page, destination)
  assert.eq(request.peer-page, if request.direction == "outgoing" { destination } else { 1 })
  assert.eq(request.peer.page, request.peer-page)
  assert.eq(request.allocation.shifted, scene-mode == "blocked" and request.direction == "outgoing")
  [#metadata((id: id, page: request.page, peer: request.peer-page, direction: request.direction))<margin-continuation>]
  [#metadata((page: request.peer.page, x: request.peer.point.first().pt(), y: request.peer.point.last().pt()))<continuation-destination>]
  link(request.peer.destination, [↗])
}
#for i in range(5) {
  deixis-margin-note(id: "note" + str(i), layer: layer, width: 85pt, connector: (
    route: if scenes { "orthogonal" } else { "curve" }, radius: if scenes { 0pt } else { auto },
    scene: if scenes { doc => {
      let boxes = if scene-mode == "blocked" and doc.is-outgoing {
        let p = doc.continuation.point
        ((page: doc.page, bounds: (left: p.first() - 8pt, right: p.first() + 8pt,
          top: p.last() - 8pt, bottom: p.last() + 8pt)),)
      } else { () }
      deixis-routing-scene(nodes: ((body: "note" + str(i)),) + boxes)
    } } else { none },
    stroke: if mode == "disabled" { none } else { blue + 1pt },
    continuation: if mode == "custom" { marker.with(i) } else if mode == "hidden" { none }
      else if mode == "portal" { (shape: "portal", link: "counterpart") } else { auto }),
    [Source #i], [#live.update(n => n + 1)#block(height: 85pt)[Body #i]])
}
#pagebreak()
Second Page
#pagebreak()
Third Page
#context {
  assert.eq(live.final(), 5)
  let markers = query(<margin-continuation>).map(n => n.value)
  assert.eq(markers.len(), if mode == "custom" { 6 } else { 0 })
  if mode == "custom" {
    assert.eq(markers.filter(m => m.direction == "outgoing").map(m => m.page), (1, 1, 1))
    assert.eq(markers.filter(m => m.direction == "incoming").map(m => m.page), (2, 2, 3))
  }
}

#let verify() = {
  if mode == "portal" {
    let sites = query(<deixis-continuation-site>).map(m => m.value)
    assert.eq(sites.len(), 6)
    (destinations: sites.map(s => (page: s.page, x: s.point.first().pt(), y: s.point.last().pt())))
  } else { (destinations: query(<continuation-destination>).map(m => m.value)) }
}
