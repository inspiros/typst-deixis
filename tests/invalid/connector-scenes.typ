#import "../../src/lib.typ": *
#set page(width: 400pt, height: 260pt, margin: 20pt)
#show: deixis-setup-notes
#let mode = sys.inputs.at("mode", default: "type")
#let form = sys.inputs.at("form", default: "explicit")
#let no-paint(request) = panic("Unexpected head or painter execution")
#let obstacle = (page: 1, bounds: (left: 140pt, top: 30pt, right: 200pt, bottom: 200pt))
#let construct(doc) = {
  let nodes = (obstacle,)
  let extra = (:)
  if mode == "endpoint" { nodes = ((page: 1, bounds: (left: 30pt, top: 80pt, right: 70pt, bottom: 120pt)),) }
  if mode == "waypoint" { nodes = (obstacle,) }
  if mode == "no-path" { nodes = ((page: 1, bounds: (left: 140pt, top: 0pt, right: 200pt, bottom: 260pt)),) }
  if mode == "budget" { extra = (max-cells: 1) }
  if mode == "continuation" {
    let p = doc.continuation.point
    nodes = ((page: doc.page, bounds: (left: p.first() - 10pt, right: p.first() + 10pt,
      top: p.last() - 10pt, bottom: p.last() + 10pt)),)
  }
  if mode in ("owner", "padding", "foreign", "interior") {
    nodes = ((mark: <note>, padding: if mode == "padding" { 10pt } else { 0pt }), (body: <note>))
    if mode == "owner" { nodes += ((mark: <note>),) }
    if mode == "foreign" {
      let b = doc.nodes.mark.bounds
      nodes += ((page: 1, bounds: (left: b.left, top: b.top, right: b.right + 4pt, bottom: b.bottom)),)
    }
  }
  deixis-routing-scene(nodes: nodes, pages: ((page: 1, bounds: (left: 0pt, top: 0pt, right: 400pt, bottom: 260pt)),), ..extra)
}
#let options = (route: "orthogonal", radius: 0pt, scene: construct,
  heads: (mark: no-paint, body: no-paint), render: no-paint, continuation: no-paint)
#if mode == "type" { options.scene = 1 }
#if mode == "tag" { options.scene = (kind: "other") }
#if mode == "callback" { options.scene = doc => none }
#if mode == "legacy" { options.route = request => [] }
#if mode == "curve" { options.route = "curve" }
#if mode == "rounded" { options.radius = 3pt }
#if mode == "radius-auto" { options.radius = auto }
#if mode == "mixed" { options.via = ("polyline",) }
#if mode == "radius" { options.radius = -1pt }
#if mode == "waypoint" { options.via = ((relative-to: "page", offset: (170pt, 100pt)),) }
#if mode == "continuation" { options.via = (("split", 0pt),) }
#if mode == "interior" { options.ports = (mark: (side: right, gap: -2pt)) }
#if mode in ("owner", "padding", "foreign", "interior") {
  deixis-mark(id: <note>)[Source]
  deixis-inset-note-body(of: <note>, width: 60pt, connector: options,
    placement: x => place(top + left, dx: 300pt, dy: 90pt, x))[Body]
} else if form == "margin" {
  deixis-margin-note(connector: options)[Source][Body]
} else if form == "inset" {
  deixis-inset-note(connector: options, dx: 280pt, dy: 90pt)[Source][Body]
} else {
  deixis-connect(from: (pin: <a>), to: (pin: <b>), connector: options)
  place(top + left, dx: 30pt, dy: 80pt, deixis-pin(<a>, padding: 0pt))
  if mode == "continuation" { pagebreak() }
  place(top + left, dx: 330pt, dy: 80pt, deixis-pin(<b>, padding: 0pt))
}
