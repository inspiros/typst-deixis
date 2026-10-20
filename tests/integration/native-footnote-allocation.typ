// Native controls: allocation depends on float scope, not merely on floating.
#set page(width: 440pt, height: 280pt, margin: 30pt)
#set text(size: 10pt)
#let live = state("native-allocation-live", ())
#let modes = ("column-float", "parent-float", "nonfloat", "placed", "box", "table",
  "before", "trailing", "alone")
#for marker in ("native", "empty", "weak") {
  for mode in modes {
    pagebreak(weak: true)
    let key = marker + "-" + mode
    let note() = {
      show footnote: it => if marker == "empty" { [] }
        else if marker == "weak" { h(0pt, weak: true) } else { it }
      footnote[#live.update(xs => xs + (key,))#metadata(key)<native-entry>Native entry.]
    }
    if mode == "column-float" { figure(placement: top)[Float#note().]; [Main flow.] }
    else if mode == "parent-float" { figure(placement: top, scope: "parent")[Float#note().]; [Main flow.] }
    else if mode == "nonfloat" { figure[Figure#note().] }
    else if mode == "placed" { place(top)[Placed#note().]; [Main flow.] }
    else if mode == "box" { box[Box#note().] }
    else if mode == "table" { table(columns: 1, [Cell#note().]) }
    else if mode == "before" { [#note()Following text.] }
    else if mode == "trailing" { [Trailing text#note()] }
    else { note() }
  }
}
#context {
  let expected = ()
  for marker in ("native", "empty", "weak") {
    for mode in modes {
      if mode != "parent-float" and not (marker == "empty" and mode in ("trailing", "alone")) {
        expected.push(marker + "-" + mode)
      }
    }
  }
  assert.eq(live.final().sorted(), expected.sorted())
  assert.eq(query(<native-entry>).map(m => m.value).sorted(), expected.sorted())
  assert.eq(query(footnote.entry).len(), expected.len())
  // Missing entries still advance the ordinary native source counter.
  assert.eq(counter(footnote).final(), (modes.len() * 3,))
}
