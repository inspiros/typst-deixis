#import "../../src/lib.typ": *
#set page(width: 600pt, height: 800pt, margin: 35pt)
#set text(size: 9pt)
#show: deixis-setup-notes

// Independent copies of the documented values: do not import the private table.
#let palettes = (
  okabe-ito: "E69F00 56B4E9 009E73 0072B2 D55E00 CC79A7".split().map(rgb),
  tol-bright: "4477AA EE6677 228833 CCBB44 66CCEE AA3377".split().map(rgb),
  tol-muted: "CC6677 332288 DDCC77 117733 88CCEE 882255 44AA99 999933 AA4499".split().map(rgb),
  tableau: "1F77B4 FF7F0E 2CA02C D62728 9467BD 8C564B E377C2 7F7F7F BCBD22 17BECF".split().map(rgb),
  deixis: "3B6D9A 387C69 9A663F 7D5A87 397D86 A05268 73783E".split().map(rgb),
)

#for (name, colors) in palettes {
  heading(name, level: 1)
  // Run the same operations with both representations, swapping between them
  // mid-cycle. Equal values must still start fresh, independent cycles.
  for named in (true, false) {
    let value = if named { name } else { colors }
    let equivalent = if named { colors } else { name }
    let series = name + if named { "-named" } else { "-array" }
    let mark(tag) = deixis-mark(id: series + "-" + tag, series: series)[#tag] + [ ]
    deixis-set(palette: value)
    for i in range(colors.len() + 2) { mark(str(i)) }
    deixis-set(palette: value)
    mark("restart")
    deixis-set(palette: equivalent)
    mark("equivalent")
    deixis-block(inset: 2pt)[
      #mark("inherited")
      #deixis-set(palette: value)
      #mark("local-first")
      #mark("local-second")
      #deixis-block(inset: 2pt)[#mark("nested-inherited")]
      #deixis-set(palette: equivalent)
      #mark("local-restart")
    ]
    mark("restored")
    deixis-set(palette: auto)
    mark("auto")
    deixis-set(palette: none)
    mark("disabled")
    deixis-set(palette: value)
    mark("reenabled")
    parbreak()
  }
}

#context {
  let accents(series) = deixis-query-notes(series: series, include-unpaired: true).map(n => n.accent)
  [#metadata(palettes.keys().map(name => (
    name: name, named: accents(name + "-named"), array: accents(name + "-array"),
  )))<palette-names-query>]
}

#let verify() = {
  for record in query(<palette-names-query>).first().value {
    let name = record.name
    let colors = palettes.at(name)
    let expected = colors + colors.slice(0, 2) + (
      colors.at(0), colors.at(0), colors.at(1), colors.at(0), colors.at(1),
      colors.at(2), colors.at(0), colors.at(2), colors.at(3), none, colors.at(0),
    )
    assert.eq(record.named, expected, message: name + " documented order, wraparound and scope restoration")
    assert.eq(record.array, expected, message: name + " equivalent array")
    assert.eq(record.named, record.array)
  }
  true
}
// Direct compilation exercises the public query assertions too.
#context assert(verify())
