#import "../../src/lib.typ": *
#set page(width: 400pt, height: 260pt, margin: 30pt)
#show: deixis-setup-notes
#let visits = sys.inputs.at("visits", default: "off") == "on"
#let missing = sys.inputs.at("missing", default: "off") == "on"
#let heads = state("scene-page-heads", ())
#let head(request) = (body: [#heads.update(xs => xs + (request.endpoint,))#circle(radius: 2pt)],
  trim: 2pt, bounds: (left: -2pt, right: 2pt, top: -2pt, bottom: 2pt))
#let scene(doc) = {
  assert(doc.page in (1, 3))
  assert.eq(doc.source-page, 1)
  assert.eq(doc.target-page, 3)
  assert.eq(doc.continuation.peer-page, if doc.page == 1 { 3 } else { 1 })
  deixis-routing-scene(nodes: (
    (pins: (<tl1>, <br1>)),
    // Unpaged nodes are never global obstacles, even on an omitted page.
    (bounds: (left: 0pt, top: 0pt, right: 1000pt, bottom: 1000pt)),
    (page: 2, bounds: (left: 0pt, top: 0pt, right: 1000pt, bottom: 1000pt)),
  ) + if missing { () } else { ((pins: (<tl3>, <br3>)),) })
}
#let paint(request) = {
  let doc = request.route.document
  assert.eq(request.route.page, doc.page)
  if visits {
    let point = (200pt - request.route.origin.first(), 150pt - request.route.origin.last())
    assert(request.route.segments.any(s => s.start == point or s.end == point))
  }
  [#metadata((page: doc.page, fragment: doc.fragment.kind, search: request.route.search,
    peer: doc.continuation.peer-page))<scene-page>]
  deixis-render-connector(request)
}
#let marker(request) = [#metadata(request.page)<scene-page-marker>]
#deixis-connect(from: (pin: <a>), to: (pin: <b>), connector: (
  route: "orthogonal", radius: 0pt, scene: scene, render: paint, heads: (mark: head, body: head), continuation: marker,
  via: if visits { ((pin: <v1>), "split", (pin: <v3>)) } else { auto },
))
#place(top + left, dx: 40pt, dy: 40pt, deixis-pin(<a>, padding: 0pt))
#place(top + left, dx: 170pt, dy: 120pt, deixis-pin(<v1>, padding: 0pt))
#place(top + left, dx: 20pt, dy: 90pt, deixis-attach(prefix: none,
  pins: (tl1: (anchor: top + left), br1: (anchor: bottom + right)), rect(width: 40pt, height: 60pt)))
Source Page
#pagebreak()
Intervening Page
#pagebreak()
#set page(width: 300pt, height: 290pt)
#place(top + left, dx: 40pt, dy: 170pt, deixis-pin(<b>, padding: 0pt))
#place(top + left, dx: 170pt, dy: 120pt, deixis-pin(<v3>, padding: 0pt))
#place(top + left, dx: 20pt, dy: 30pt, deixis-attach(prefix: none,
  pins: (tl3: (anchor: top + left), br3: (anchor: bottom + right)), rect(width: 40pt, height: 50pt)))
Target Page
#let verify() = {
  assert.eq(heads.final().sorted(), ("body", "mark"))
  assert.eq(query(<scene-page-marker>).map(m => m.value).sorted(), (1, 3))
  let records = query(<scene-page>).map(m => m.value).sorted(key: r => r.page)
  assert.eq(records.map(r => r.fragment), ("source", "target"))
  assert.eq(records.map(r => r.peer), (3, 1))
  assert(records.first().search != none)
  assert.eq(records.last().search == none, missing)
  records
}
