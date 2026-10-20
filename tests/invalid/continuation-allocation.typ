#import "../../src/lib.typ": *
#set page(width: 400pt, height: 260pt, margin: 30pt)
#show: deixis-setup-notes
#let mode = sys.inputs.at("mode", default: "closed")
#let no-paint(request) = panic("Unexpected failed-fragment head/painter/marker execution")
#let scene(doc) = {
  let p = if mode in ("real-endpoint", "no-path") {
    if doc.is-outgoing { doc.endpoints.mark.point } else { doc.endpoints.body.point }
  } else if mode == "waypoint" { (180pt, 120pt) } else { doc.continuation.point }
  let boxes = if mode == "no-path" {
    ((left: p.first() - 20pt, right: p.first() + 20pt, top: p.last() - 20pt, bottom: p.last() - 15pt),
     (left: p.first() - 20pt, right: p.first() + 20pt, top: p.last() + 15pt, bottom: p.last() + 20pt),
     (left: p.first() - 20pt, right: p.first() - 15pt, top: p.last() - 20pt, bottom: p.last() + 20pt),
     (left: p.first() + 15pt, right: p.first() + 20pt, top: p.last() - 20pt, bottom: p.last() + 20pt))
  } else { ((
    left: if mode == "closed" { -20pt } else { p.first() - 10pt },
    right: if mode == "closed" { 420pt } else { p.first() + 10pt },
    top: p.last() - 10pt, bottom: p.last() + 10pt),) }
  deixis-routing-scene(nodes: boxes.map(b => (page: doc.page, bounds: b)),
    pages: ((page: doc.page, bounds: (left: 0pt, top: 0pt, right: 400pt, bottom: 260pt)),),
    max-cells: if mode == "budget" { 1 } else { 65536 },
    max-expansions: if mode == "expansions" { 1 } else { 50000 })
}
#deixis-connect(from: (pin: <a>), to: (pin: <b>), connector: (
  route: "orthogonal", radius: 0pt, scene: scene, render: no-paint, continuation: no-paint,
  heads: (mark: no-paint, body: no-paint),
  via: if mode == "fixed" { (("split", 0pt),) }
    else if mode == "waypoint" { ((relative-to: "page", offset: (180pt, 120pt)), "split",
      (relative-to: "page", offset: (180pt, 120pt))) } else { auto }))
#place(top + left, dx: 60pt, dy: 70pt, deixis-pin(<a>, padding: 0pt))
Source Page
#pagebreak()
#place(top + left, dx: 260pt, dy: 70pt, deixis-pin(<b>, padding: 0pt))
Target Page
