#import "../../src/lib.typ": *
#set page(width: 400pt, height: 260pt, margin: 25pt)
#show: deixis-setup-notes
#let constraint = sys.inputs.at("constraint", default: "source")
#let no-paint(request) = panic("Unexpected head or painter execution")
#let scene(doc) = {
  let p = doc.endpoints.at(if constraint == "target" { "body" } else { "mark" }).point
  let b = doc.nodes.mark.bounds
  deixis-routing-scene(clearance: 1pt, nodes: ((mark: <note>), (body: <note>),
    (page: doc.page, bounds: (left: p.first() - 1pt, right: p.first() + 1pt,
      top: if constraint == "side" { b.top - 4pt } else { p.last() - 1pt },
      bottom: if constraint == "side" { b.bottom + 4pt } else { p.last() + 1pt }))))
}
#let options = (route: "orthogonal", radius: 0pt, scene: scene, render: no-paint,
  heads: (mark: no-paint, body: no-paint), ports:
    ((if constraint == "target" { "body" } else { "mark" }): if constraint == "pin" { (pin: <socket>, side: right) }
      else if constraint == "side" { right } else { (side: if constraint == "target" { left } else { right }, at: 50%) }))
#deixis-connect(from: <note>, to: <note>, connector: options)
#place(top + left, dx: 85pt, dy: 95pt, deixis-pin(<socket>, padding: 0pt))
#place(top + left, dx: 30pt, dy: 80pt,
  deixis-mark(id: <note>, mark-type: "region", inline: true)[#box(width: 50pt, height: 30pt)[Source]])
#deixis-inset-note-body(of: <note>, width: 65pt, connector: none,
  placement: x => place(top + left, dx: 270pt, dy: 80pt, x))[Body]
