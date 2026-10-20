#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#import "../../src/core/references.typ": _deixis-reference-sites
#import "../../src/routing/frames.typ": _deixis-body-nodes
#set page(width: 550pt, height: 450pt, margin: 45pt)
#show: deixis-setup-notes
#let edges = sys.inputs.at("edges", default: "on") == "on"
#let ticks = state("explicit-inline-bodies", 0)
#let paints = state("explicit-inline-renderers", 0)
#let cases = ()
#let body = [#ticks.update(n => n + 1)One live body.]
#let fixed(data, ..args) = {
  paints.update(n => n + 1)
  box(width: 125pt, height: 40pt, deixis-native-render-single(data, ..args.named()))
}
#let painter(name, request) = {
  let doc = request.route.document
  assert.eq(request.heads.mark != none, not doc.is-incoming)
  assert.eq(request.heads.body != none, not doc.is-outgoing)
  [#metadata((name: name, document: doc))<inline-body-route>]
}
#let connect(from, to, name, layer) = if edges {
  deixis-connect(from: from, to: to, connector: (
    route: "curve", layer: layer, heads: (mark: "triangle", body: "circle"),
    ports: (mark: bottom, body: top), render: painter.with(name)))
}
#for inline in (false, true) {
  for standalone in (false, true) {
    if cases.len() > 0 { pagebreak() }
    let n = cases.len()
    let id = "inline-target-" + str(n)
    let source = "inline-source-" + str(n)
    let target = if standalone { id } else { source }
    let layer = if standalone { "background" } else { "foreground" }
    cases.push((id: target, width: auto, height: auto))
    // Both declarations precede every endpoint; repeats do not acquire edges.
    connect(source, target, "original-" + str(n), layer)
    connect((mark: source, occurrence: <again>), target, "repeat-" + str(n), layer)
    deixis-mark(id: source)[Original]
    v(20pt)
    if standalone { deixis-inline-note-body(id: id, inline: inline, breakable: false, backlink: true, body) }
    else { deixis-inline-note-body(of: source, inline: inline, breakable: false, backlink: true, body) }
    [After the body.]
    deixis-block(inset: 8pt)[#deixis-mark(of: source, occurrence: <again>)[Repeated passage]]
    [Native #link(label(target))[body link]; package #deixis-ref(label(target)).]
  }
}
#pagebreak()
// Custom renderer dimensions, enclosing transforms, and captured typography.
#for (i, transform) in (it => it, scale.with(x: 120%, y: 120%), rotate.with(20deg)).enumerate() {
  if i > 0 { pagebreak() }
  let id = "fixed-" + str(i)
  cases.push((id: id,
    width: if i == 0 { 125pt } else if i == 1 { 150pt } else { 125pt * calc.cos(20deg) + 40pt * calc.sin(20deg) },
    height: if i == 0 { 40pt } else if i == 1 { 48pt } else { 125pt * calc.sin(20deg) + 40pt * calc.cos(20deg) }))
  deixis-mark(id: id, mark-type: "phantom")
  transform(deixis-inline-note-body(of: id, inline: false, breakable: false, render-single: fixed, body))
  connect(id, id, id, "foreground")
  [Native #link(label(id))[body link].]
}
#pagebreak()
// Cross-page endpoints retain page ownership and endpoint-only continuation.
#deixis-mark(id: <forward>)[Forward source]
#deixis-inline-note-body(of: <backward>, breakable: false, inline: true, body)
#connect(<forward>, <forward>, "forward", "background")
#connect(<backward>, <backward>, "backward", "foreground")
#pagebreak()
No intermediate connection fragment.
#pagebreak()
#deixis-mark(id: <backward>, mark-type: "region", inline: true)[Backward source]
#deixis-inline-note-body(of: <forward>, breakable: false, body)
#for id in (<forward>, <backward>) { [Native #link(id)[body link].] }
#context {
  let nodes = _deixis-body-nodes()
  assert.eq(ticks.final(), 9)
  assert.eq(paints.final(), 3)
  assert.eq(query(<deixis-rendered-start>).len(), 9)
  assert.eq(query(<deixis-body-destination>).len(), 9)
  assert.eq(nodes.len(), 9)
  assert.eq(deixis-system.final().registry.value.counters.at("page").at("default"), 9)
  for case in cases {
    let frame = nodes.at("id-" + case.id)
    assert.eq(frame.len(), 1)
    let bounds = frame.first().bounds
    assert(bounds.right > bounds.left and bounds.bottom > bounds.top)
    if case.width != auto { assert(calc.abs(bounds.right - bounds.left - case.width) < 0.01pt) }
    if case.height != auto { assert(calc.abs(bounds.bottom - bounds.top - case.height) < 0.01pt) }
  }
  for n in range(4) {
    let uid = deixis-system.final().registry.value.id-index.at("inline-source-" + str(n))
    assert.eq(_deixis-reference-sites().at(uid).len(), if calc.odd(n) { 1 } else { 2 })
  }
  [#metadata((destinations: query(<deixis-body-destination>).map(b => {
    let pos = query(label(str(b.value.id))).first().location().position()
    (page: pos.page, x: pos.x.pt(), y: pos.y.pt())
  }), frames: nodes.values().flatten().map(n => (identity: n.identity, page: n.page, bounds: n.bounds)),
    positions: query(<deixis-rendered-start>).map(b => b.location().position())))<test-result>]
}
