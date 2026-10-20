#import "../../src/lib.typ": *
#import "../../src/render/summary.typ": _deixis-summary-text
#set page(width: 560pt, height: 450pt, margin: (x: 110pt, y: 40pt))
#show: deixis-setup-notes
#let live = state("note-data-live", 0)
#let dormant = state("note-data-dormant", 0)
#let orders = (("mark", "body", "reuse"), ("mark", "reuse", "body"),
  ("body", "mark", "reuse"), ("body", "reuse", "mark"),
  ("reuse", "mark", "body"), ("reuse", "body", "mark"))
#let expected = ()
#for (i, kind) in ("inline-note", "footnote", "endnote", "margin-note", "inset-note").enumerate() {
  for (j, order) in orders.enumerate() {
    if i > 0 or j > 0 { pagebreak() }
    let id = label(kind + "-" + str(j))
    let data = (title: [Title #str(j)], tags: ("review", kind), status: "open",
      id: "custom-id", count: 999, body: "custom-body", loc: "custom-location", marks: "custom-marks")
    let render(n, ..args) = {
      assert.eq(n.data, data)
      deixis-native-render-single(n, ..args)
    }
    let body = [#live.update(n => n + 1)One real explanation.]
    let emit-body() = {
      let args = (of: id, render-single: render)
      if kind == "inline-note" { deixis-inline-note-body(..args, body) }
      else if kind == "footnote" { deixis-footnote-body(..args, body) }
      else if kind == "endnote" { deixis-endnote-body(..args, body) }
      else if kind == "margin-note" { deixis-margin-note-body(..args, width: 80pt, side: right, body) }
      else { deixis-inset-note-body(..args, layer: "foreground", width: 90pt, dy: 75pt, body) }
    }
    for step in order {
      if step == "mark" {
        if calc.rem(j, 3) == 0 { deixis-inline-mark(id: id, data: data)[Original passage] }
        else if calc.rem(j, 3) == 1 { deixis-region-mark(id: id, data: data, inline: true)[Original region] }
        else { deixis-phantom-mark(id: id, data: data) }
      } else if step == "body" { emit-body() }
      else { deixis-mark(of: id, occurrence: <again>)[Reused passage] }
    }
    [Following text.]
    deixis-print-endnotes()
    context {
      let page-body = deixis-query-notes(page: here().page()).find(n => n.id == id)
      assert(page-body != none)
      assert.eq(page-body.data, data)
    }
    // Both view callbacks see the same immutable annotation data.
    deixis-note-outline(title: none, after: none, include-types: kind,
      summary: n => { assert.eq(n.data.at("status", default: "open"), "open"); n.summary },
      group-by: n => n.data.at("status", default: "open"))
    expected.push((id: id, type: kind, data: data))
  }
}

// Opaque user data must not be visited for declarations, summaries, or painting.
#pagebreak()
#let opaque = (
  title: [#dormant.update(n => n + 1)A contextual title],
  nested: [#deixis-endnote(id: <data-is-not-a-note>)[Never registered.]],
  callback: () => panic("Data callbacks must not be called by a query."),
)
#deixis-mark(id: <opaque>, data: opaque)[Opaque-data original]
#deixis-endnote-body(of: <opaque>)[#live.update(n => n + 1)Safe explanation.]
#deixis-mark(of: <opaque>, mark-type: "region", inline: true)[Reused region]
#deixis-mark(of: <opaque>, mark-type: "phantom")
#deixis-mark(data: (title: "anonymous",))[Anonymous inline decoration]
#deixis-mark(mark-type: "region", inline: true, data: (title: "anonymous-region",))[Anonymous region]
#deixis-mark(id: <empty>)[Default empty data]
#deixis-print-endnotes()
#deixis-note-outline(title: none)
#context {
  let notes = deixis-query-notes(include-unpaired: true)
  assert.eq(notes.len(), 34)
  for e in expected {
    let n = notes.find(n => n.id == e.id)
    assert.eq(n.data, e.data)
    assert.eq(n.id, e.id)
    assert.eq(n.type, e.type)
    assert(n.count != 999 and n.body != none and type(n.loc) == location)
    assert.eq(n.marks.len(), 2)
    assert(n.body.dest != none)
  }
  let n = notes.find(n => n.id == <opaque>)
  assert.eq(n.data, opaque)
  assert.eq(n.marks.len(), 3)
  assert.eq(_deixis-summary-text(n.summary), "Safe explanation.")
  assert.eq(notes.find(n => n.id == <empty>).data, (:))
  assert.eq(notes.filter(n => n.id == none).map(n => n.data.title), ("anonymous", "anonymous-region"))
  assert.eq(dormant.final(), 0)
  assert.eq(live.final(), 31)
  assert.eq(query(<deixis-endnote>).filter(n => n.value.id == <data-is-not-a-note>).len(), 0)
  assert.eq(deixis-query-notes().filter(n => "review" in n.data.at("tags", default: ())).len(), 30)
}
