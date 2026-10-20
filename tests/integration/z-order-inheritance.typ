#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#let live = state("z-inheritance-live", 0)
#set page(width: 500pt, height: 340pt, margin: (x: 100pt, y: 40pt))
#show: deixis-setup-notes
#let expected = ()
#for (index, order) in ("mbr", "mrb", "bmr", "brm", "rmb", "rbm").enumerate() {
  for kind in ("inline", "endnote", "footnote", "margin", "inset") {
    if expected.len() > 0 { pagebreak() }
    let id = order + "-" + kind
    let form = ("inline", "region", "phantom").at(calc.rem(index, 3))
    let override = calc.odd(index)
    let original() = {
      let options = (id: id, mark-type: form, z-index: (mark: -2, body: 3, connector: 4))
      if form == "phantom" { deixis-mark(..options) }
      else if form == "region" { deixis-mark(..options, inline: true, layer: "foreground")[Original region] }
      else { deixis-mark(..options)[Original inline] }
    }
    let repeated() = deixis-mark(of: id, mark-type: "region", occurrence: "again",
      inline: true, layer: "foreground", z-index: if index == 0 { 8 } else { auto },
    )[Reused region]
    let body() = {
      let options = (of: id, z-index: if override { (body: 1, connector: 5) } else { auto })
      let content = [#live.update(n => n + 1)One live body.]
      if kind == "inline" { deixis-inline-note-body(..options, inline: false, content) }
      else if kind == "endnote" { deixis-endnote-body(..options, content) }
      else if kind == "footnote" { [Footnote#deixis-footnote-body(..options, content).] }
      else {
        let call = if kind == "margin" { deixis-margin-note-body } else { deixis-inset-note-body }
        call(..options, layer: "foreground", width: 80pt,
          connector: (route: "straight-line", z-index: if index == 5 { 7 } else { auto }),
          content)
      }
    }
    for action in order {
      if action == "m" { original() }
      else if action == "b" { body() }
      else { repeated() }
      [ Following text. ]
    }
    deixis-print-endnotes()
    expected.push((id: id, body: if override { 1 } else { 3 },
      mark: if index == 0 { 8 } else { -2 },
      connector: if index == 5 { 7 } else if override { 5 } else { 4 }))
  }
}
#for (index, kind) in ("footnote", "endnote", "margin", "inset", "sidenote").enumerate() {
  pagebreak()
  let id = "wrapper-" + kind
  let call = (footnote: deixis-footnote, endnote: deixis-endnote,
    margin: deixis-margin-note, inset: deixis-inset-note, sidenote: deixis-sidenote).at(kind)
  let form = ("inline", "region", "phantom").at(calc.rem(index, 3))
  let content = [#live.update(n => n + 1)Wrapper body.]
  if form == "region" { [Wrapper#call(id: id, mark-type: form, z-index: 6)[Passage][#content].] }
  else { [Wrapper#call(id: id, mark-type: form, z-index: 6)[#content].] }
  deixis-print-endnotes()
  expected.push((id: id, body: 6, mark: none, connector: 6))
}
#pagebreak()
#deixis-block(id: "ordering-scope")[
  #deixis-set(z-index: (inset-note: (nodes: 9, connector: -2)))
  #deixis-inset-note(id: "configured-a", layer: "foreground", width: 70pt, dx: 80pt,
    connector: (route: "straight-line"))[A][#live.update(n => n + 1)Configured A.]
  #deixis-set(z-index: (inset-note: (body: 10)))
  #deixis-inset-note(id: "configured-b", layer: "foreground", width: 70pt, dx: 170pt,
    connector: (route: "straight-line"))[B][#live.update(n => n + 1)Configured B.]
]
#deixis-inset-note(id: "outside", layer: "foreground", width: 70pt, dx: 80pt,
  connector: (route: "straight-line"))[Outside][#live.update(n => n + 1)Outside scope.]
#pagebreak()
#deixis-mark(id: "scalar-original", z-index: 6)[Scalar original]
#deixis-inset-note-body(of: "scalar-original", layer: "foreground", z-index: (body: 2),
  width: 80pt, dx: 80pt, connector: (route: "straight-line"),
)[#live.update(n => n + 1)Only the body priority is overridden.]
#for (id, body, link) in (("configured-a", 9, -2), ("configured-b", 10, -2),
  ("outside", 0, 0), ("scalar-original", 2, 6)) {
  expected.push((id: id, body: body, mark: none, connector: link))
}
#context {
  assert.eq(expected.len(), 39)
  assert.eq(live.final(), 39)
  assert.eq(query(<deixis-rendered-start>).len(), 39)
  let bodies = query(selector(<deixis-inline-note>).or(<deixis-endnote>).or(<deixis-footnote>)
    .or(<deixis-margin-note>).or(<deixis-inset-note>)).map(m => m.value)
  let regions = query(<deixis-region-occurrence>).map(m => m.value)
  let registry = deixis-system.final()
  for e in expected {
    let body = bodies.find(b => str(b.id) == e.id)
    assert.eq(body.z-index, e.body)
    assert("z-index" not in body.styles)
    if "link-z-index" in body { assert.eq(body.link-z-index, e.connector) }
    if e.mark != none {
      assert.eq(regions.find(r => r.occurrence-target == e.id).z-index, e.mark)
      assert.eq(registry.registry.value.notes.at("id-" + e.id).mark-z-index, -2)
    }
  }
}
