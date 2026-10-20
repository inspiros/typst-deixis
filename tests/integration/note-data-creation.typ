#import "../../src/lib.typ": *
#set page(width: 560pt, height: 450pt, margin: (x: 110pt, y: 40pt))
#show: deixis-setup-notes
#let live = state("note-data-creation-live", 0)
#let expected = ()
#for (i, kind) in ("footnote", "endnote", "margin", "inset", "sidenote").enumerate() {
  for (j, mark-type) in ("inline", "region", "phantom").enumerate() {
    if i > 0 or j > 0 { pagebreak() }
    let id = label(kind + "-" + mark-type)
    let data = (title: kind + " " + mark-type, tags: ("wrapper",))
    let render(n, ..args) = { assert.eq(n.data, data); deixis-native-render-single(n, ..args) }
    let args = (id: id, data: data, mark-type: mark-type, render-single: render)
    let body = [#live.update(n => n + 1)Wrapper explanation.]
    let passage = if mark-type == "phantom" { () } else { ([Marked passage],) }
    if kind == "footnote" { deixis-footnote(..args, ..passage, body) }
    else if kind == "endnote" { deixis-endnote(..args, ..passage, body) }
    else if kind == "margin" { deixis-margin-note(..args, width: 80pt, side: right, ..passage, body) }
    else if kind == "sidenote" { deixis-sidenote(..args, width: 80pt, side: right, ..passage, body) }
    else { deixis-inset-note(..args, layer: "foreground", width: 90pt, dy: 65pt, ..passage, body) }
    [Following text.]
    deixis-print-endnotes()
    expected.push((id: id, data: data))
  }
}
#for (i, kind) in ("inline", "footnote", "endnote", "margin", "inset", "sidenote").enumerate() {
  for named in (false, true) {
    pagebreak()
    let id = if named { label("standalone-" + kind) } else { none }
    let data = (title: kind, named: named, tags: ("standalone",))
    let render(n, ..args) = { assert.eq(n.data, data); deixis-native-render-single(n, ..args) }
    let args = (id: id, data: data, render-single: render)
    let body = [#live.update(n => n + 1)Standalone explanation.]
    if kind == "inline" { deixis-inline-note-body(..args, body) }
    else if kind == "footnote" { deixis-footnote-body(..args, body) }
    else if kind == "endnote" { deixis-endnote-body(..args, body) }
    else if kind == "margin" { deixis-margin-note-body(..args, width: 80pt, side: right, body) }
    else if kind == "sidenote" { deixis-sidenote-body(..args, width: 80pt, side: right, body) }
    else { deixis-inset-note-body(..args, layer: "foreground", width: 90pt, dy: 65pt, body) }
    [Following text.]
    deixis-print-endnotes()
    expected.push((id: id, data: data))
  }
}
// Private wrapper identities still own annotation data without a public id.
#pagebreak()
#deixis-endnote(data: (title: "private",))[#live.update(n => n + 1)Private explanation.]
#deixis-print-endnotes()
#context {
  let notes = deixis-query-notes(include-unpaired: true)
  assert.eq(notes.len(), 28)
  for e in expected { assert(notes.any(n => n.id == e.id and n.data == e.data)) }
  assert.eq(notes.find(n => n.data.title == "private").id, none)
  assert.eq(notes.filter(n => "standalone" in n.data.at("tags", default: ())).len(), 12)
  for n in notes { assert(n.body.dest != none and n.body.start != none and n.body.end != none) }
  assert.eq(live.final(), 28)
}
