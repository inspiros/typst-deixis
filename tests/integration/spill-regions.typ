#import "../../src/lib.typ": *
#let policy = sys.inputs.at("policy", default: "native")
#let side = sys.inputs.at("side", default: "right")
#let kind = sys.inputs.at("kind", default: "margin")
#let layer = sys.inputs.at("layer", default: "foreground")
#let backwards = sys.inputs.at("direction", default: "forward") == "backward"
#let override = sys.inputs.at("spill", default: "auto")
#let point = sys.inputs.at("point", default: "none")
#let obstacle = sys.inputs.at("obstacle", default: "preferred")
#set page(width: 420pt, height: 260pt, margin: (left: 90pt, right: 110pt, y: 30pt))
#set text(size: 10pt)
#show: deixis-setup-notes
#show: body => if policy in ("native", "scene") { body } else { deixis-routing(policy: policy, body) }
#let live = state("spill-region-bodies", 0)
#let scene(d) = {
  let p = d.continuation.point
  if obstacle == "channel" {
    return deixis-routing-scene(nodes: if d.is-outgoing {
      ((page: d.page, bounds: (left: 300pt, right: 420pt, top: 210pt, bottom: 260pt)),)
    } else { () })
  }
  deixis-routing-scene(nodes: ((page: d.page, bounds: (
    left: p.first() - 8pt, right: p.first() + 8pt, top: p.last() - 8pt, bottom: p.last() + 8pt)),))
}
#let paint(r) = {
  let c = r.route.document.continuation
  let region = c.allocation.region
  let width = if c.page == 1 { 420pt } else { 360pt }
  let expected = if override == "page" { (0pt, width) }
    else if override == "custom" { (width * 20%, width * 80%) }
    else if override == "content" or kind != "margin" { (90pt, width - 110pt) }
    else if side == "left" { (0pt, 90pt) } else { (width - 110pt, width) }
  assert.eq((region.left, region.right), expected)
  assert(region.left <= c.point.first() and c.point.first() <= region.right)
  if policy == "scene" { assert.eq(c.allocation.shifted, obstacle == "preferred") }
  [#metadata((page: c.page, x: c.point.first(), kind: region.kind))<spill-region-painted>]
  deixis-render-connector(r)
}
#let options = (route: "orthogonal", radius: 0pt, layer: layer, render: paint,
  continuation: (shape: "portal", link: "counterpart"),
  scene: if policy == "scene" { scene } else { none },
  spill: if override == "custom" { (left: 20%, right: 80%) } else if override == "auto" { auto } else { override })
#let source() = place(top + left, dx: 60pt, dy: 80pt, deixis-pin(<source>, padding: 0pt))
#let destination() = {
  if kind == "margin" {
    deixis-margin-note(id: <note>, side: side, width: 65pt, layer: layer, connector: none)[Mark][#live.update(n => n + 1)Margin Body]
  } else if kind == "inset" {
    deixis-inset-note(id: <note>, width: 65pt, dx: 70pt, dy: 65pt, layer: layer, connector: none)[Mark][#live.update(n => n + 1)Inset Body]
  } else {
    place(top + left, dx: 80pt, dy: 90pt, deixis-attach(id: <node>, rect(width: 50pt, height: 25pt)))
  }
}
#deixis-connect(from: (pin: <source>), to: if kind == "node" { (node: <node>) } else if point != "none" { (body: <note>, point: point) } else { <note> }, connector: options)
#if backwards { destination() } else { source() }
First Page
#pagebreak()
Middle Page
#pagebreak()
#set page(width: 360pt, height: 290pt)
#if backwards { source() } else { destination() }
Last Page
#context {
  assert.eq(query(<spill-region-painted>).len(), 2)
  assert.eq(live.final(), if kind == "node" { 0 } else { 1 })
}
