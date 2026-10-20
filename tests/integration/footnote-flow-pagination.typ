#import "../../src/lib.typ": *
#set page(width: 420pt, height: 300pt, margin: 32pt, numbering: "1",
  header: context [#metadata((page: here().page(),
    ids: deixis-query-notes(page: here().page(), include-types: "footnote").map(n => n.id)))<flow-footer-page>])
#set text(size: 11pt)
#show: deixis-setup-notes
#let mode = sys.inputs.at("mode", default: "paragraphs")
#let tokens = state("footnote-flow-tokens", ())
#let emit(i) = {
  let token = "FN" + str(101 + i)
  tokens.update(xs => xs + (token,))
  [#metadata(token)<flow-footer-chunk>#token #lorem(23)]
}
#let long-body = {
  if mode == "table" {
    table(columns: (auto, 1fr), inset: 3pt,
      table.header([Row], [Explanation]),
      ..range(12).map(i => (str(i + 1), emit(i))).flatten())
  } else if mode == "lists" {
    list(..range(12).map(emit))
  } else {
    for i in range(12) {
      emit(i)
      if mode == "single-paragraph" { [ ] } else { parbreak() }
    }
  }
}
#let long-body = [#long-body ENDLONG#metadata(none)<flow-footer-end>]
#let custom(data, ..args) = {
  deixis-generate-body-marker(data)
  deixis-generate-body-content(data)
  deixis-generate-backlinks(data)
}
#let declare() = {
  let options = (layer: "flow", backlink: true,
    render-single: if mode == "native-renderer" { deixis-native-render-single }
      else if mode == "custom-renderer" { custom } else { auto },
    container-func: if mode == "border" { block } else { auto },
    container-args: if mode == "border" { (breakable: true, inset: 5pt) } else { (:) },
    stroke: if mode == "border" { rgb("32736D") } else { auto })
  if mode == "native" { [A passage#std.footnote(long-body)] }
  else if mode == "standalone" { deixis-footnote-body(id: <long>, ..options, long-body) }
  else if mode == "shared" {
    deixis-footnote-body(of: <long>, ..options, long-body)
    [Forward #deixis-mark(of: <long>, occurrence: <early>)[reuse]. ]
    [Original #deixis-mark(id: <long>)[passage]. ]
  } else { [A passage#deixis-footnote(id: <long>, ..options, long-body)] }
}
#let main = [
  Before The Long Footnote.
  #declare()
  Continues After The Marker.
  #if mode == "mixed" {
    [Native#footnote[Native One.]. ]
    [Neighbor#deixis-footnote(id: <overlay>, layer: "foreground")[An overlay neighbor.]. ]
    [Background#deixis-footnote(id: <background>, layer: "background")[A background neighbor.]. ]
  }
  #for i in range(8) { [Main paragraph #i. #lorem(15)] ; parbreak() }
  A second passage#if mode == "native" { std.footnote[A Short Flow Note.] } else { deixis-footnote(layer: "flow", id: <short>)[A Short Flow Note.] }
  #if mode == "mixed" { [Native#footnote[Native Two.].] }
]
#if mode == "columns" { columns(2, gutter: 20pt, main) } else { main }

// Evaluate after layout; do not add observer-driven geometry to live bodies.
#context [#metadata((notes: deixis-query-notes(include-unpaired: true),
  native-count: counter(footnote).final()))<flow-footer-catalogue>]
#let verify() = {
  let expected = range(12).map(i => "FN" + str(101 + i))
  assert.eq(tokens.final(), expected)
  if mode == "native" {
    let start = query(<flow-footer-chunk>).first().location().page()
    let end = query(<flow-footer-end>).first().location().page()
    assert(end > start)
    assert.eq(query(<flow-footer-catalogue>).first().value.native-count, (2,))
    return (mode: mode, expected: expected, start: start, end: end, destinations: ())
  }
  let record = query(<flow-footer-catalogue>).first().value
  let notes = record.notes
  let n = notes.find(n => n.id == <long>)
  assert(n.body.dest != none and n.body.start != none and n.body.end != none)
  assert(n.body.end.page() >= n.body.start.page() + 1)
  assert.eq(n.marks.len(), if mode == "standalone" { 0 } else if mode == "shared" { 2 } else { 1 })
  let pages = query(<flow-footer-page>).map(m => m.value)
  assert.eq(pages.filter(p => <long> in p.ids).map(p => p.page).dedup().sorted(),
    range(n.body.start.page(), n.body.end.page() + 1))
  let entries = query(<deixis-footnote-entry>)
  assert.eq(entries.len(), if mode == "mixed" { 4 } else { 2 })
  assert.eq(query(<deixis-reserver-left>).len(), if mode == "mixed" { 2 } else { 0 })
  assert.eq(record.native-count, (if mode == "mixed" { 2 } else { 0 },))
  for chunk in query(<flow-footer-chunk>) {
    let p = chunk.location().position()
    assert(p.y >= 31pt and p.y <= 269pt)
    assert(p.x >= 31pt and p.x <= 389pt)
  }
  (mode: mode, expected: expected, start: n.body.start.page(), end: n.body.end.page(),
    destinations: notes.filter(n => n.body.dest != none and n.marks.len() > 0).map(n => {
      let p = n.body.dest.position()
      (page: p.page, x: p.x.pt(), y: p.y.pt())
    }))
}
