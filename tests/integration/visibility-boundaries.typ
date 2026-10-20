#import "../../src/lib.typ": *
#import "../../src/core/visibility.typ": _deixis-is-hidden
#set page(width: 480pt, height: 340pt, margin: (x: 70pt, y: 25pt))
#set text(size: 10pt)
#show: deixis-setup-notes
#let shape(name, ..args) = {
  let a = args.named()
  [#metadata(name)<boundary-visible-shape>]
  rect(width: a.width, height: a.height, stroke: blue, fill: none)
}

// The main-flow hide remains open at page 1's foreground and native footer.
// Neither independent output is inside that hide. Their nested regions must
// capture an uncovered context, while the actual covered passages stay covered.
#deixis-inset-note(id: <outer>, layer: "foreground", width: 140pt, dx: 80pt, dy: 40pt)[Outer][
  #deixis-region-mark(id: <in-overlay>, series: "nested", inline: true,
    layer: "foreground", region-shape: shape.with("overlay"))[VisibleOverlay]
]
Visible footnote#deixis-footnote(id: <foot>, layer: "flow") [
  #deixis-region-mark(id: <in-footer>, series: "nested", inline: true,
    layer: "foreground", region-shape: shape.with("footer"))[VisibleFooter]
].
#hide[
  #deixis-region-mark(id: <covered-first>, inline: true, layer: "foreground")[CoveredFirst]
  #pagebreak()
  #deixis-region-mark(id: <covered-second>, inline: true, layer: "foreground")[CoveredSecond]
]
Visible after the scope.

// A visible declaration printed inside hide keeps native flow execution, but
// its independently painted body-point connection must follow the hidden span.
#deixis-endnote-body(id: <hidden-printer>, series: "hidden-printer")[HiddenPrinterBody]
#hide[#deixis-print-endnotes(series: "hidden-printer")]
#deixis-pin("visible-source", padding: none)
#deixis-connect(from: (pin: "visible-source"), to: (body: <hidden-printer>, point: "start"),
  connector: (route: "straight-line", render: _ => panic("A hidden printer must not expose its connection.")))

#context {
  assert.eq(query(<boundary-visible-shape>).map(m => m.value).sorted(), ("footer", "overlay"))
  for r in query(<deixis-region-mark>) {
    let covered = r.value.id in (<covered-first>, <covered-second>)
    assert.eq(_deixis-is-hidden(r.value), covered, message: repr(r.value.id))
  }
  let printed = query(<deixis-body-visibility>).filter(m => m.value.internal-id == "id-hidden-printer")
  assert.eq(printed.len(), 1)
  assert(_deixis-is-hidden(printed.first().value))
}
