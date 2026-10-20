#import "../../src/lib.typ": *
#set page(width: 460pt, height: 280pt, margin: (x: 95pt, y: 35pt))
#show: deixis-setup-notes
#let kind = sys.inputs.at("kind", default: "explicit")
#let layer = sys.inputs.at("layer", default: "foreground")
#let edge-layer = sys.inputs.at("edge-layer", default: "foreground")
#let mode = sys.inputs.at("mode", default: "center")
#let enabled = sys.inputs.at("cuts", default: "on") == "on"
#let indicators = sys.inputs.at("indicators", default: "on") == "on"
#let inherited = sys.inputs.at("inherit", default: "off") == "on"
#let restore = sys.inputs.at("restore", default: "off") == "on"
#let live = state("cut-body-live", 0)
#let cuts = {
  if not enabled { none } else if mode == "center" { (at: 50%, length: 14pt) }
  else { ((from: 45%, to: 52%), (from: 50%, to: 55%)) }
}
#let paint(request) = {
  assert.eq(request.route.gaps, ())
  assert.eq(request.gaps.len(), if enabled { 1 } else { 0 })
  assert.eq(request.cuts.len(), if enabled { 1 } else { 0 })
  if enabled {
    let expected = if mode == "center" { 14pt } else { request.route.length * 10% }
    assert(calc.abs(request.cuts.first().to - request.cuts.first().from - expected) < 0.001pt)
  } else { assert.eq(request.shaft, request.uncut-shaft) }
  let doc = request.route.document
  [#metadata((gaps: request.gaps, shaft: request.shaft, uncut: request.uncut-shaft,
    cuts: request.cuts, geometry: (segments: request.route.segments, origin: request.route.origin,
      start: request.route.start, end: request.route.end, length: request.route.length),
    heads: (mark: if request.heads.mark == none { none } else { request.heads.mark.trim },
      body: if request.heads.body == none { none } else { request.heads.body.trim }),
    page: doc.page))<cut-route>]
  deixis-render-connector(request + if restore { (shaft: request.uncut-shaft) } else { (:) })
}
#let options = (route: "curve", layer: edge-layer, heads: (mark: "circle", body: "triangle"),
  stroke: blue + 0.8pt, render: paint, cuts: cuts,
  gap-marks: if indicators { (shape: "slash", size: 7pt, stroke: rgb("228855") + 0.8pt) } else { none },
  via: ((relative-to: "mark", offset: (40pt, 50pt)),
    (relative-to: "body", offset: (-40pt, 20pt))))
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
  let routes = query(<cut-route>).map(m => m.value)
  assert.eq(routes.len(), if kind == "cross-page" { 2 } else { 1 })
  if kind != "explicit" {
    assert.eq(query(<deixis-body-destination>).filter(m => m.value.id == <note>).len(), 1)
  }
  (routes: routes, destinations: if kind == "explicit" { () } else {
    let pos = query(<note>).first().location().position()
    ((page: pos.page, x: pos.x.pt(), y: pos.y.pt()),)
  })
}
