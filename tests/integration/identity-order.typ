#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#import "../../src/core/references.typ": _deixis-reference-sites
#set page(width: 560pt, height: 400pt, margin: (x: 105pt, y: 40pt))
#show: deixis-setup-notes
#let ticks = state("identity-order-bodies", 0)
#let cases = ()
#let orders = (("original", "body", "reuse"), ("original", "reuse", "body"),
  ("body", "original", "reuse"), ("body", "reuse", "original"),
  ("reuse", "original", "body"), ("reuse", "body", "original"))
#let adapters = ("inline", "endnote-body", "endnote", "footnote-body", "footnote",
  "margin-body", "margin", "inset-body", "inset", "sidenote-body", "sidenote")
#let attach(kind, id, body) = {
  if kind == "inline" { deixis-inline-note-body(of: id, inline: true, body) }
  else if kind == "endnote-body" { deixis-endnote-body(of: id, body) }
  else if kind == "endnote" { deixis-endnote(of: id, body) }
  else if kind == "footnote-body" { deixis-footnote-body(of: id, body) }
  else if kind == "footnote" { deixis-footnote(of: id, body) }
  else if kind == "margin-body" { deixis-margin-note-body(of: id, width: 85pt, side: right, body) }
  else if kind == "margin" { deixis-margin-note(of: id, width: 85pt, side: right, body) }
  else if kind == "inset-body" {
    deixis-inset-note-body(of: id, layer: "background", width: 120pt, dx: 120pt, dy: 85pt, body)
  } else if kind == "inset" {
    deixis-inset-note(of: id, layer: "foreground", width: 120pt, dx: 120pt, dy: 85pt, body)
  } else if kind == "sidenote-body" { deixis-sidenote-body(of: id, width: 85pt, side: right, body) }
  else { deixis-sidenote(of: id, width: 85pt, side: right, body) }
}
#for original-kind in ("inline", "region", "phantom") {
  for (index, order) in orders.enumerate() {
    if cases.len() > 0 { pagebreak() }
    let id = "order-" + original-kind + "-" + str(index)
    let adapter = adapters.at(calc.rem(cases.len(), adapters.len()))
    cases.push((id: id, order: order, adapter: adapter))
    for operation in order {
      if operation == "original" {
        if original-kind == "region" {
          deixis-mark(id: id, mark-type: "region", inline: true, layer: "background", series: "order")[Original region]
        } else if original-kind == "phantom" {
          deixis-mark(id: id, mark-type: "phantom", series: "order")
          [Original point.]
        } else { deixis-mark(id: id, series: "order")[Original inline] }
      } else if operation == "body" {
        attach(adapter, label(id), [#ticks.update(n => n + 1)One body.])
        [Visible footer anchor.]
      } else {
        // Every form must resolve a later original, including across a scope.
        deixis-block(inset: 3pt)[
          #deixis-mark(of: label(id), occurrence: <inline>)[Reused inline]
          #deixis-mark(of: label(id), mark-type: "region", inline: true, layer: "background", occurrence: <region>)[Reused region]
          #deixis-mark(of: label(id), mark-type: "phantom", occurrence: <phantom>)
          #context assert.eq(deixis-note-counter(), 0)
        ]
      }
    }
    deixis-print-endnotes()
    [Native #link(label(id))[body link]. Reference #deixis-ref(label(id)).]
  }
}
#context {
  let registry = deixis-system.final()
  let sites = _deixis-reference-sites()
  assert.eq(cases.len(), 18)
  assert.eq(registry.registry.value.notes.len(), 18)
  assert.eq(registry.registry.value.counters.at("page").at("order"), 18)
  assert.eq(registry.registry.value.pending-bodies.len(), 0)
  assert.eq(ticks.final(), 18)
  assert.eq(query(<deixis-rendered-start>).len(), 18)
  assert.eq(query(<deixis-mark-occurrence>).len(), 54)
  let destinations = ()
  for (i, case) in cases.enumerate() {
    let uid = registry.registry.value.id-index.at(case.id)
    assert.eq(registry.registry.value.notes.at(uid).count, i + 1)
    assert.eq(sites.at(uid).len(), 4)
    let body = query(label(case.id))
    assert.eq(body.len(), 1)
    assert.eq(body.first().value.count, i + 1)
    let pos = body.first().location().position()
    assert.eq(pos.page, i + 1)
    destinations.push((page: pos.page, x: pos.x.pt(), y: pos.y.pt()))
  }
  [#metadata((destinations: destinations))<test-result>]
}
