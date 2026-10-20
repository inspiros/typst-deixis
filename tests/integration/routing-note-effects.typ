#import "../../src/lib.typ": *
#set page(width: 440pt, height: 280pt, margin: (left: 30pt, right: 95pt, y: 30pt))
#show: deixis-setup-notes
#let kind = sys.inputs.at("kind", default: "inset")
#let policy = sys.inputs.at("policy", default: "avoid")
#show: deixis-routing.with(policy: policy, weight: 0)
#let heads = state("note-effects-heads", ())
#let head(r) = (body: [#heads.update(xs => xs + (r.endpoint,))#circle(radius: 2pt)],
  trim: 2pt, bounds: (left: -2pt, top: -2pt, right: 2pt, bottom: 2pt))
#let paint(r) = {
  assert.eq(r.route.length, 200pt)
  assert.eq(r.cuts.len(), if policy == "manual" { 1 } else { 2 })
  assert.eq(r.crossings.hits.len(), 1)
  assert.eq(r.gaps.len(), if policy == "manual" { 2 } else { 3 })
  [#metadata(r.route.document.page)<note-effects-painted>]
  deixis-render-connector(r)
}
#let options = (route: "orthogonal", radius: 0pt,
  ports: (mark: (pin: <from>, side: right), body: (pin: <to>, side: left)),
  cuts: (at: 25%, length: 8pt), gap-marks: "slash", crossings: (mode: "gap", clearance: 0pt),
  heads: (mark: head, body: head), render: paint, z-index: 1)
#place(top + left, dx: 70pt, dy: 70pt, deixis-pin(<from>, padding: 0pt))
#place(top + left, dx: 270pt, dy: 70pt, deixis-pin(<to>, padding: 0pt))
#place(top + left, dx: 220pt, dy: 20pt, deixis-pin(<top>, padding: 0pt))
#place(top + left, dx: 220pt, dy: 120pt, deixis-pin(<bottom>, padding: 0pt))
#place(top + left, dx: 150pt, dy: 60pt,
  deixis-attach(behavior: "cut", rect(width: 20pt, height: 20pt, fill: luma(230))))
#deixis-routing(policy: "manual")[
  #deixis-connect(from: (pin: <top>), to: (pin: <bottom>), connector: (
    route: "polyline", z-index: 3, crossings: "gap"))
]
#deixis-mark(id: <note>)[Source]
#if kind == "margin" {
  deixis-margin-note-body(of: <note>, layer: "flow", width: 65pt, connector: options)[Body]
} else {
  deixis-inset-note-body(of: <note>, layer: "flow", width: 65pt, connector: options,
    placement: x => place(top + left, dx: 200pt, dy: 120pt, x))[Body]
}
#context {
  assert.eq(heads.final().sorted(), ("body", "mark"))
}
