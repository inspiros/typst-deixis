#import "../../src/lib.typ": *
#set page(width: 500pt, height: 280pt, margin: (x: 100pt, y: 25pt))
#set text(size: 10pt)
#show: deixis-setup-notes
#let adapter = sys.inputs.at("adapter", default: "explicit")
#let layer = sys.inputs.at("layer", default: "foreground")
#let side = sys.inputs.at("side", default: "right")
#let mode = sys.inputs.at("mode", default: "both")
#let direction = sys.inputs.at("direction", default: "same")
#let visits = sys.inputs.at("visits", default: "off") == "on"
#let delegated = sys.inputs.at("painter", default: "delegate") == "delegate"
#let live = state("slide-body", 0)
#let heads = state("slide-heads", ())
#let head(r) = (body: [#heads.update(xs => xs + (r.endpoint,))#circle(radius: 1pt)],
  trim: 1pt, bounds: (left: -1pt, top: -1pt, right: 1pt, bottom: 1pt))
#let scene(doc) = {
  let nodes = ((mark: <note>), (body: <note>))
  for (role, active) in (("mark", not doc.is-incoming and mode in ("source", "both")),
    ("body", not doc.is-outgoing and mode in ("target", "both"))) {
    if active {
      let p = doc.endpoints.at(role).point
      nodes.push((page: doc.page, bounds: (left: p.first() - 1pt, top: p.last() - 1pt,
        right: p.first() + 1pt, bottom: p.last() + 1pt)))
    }
  }
  deixis-routing-scene(nodes: nodes, clearance: 1pt, escape: 3pt)
}
#let paint(r) = {
  let d = r.route.document
  assert.eq(r.route.origin, d.endpoints.mark.point)
  assert.eq(r.route.origin.zip(r.route.end).map(((v, o)) => v + o), d.endpoints.body.point)
  assert.eq(r.route.start-tangent, d.endpoints.mark.normal)
  assert.eq(r.route.end-tangent.map(v => -v), d.endpoints.body.normal)
  let changed = if d.is-incoming { mode in ("target", "both") } else if d.is-outgoing { mode in ("source", "both") } else { mode != "clear" }
  assert.eq(r.route.search.at("attempts", default: 1), if changed { 2 } else { 1 })
  for (role, virtual) in (("mark", d.is-incoming), ("body", d.is-outgoing)) {
    if virtual { continue }
    let p = d.endpoints.at(role)
    let b = d.nodes.at(role).bounds
    let normal = if (role == "mark") == (side == "right") { (1, 0) } else { (-1, 0) }
    assert.eq(p.normal, normal)
    assert(b.top - 0.001pt <= p.point.last() and p.point.last() <= b.bottom + 0.001pt)
    let gap = if adapter == "margin" { 0pt } else if role == "mark" { 2pt } else { 3pt }
    assert(calc.abs(p.point.first() - (if normal.first() == 1 { b.right + gap } else { b.left - gap })) < 0.001pt)
  }
  if visits {
    let expected = if d.is-incoming { (230pt, 180pt) } else { (220pt, 180pt) }
    assert(r.route.segments.any(s => s.end.zip(r.route.origin).map(((v, o)) => v + o) == expected))
  }
  [#metadata((page: d.page, endpoints: d.endpoints, search: r.route.search))<side-route>]
  deixis-render-connector(r)
}
#let options = (route: "orthogonal", radius: 0pt, stroke: blue + 0.7pt, layer: layer,
  heads: (mark: head, body: head), scene: scene, render: if delegated { paint } else { none }, continuation: none,
  ports: if adapter == "margin" { auto } else { (mark: (side: side, gap: 2pt),
    body: (side: if side == "right" { left } else { right }, gap: 3pt)) },
  via: if not visits { auto } else if direction == "same" { ((relative-to: "page", offset: (220pt, 180pt)),) }
    else { ((relative-to: "page", offset: (220pt, 180pt)), "split", (relative-to: "page", offset: (230pt, 180pt))) })
#let source() = place(top + left, dx: 40pt, dy: 70pt,
  deixis-mark(id: <note>, mark-type: "region", inline: true)[#box(width: 50pt, height: 35pt)[Source]])
#let target() = {
  let body = [#live.update(n => n + 1)#block(height: 45pt)[One Body]]
  if adapter == "margin" {
    deixis-margin-note-body(of: <note>, layer: layer, side: side, width: 65pt, connector: options, body)
  } else {
    deixis-inset-note-body(of: <note>, layer: layer, width: 65pt,
      connector: if adapter == "inset" { options } else { none },
      placement: x => place(top + left, dx: if side == "right" { 300pt } else { 30pt }, dy: 70pt, x), body)
  }
}
#if adapter == "explicit" { deixis-connect(from: <note>, to: <note>, connector: options) }
#if direction == "backward" { target() } else { source() }
First Page
#if direction != "same" { pagebreak(); [Middle Page]; pagebreak(); [Last Page] }
#if direction == "backward" { source() } else { target() }
#let verify() = {
  assert.eq(live.final(), 1)
  assert.eq(heads.final().sorted(), ("body", "mark"))
  assert.eq(query(<side-route>).len(), if not delegated { 0 } else if direction == "same" { 1 } else { 2 })
  query(<side-route>).map(r => r.value)
}
