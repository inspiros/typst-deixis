#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#set page(width: 360pt, height: 230pt, margin: 25pt)
#show: deixis-setup-notes
#let mode = sys.inputs.at("mode", default: "counterpart")
#let policy = sys.inputs.at("policy", default: "separate")
#let layer = sys.inputs.at("layer", default: "foreground")
#let painter = sys.inputs.at("painter", default: "native") == "custom"
#let route = sys.inputs.at("route", default: "orthogonal")
#let cuts = sys.inputs.at("cuts", default: "off") == "on"
#show: deixis-routing.with(policy: policy)
#let paint(r) = {
  [#metadata((route: r.route, shaft: r.shaft))<portal-route>]
  assert.eq(r.heads.mark, none)
  assert.eq(r.heads.body != none, r.route.document.is-incoming)
  deixis-render-connector(r)
}
#let spec = (if mode == "unlinked" { "portal" }
  else if mode == "dot" { "dot" }
  else if mode == "none" { none }
  else { (shape: "portal", link: if mode == "peer" { "peer" } else { "counterpart" }) })
#let edge = deixis-connect(from: (pin: "a"), to: (pin: <b>), connector: (
  route: route, radius: 0pt, ports: (mark: bottom, body: top), layer: layer,
  stroke: if mode == "disabled" { none } else { stroke(paint: blue, thickness: 1pt, cap: "round", dash: "dashed") },
  heads: "stealth", continuation: spec, cuts: if cuts { (at: 50%, length: 8pt) } else { none },
  render: if painter { paint } else { none }))
#if mode == "hidden" { hide(edge) } else { edge }
#place(top + left, dx: 70pt, dy: 80pt, deixis-pin(<a>, padding: 0pt))
First Page
#pagebreak()
No Shaft On This Page
#pagebreak()
#set page(width: 420pt, height: 290pt)
#place(top + left, dx: 230pt, dy: 90pt, deixis-pin("b", padding: 0pt))
Last Page
#let verify() = {
  assert.eq(deixis-system.final().registry.value.notes.len(), 0)
  let sites = query(<deixis-continuation-site>).map(m => m.value)
  let linked = mode in ("peer", "counterpart")
  let published = mode != "hidden" and (painter or mode == "counterpart")
  assert.eq(sites.len(), if published { 2 } else { 0 })
  let routes = query(<portal-route>).map(m => m.value)
  assert.eq(routes.len(), if painter and mode != "hidden" { 2 } else { 0 })
  for r in routes {
    assert(r.route.document.page in (1, 3))
    if mode not in ("disabled", "dot", "none") {
      if r.route.document.is-incoming { assert.ne(r.shaft.first().start, r.route.start) }
      else { assert.ne(r.shaft.last().end, r.route.end) }
    }
  }
  let targets = if not linked { () } else if mode == "counterpart" {
    sites.map(s => (page: s.page, x: s.point.first().pt(), y: s.point.last().pt()))
  } else {
    query(<deixis-pin>).map(m => { let p = m.location().position(); (page: p.page, x: p.x.pt(), y: p.y.pt()) })
  }
  (destinations: targets, links: if linked { 2 } else { 0 })
}
