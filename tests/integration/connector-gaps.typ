#import "../../src/lib.typ": *
#set page(width: 460pt, height: 280pt, margin: (x: 95pt, y: 35pt))
#show: deixis-setup-notes
#let kind = sys.inputs.at("kind", default: "explicit")
#let layer = sys.inputs.at("layer", default: "foreground")
#let edge-layer = sys.inputs.at("edge-layer", default: "foreground")
#let shape = sys.inputs.at("shape", default: "slash")
#let enabled = sys.inputs.at("marks", default: "on") == "on"
#let inherited = sys.inputs.at("inherit", default: "off") == "on"
#let live = state("gap-body-live", 0)
#let gap-spec = if enabled { (shape: shape, size: 7pt, stroke: rgb("228855") + 0.8pt) } else { none }
#let paint(request) = {
  assert.eq(request.gap-marks != none, enabled)
  assert.eq(request.route.gaps.map(g => (g.start, g.end)), request.gaps.map(g => (g.start, g.end)))
  let doc = request.route.document
  let expected = if kind == "cross-page" and doc.is-incoming { 0 } else { 1 }
  assert.eq(request.gaps.len(), expected)
  if expected == 1 {
    let gap = request.gaps.first()
    assert.eq((gap.end.at(0) - gap.start.at(0), gap.end.at(1) - gap.start.at(1)), (24pt, 0pt))
  }
  [#metadata((gaps: request.gaps, shaft: request.shaft, page: doc.page,
    incoming: doc.is-incoming, outgoing: doc.is-outgoing))<gap-route>]
  deixis-render-connector(request)
}
#let options = (route: "curve", layer: edge-layer, heads: (mark: "circle", body: "triangle"),
  stroke: blue + 0.8pt, render: paint,
  via: ((relative-to: "mark", offset: (24pt, 0pt)), "none",
    (relative-to: "mark", offset: (48pt, 0pt)), "curve"), gap-marks: gap-spec)
#let options = if kind == "cross-page" { options + (via: options.via + ("split",)) } else { options }
#if inherited { deixis-set(connector: options) }
#let selected = if inherited { auto } else { options }
#let body = [#live.update(n => n + 1)One body.]
#{
  if kind == "explicit" {
    deixis-pin("source", padding: 0pt)
    place(top + left, dx: 200pt, dy: 90pt, deixis-pin("target", padding: 0pt))
    deixis-connect(from: (pin: "source"), to: (pin: "target"), connector: selected)
  } else if kind == "margin" {
    deixis-margin-note(id: <note>, layer: layer, side: right, width: 80pt,
      connector: selected)[Source][#body]
  } else if kind == "inset" {
    deixis-inset-note(id: <note>, layer: layer, dx: 155pt, dy: 70pt, width: 80pt,
      connector: selected)[Source][#body]
  } else {
    deixis-mark(id: <note>)[Source]
    pagebreak()
    deixis-inset-note-body(of: <note>, layer: layer, dx: 155pt, dy: 70pt, width: 80pt,
      connector: selected)[#body]
  }
}
Text. #if kind != "explicit" { link(<note>)[Body] }
#let verify() = {
  assert.eq(live.final(), if kind == "explicit" { 0 } else { 1 })
  let routes = query(<gap-route>).map(m => m.value)
  assert.eq(routes.len(), if kind == "cross-page" { 2 } else { 1 })
  if kind != "explicit" {
    assert.eq(query(<deixis-body-destination>).filter(m => m.value.id == <note>).len(), 1)
  }
  (routes: routes, destinations: if kind == "explicit" { () } else {
    let pos = query(<note>).first().location().position()
    ((page: pos.page, x: pos.x.pt(), y: pos.y.pt()),)
  })
}
