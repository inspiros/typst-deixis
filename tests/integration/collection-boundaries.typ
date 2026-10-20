#import "../../src/lib.typ": *
#set page(width: 540pt, height: 650pt, margin: 45pt)
#show: deixis-setup-notes
#let ticks = state("collection-boundaries-live", 0)
#let expected = ()
#for (i, mode) in ("labels", "locations", "selectors", "pins", "scoped-pins", "forward-pin").enumerate() {
  if i > 0 { pagebreak() }
  let id(name) = label(mode + "-" + name)
  let body(name) = [#ticks.update(n => n + 1)#name body.]
  let boundary(edge) = {
    [#metadata(none)#id(edge)]
    deixis-pin(str(id(edge)))
    deixis-pin(edge, scope: mode)
  }
  let collect() = context {
    let bound(edge) = if mode == "locations" { query(id(edge)).first().location() }
      else if mode == "selectors" { selector(id(edge)) }
      else if mode in ("pins", "forward-pin") { str(id(edge)) }
      else if mode == "scoped-pins" { (name: label(edge), scope: label(mode)) }
      else { id(edge) }
    let after = bound("lower")
    let before = bound("upper")
    // An empty union claims nothing; duplicate filters still print each body once.
    deixis-print-endnotes(series: (), after: after, before: before)
    [#metadata(mode)<bounded-batch>]
    deixis-print-endnotes(series: ("notes", "notes"), after: after, before: before)
    [#metadata(mode)<bounded-end>]
    deixis-print-endnotes(series: "notes", after: after, before: before)
    deixis-note-outline(title: none, include-unpaired: true, include-types: "endnote",
      after: after, before: before, series: "notes", summary: note => [
        #metadata((mode: mode, id: note.id))<boundary-outline>Independent summary.
      ])
  }
  deixis-mark(id: id("outside"), series: "notes")[Original before interval]
  deixis-endnote-body(of: id("forward"), body("forward"))
  boundary("lower")
  deixis-endnote-body(of: id("outside"), body("outside"))
  deixis-mark(id: id("forward"), series: "notes")[Forward original inside]
  deixis-endnote(id: id("paired"), series: "notes", body("paired"))
  deixis-mark(id: id("late"), series: "notes")[Original inside, body later]
  deixis-mark(of: id("outside"))[Reuse inside the interval]
  deixis-endnote-body(id: id("standalone"), series: "notes", body("standalone"))
  if mode == "forward-pin" {
    collect()
    deixis-endnote(id: id("future"), series: "notes", body("future"))
  }
  boundary("upper")
  deixis-endnote-body(of: id("late"), body("late"))
  if mode != "forward-pin" { collect() }
  [#metadata(mode)<remaining-batch>]
  deixis-print-endnotes(series: "notes")
  [#metadata(mode)<remaining-end>]
  deixis-print-endnotes()
  // Explicit native links verify unnumbered bodies as well as attached bodies.
  let names = ("outside", "forward", "paired", "late", "standalone")
  if mode == "forward-pin" { names.push("future") }
  for name in names { [#link(id(name))[Body] ] }
  expected.push((mode: mode,
    printed: (id("outside"), id("paired"), id("standalone")) + if mode == "forward-pin" { (id("future"),) } else { () },
    remaining: (id("forward"), id("late")),
    outlined: (id("forward"), id("paired"), id("late"), id("standalone")) + if mode == "forward-pin" { (id("future"),) } else { () }))
}
#context {
  assert.eq(ticks.final(), 31)
  assert.eq(query(<deixis-rendered-start>).len(), 31)
  for e in expected {
    let after = query(<bounded-batch>).find(n => n.value == e.mode).location()
    let before = query(<bounded-end>).find(n => n.value == e.mode).location()
    assert.eq(query(selector(<deixis-rendered-start>).after(after).before(before)).map(n => n.value.id), e.printed)
    let after = query(<remaining-batch>).find(n => n.value == e.mode).location()
    let before = query(<remaining-end>).find(n => n.value == e.mode).location()
    assert.eq(query(selector(<deixis-rendered-start>).after(after).before(before)).map(n => n.value.id), e.remaining)
    assert.eq(query(<boundary-outline>).filter(n => n.value.mode == e.mode).map(n => n.value.id), e.outlined)
  }
  [#metadata((destinations: query(<deixis-body-destination>).map(body => {
    let pos = body.location().position()
    (page: pos.page, x: pos.x.pt(), y: pos.y.pt())
  })))<test-result>]
}
