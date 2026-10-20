#import "../../src/lib.typ": *
#set page(width: 460pt, height: 390pt, margin: 35pt)
#show: deixis-setup-notes
#let ticks = state("group-policy-bodies", 0)
#let check(data, ..args) = {
  assert.eq(text.size, if str(data.id).ends-with("a") { 18pt } else { 10pt })
  assert.eq(par.leading, 8pt)
  deixis-default-render-single(data, ..args.named())
}
#let group(name, notes, ..args) = {
  [#metadata((name: name, labels: notes.map(n => n.id)))<group-policy>]
  deixis-native-render-group(notes, ..args.named())
}
#let styles = (("native", group.with("native")), ("aligned", deixis-default-render-group), ("grid", deixis-grid-render-group))
#for (index, (name, renderer)) in styles.enumerate() {
  if index > 0 { pagebreak() }
  for (suffix, size, gap) in (("a", 18pt, 6pt), ("b", 10pt, 22pt)) {
    set text(size: size, fill: if suffix == "a" { blue } else { green })
    set par(leading: 8pt)
    deixis-set(render-group: renderer, gap: gap)
    [Mark#deixis-endnote(series: name, id: label(name + suffix), render-single: check)[
      #context {
        assert.eq(text.size, size)
        ticks.update(n => n + 1)
      }
      Styled body.
    ]]
  }
  deixis-print-endnotes(series: name)
}
#pagebreak()
// Each series retains its own group policy; non-adjacent members are collected
// in source order. A printer override deliberately replaces both policies.
#deixis-set(render-group: group.with("A"))
A#deixis-endnote(series: "A", id: <Aa>)[A first.]
#deixis-set(render-group: group.with("B"))
B#deixis-endnote(series: "B", id: <Ba>)[B first.]
#deixis-set(render-group: group.with("A"))
A#deixis-endnote(series: "A", id: <Ab>)[A second.]
#deixis-print-endnotes(series: ("A", "B"))
A#deixis-endnote(series: "A", id: <overrideA>)[Override A.]
B#deixis-endnote(series: "B", id: <overrideB>)[Override B.]
#deixis-print-endnotes(render-group: group.with("override"))
#context {
  assert.eq(ticks.final(), 6)
  let policies = query(<group-policy>).map(n => n.value)
  assert.eq(policies, (
    (name: "native", labels: (<nativea>, <nativeb>)),
    (name: "A", labels: (<Aa>, <Ab>)), (name: "B", labels: (<Ba>,)),
    (name: "override", labels: (<overrideA>,)), (name: "override", labels: (<overrideB>,)),
  ))
  let starts = query(<deixis-rendered-start>)
  let ends = query(<deixis-rendered-end>)
  assert.eq(starts.len(), 11)
  for (name, _) in styles {
    let end = ends.find(n => n.value.id == label(name + "a")).location().position().y
    let start = starts.find(n => n.value.id == label(name + "b")).location().position().y
    // Rendered-span probes are on the body baselines. The group's actual gap
    // still needs to be at least the 22pt requested by its incoming second note.
    assert(start - end >= 22pt)
  }
}
