#import "../../src/lib.typ": *
#show: deixis-setup-notes
#let live = state("empty-ranges-live", ())
#let results = ()
#for mode in ("labels", "selectors", "locations", "pins", "scoped-pins") {
  let id(s) = label(mode + "-" + s)
  let boundary(s) = [#metadata(none)#id(s)#deixis-pin(str(id(s)))#deixis-pin(s, scope: mode)]
  boundary("lower")
  deixis-endnote(id: id("first"))[#live.update(xs => xs + (str(id("first")),))First body.]
  boundary("middle")
  deixis-endnote(id: id("second"))[#live.update(xs => xs + (str(id("second")),))Second body.]
  boundary("upper")
  context {
    let bound(s) = if mode == "locations" { query(id(s)).first().location() }
      else if mode == "selectors" { selector(id(s)) }
      else if mode == "pins" { str(id(s)) }
      else if mode == "scoped-pins" { (name: s, scope: mode) } else { id(s) }
    for (after, before) in ((bound("upper"), bound("lower")), (bound("middle"), bound("middle"))) {
      deixis-print-endnotes(after: after, before: before)
      deixis-note-outline(title: none, after: after, before: before,
        summary: _ => panic("Empty range must not execute an outline callback."))
      assert.eq(deixis-query-notes(after: after, before: before), ())
    }
    // A valid empty filter and an empty range claim no bodies from a later printer.
    deixis-print-endnotes(series: (), after: bound("lower"), before: bound("upper"))
  }
  [#metadata(mode)<empty-range-complete>]
  deixis-print-endnotes()
  for suffix in ("first", "second") { [#link(id(suffix))[Body] ] }
}
#let verify() = {
  let expected = ("labels", "selectors", "locations", "pins", "scoped-pins")
    .map(mode => (mode + "-first", mode + "-second")).flatten()
  assert.eq(live.final(), expected)
  assert.eq(query(<deixis-rendered-start>).len(), expected.len())
  assert.eq(query(<deixis-body-destination>).len(), expected.len())
  (destinations: query(<deixis-body-destination>).map(n => {
    let p = n.location().position()
    (page: p.page, x: p.x.pt(), y: p.y.pt())
  }))
}
