#import "../../src/lib.typ": *
#set page(width: 410pt, height: 280pt, margin: 32pt,
  header: context [#metadata((page: here().page(), labels: deixis-query-notes(page: here().page(), include-types: "endnote").map(n=>n.id)))<group-page>])
#show: deixis-setup-notes
#let ticks = state("paginated-groups", 0)
#let column-group(notes, ..args) = columns(2, gutter: 16pt, deixis-native-render-group(notes, ..args.named()))
#for (index, (name, renderer)) in (
  ("native", deixis-native-render-group), ("aligned", deixis-default-render-group),
  ("grid", deixis-grid-render-group), ("columns", column-group),
).enumerate() {
  if index > 0 { pagebreak() }
  [Long#deixis-endnote(series: name, id: label(name + "-long"))[
    #ticks.update(n => n + 1)
    #for i in range(14) { [Paragraph #i. #lorem(19)] ; parbreak() }
  ]]
  [Short#deixis-endnote(series: name, id: label(name + "-short"))[#ticks.update(n => n + 1)Last body.]]
  deixis-print-endnotes(series: name, render-group: renderer)
  deixis-print-endnotes(series: name, render-group: renderer)
}
#context {
  assert.eq(ticks.final(), 8)
  let starts = query(<deixis-rendered-start>)
  let ends = query(<deixis-rendered-end>)
  assert.eq(starts.len(), 8)
  assert.eq(ends.len(), 8)
  let pages = query(<group-page>).map(p=>p.value)
  for name in ("native", "aligned", "grid", "columns") {
    let lbl = label(name + "-long")
    let start = starts.find(n=>n.value.id == lbl).location().page()
    let end = ends.find(n=>n.value.id == lbl).location().page()
    assert(end > start)
    for p in range(start, end + 1) {
      assert(lbl in pages.find(info=>info.page == p).labels)
    }
    assert.eq(query(lbl).len(), 1)
  }
}
