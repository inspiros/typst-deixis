#import "../../src/lib.typ": *
#set page(width: 560pt, height: 460pt, margin: (x: 110pt, y: 40pt))
#show: deixis-setup-notes
#deixis-set(fill: (margin-note: (body: teal.lighten(90%))), mark-align-strictness: "strict")
#let live = state("sidenote-preset-bodies", 0)
#let cases = ()
#for (i, layer) in ("flow", "background", "foreground").enumerate() {
  if i > 0 { pagebreak() }
  for (j, form) in ("wrapper", "attached", "standalone").enumerate() {
    let id = layer + "-" + form
    let args = (layer: layer, width: 85pt)
    let body = [#live.update(n => n + 1)Sidenote body.]
    if form == "wrapper" { deixis-sidenote(id: id, ..args, body) }
    else if form == "attached" {
      deixis-mark(id: id)[Original]
      // Auto deliberately releases the preset's loose value to the cascade.
      deixis-sidenote(of: id, ..args, mark-align-strictness: auto, body)
    } else { deixis-sidenote-body(id: id, ..args, side: left, mark-align-strictness: "none", body) }
    [Following native anchor.]
    v(30pt)
    cases.push((id: id, form: form, layer: layer))
  }
}
#deixis-margin-note(id: <control>, width: 85pt)[#live.update(n => n + 1)Ordinary margin control.]
#context {
  assert.eq(live.final(), 10)
  let notes = deixis-query-notes(include-unpaired: true)
  assert.eq(notes.len(), 10)
  assert.eq(deixis-query-notes(include-types: "sidenote", include-unpaired: true), ())
  for c in cases {
    let n = notes.find(n => str(n.id) == c.id)
    assert.eq(n.type, "margin-note")
    assert.eq(n.styles.fill, teal.lighten(90%))
    let record = query(<deixis-margin-note>).find(m => str(m.value.id) == c.id).value
    assert.eq(record.layer, c.layer)
    assert.eq(record.side, if c.form == "standalone" { left } else { "outside" })
    assert.eq(record.mark-align-strictness, if c.form == "wrapper" { "loose" } else if c.form == "attached" { "strict" } else { "none" })
  }
  let control = query(<deixis-margin-note>).find(m => m.value.id == <control>).value
  assert.eq(control.mark-align-strictness, "strict")
  assert.eq(control.styles.fill, teal.lighten(90%))
}
