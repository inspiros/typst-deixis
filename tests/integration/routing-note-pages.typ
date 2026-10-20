#import "@preview/deixis:0.2.0": *
#set text(size: 11pt)
#set page(width: 500pt, height: 260pt, margin: (x: 110pt, y: 30pt))
#show: deixis-setup-notes
#let kind = sys.inputs.at("kind", default: "margin")
#let policy = sys.inputs.at("policy", default: "separate")
#let backwards = sys.inputs.at("direction", default: "forward") == "backward"
#let edge-layer = sys.inputs.at("edge", default: "foreground")
#show: deixis-routing.with(policy: policy)
#let live = state("note-page-bodies", 0)
#let heads = state("note-page-heads", ())
#let head(r) = (body: [#heads.update(xs => xs + (r.endpoint,))#circle(radius: 1.5pt)],
  trim: 1.5pt, bounds: (left: -1.5pt, right: 1.5pt, top: -1.5pt, bottom: 1.5pt))
#let paint(r) = {
  let d = r.route.document
  assert.eq(r.route.at("search", default: none) != none, policy != "manual")
  if d.continuation != none {
    assert.eq(d.fragment.status, "resolved")
    assert.eq(d.continuation.peer-page, if d.is-outgoing { d.target-page } else { d.source-page })
  }
  [#metadata((page: d.page, source: d.source-page, target: d.target-page,
    fragment: d.fragment.kind))<note-page-painted>]
  deixis-render-connector(r)
}
#let relay(r) = {
  assert.eq(r.status, "resolved")
  assert.eq(r.peer.page, r.peer-page)
  [#metadata((page: r.page, peer: r.peer-page))<note-page-relay>]
  circle(radius: 1.5pt)
}
#let options = (route: "orthogonal", radius: 0pt, layer: edge-layer,
  heads: (mark: head, body: head), render: paint, continuation: relay)
#let inset-body() = deixis-inset-note-body(of: <note>, width: 65pt, layer: "foreground",
  placement: x => place(top + left, dx: 100pt, dy: 70pt, x), connector: options)[#live.update(n => n + 1)Body]
#if kind == "margin" {
  for i in range(5) {
    deixis-margin-note(id: "note" + str(i), width: 85pt, connector: options,
      [Source #i], [#live.update(n => n + 1)#block(height: 85pt)[Body #i]])
  }
} else if backwards { inset-body() } else {
  place(top + left, dy: 60pt, deixis-mark(id: <note>)[Source])
}
First Page
#pagebreak()
Middle Page
#pagebreak()
#set page(width: 440pt, foreground: [Host Decoration])
#show: deixis-setup-notes
#if kind == "inset" {
  if backwards { place(top + left, dy: 60pt, deixis-mark(id: <note>)[Source]) } else { inset-body() }
}
Last Page
#context {
  assert.eq(live.final(), if kind == "margin" { 5 } else { 1 })
  let paints = query(<note-page-painted>).map(m => m.value)
  assert.eq(paints.len(), if kind == "margin" { 8 } else { 2 })
  assert.eq(heads.final().filter(x => x == "body").len(), if kind == "margin" { 5 } else { 1 })
  assert.eq(heads.final().filter(x => x == "mark").len(), if kind == "margin" { 5 } else { 1 })
  let relays = query(<note-page-relay>).map(m => m.value)
  assert.eq(relays.len(), if kind == "margin" { 6 } else { 2 })
  if kind == "inset" {
    assert.eq(paints.map(p => p.page).sorted(), (1, 3))
    assert(paints.all(p => p.source == (if backwards { 3 } else { 1 }) and p.target == (if backwards { 1 } else { 3 })))
  }
  let plans = query(<deixis-routing-plan>).map(m => m.value)
  assert.eq(plans.len(), if policy == "manual" { 0 } else if kind == "margin" { 3 } else { 2 })
  assert(plans.all(p => p.plan.routes.all(r => r.status == "ok")))
}
