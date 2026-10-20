#import "../../src/lib.typ": *
#set text(size: 10pt)
#set page(width: 430pt, height: 320pt, margin: 40pt,
  header: context [#metadata((page: here().page(), labels: deixis-query-notes(page: here().page(), include-types: "endnote").map(n => n.id)))<endnote-pages>],
)
#show: deixis-setup-notes

#let batch(name, ..options) = {
  [#metadata(name)<endnote-batch-start>]
  deixis-print-endnotes(..options.named())
  [#metadata(name)<endnote-batch-end>]
}

// Filtering follows body declarations, which can precede their marks.
#deixis-endnote-body(of: <forward-mark>)[Forward body.]
#deixis-pin("chapter-start")
Alpha#deixis-endnote(series: "alpha", id: <alpha-body>)[Alpha body.]
Beta#deixis-endnote(series: "beta", id: <beta-body>)[Beta body.]
#deixis-endnote-body(series: "beta", id: <standalone-body>)[Standalone body.]
#deixis-pin("chapter-end")
#metadata(none)<endnote-boundary>

#batch("alpha", series: "alpha", after: "chapter-start", before: "chapter-end", marker-style: it => text("A" + str(it)))
#batch("beta", series: ("beta",), after: "chapter-start", before: "chapter-end")
#batch("overlap", series: ("alpha", "beta"), after: "chapter-start", before: "chapter-end")
#batch("overlap-by-label", series: "beta", before: <endnote-boundary>)
#context batch("overlap-by-location", series: "alpha",
  after: query(<deixis-pin>).find(n => n.value.name == "chapter-start").location(), before: <endnote-boundary>)

Later#deixis-endnote(series: "alpha", id: <later-body>)[Later body.]
#deixis-inline-mark(id: <forward-mark>, series: "alpha")[Forward mark]
#deixis-block(id: <scoped>)[
  Scoped#deixis-endnote(series: "alpha", id: <scoped-body>)[Scoped body.]
]
#batch("remaining", series: ("alpha", "beta"))
#batch("scoped", target: <scoped>, series: "alpha")
#batch("scoped-again", target: <scoped>)
#batch("page-again")
References: @alpha-body, @forward-mark, @scoped-body.

#pagebreak()
Long#deixis-endnote(series: "long", id: <long-body>)[Long-start. #lorem(650) Long-end.]
#batch("long", series: "long", render-single: deixis-default-render-single,
  render-group: deixis-default-render-group, body-style: it => text(size: 10pt, it))
#batch("long-again", series: "long")

#context {
  let expected = (
    alpha: (<alpha-body>,), beta: (<beta-body>, <standalone-body>), overlap: (),
    overlap-by-label: (), overlap-by-location: (),
    remaining: (<forward-mark>, <later-body>), scoped: (<scoped-body>,),
    scoped-again: (), page-again: (), long: (<long-body>,), long-again: (),
  )
  let starts = query(<endnote-batch-start>)
  let ends = query(<endnote-batch-end>)
  let bodies = query(<deixis-rendered-start>)
  assert.eq(bodies.len(), 7)
  for (name, labels) in expected {
    let start = starts.find(n => n.value == name).location()
    let end = ends.find(n => n.value == name).location()
    let printed = query(selector(<deixis-rendered-start>).after(start).before(end))
    assert.eq(printed.map(n => n.value.id), labels)
  }
  let alpha = bodies.find(n => n.value.id == <alpha-body>)
  assert.eq((alpha.value.body-marker-style)("1"), text("A1"))
  let long = bodies.find(n => n.value.id == <long-body>)
  let long-end = query(<deixis-rendered-end>).find(n => n.value.id == <long-body>)
  assert(long-end.location().page() >= long.location().page() + 2,
    message: "The long endnote should span at least three physical pages.")
  let pages = query(<endnote-pages>)
  for p in range(long.location().page(), long-end.location().page() + 1) {
    assert(<long-body> in pages.find(n => n.value.page == p).value.labels,
      message: "Page-note introspection lost a continuation page.")
  }
  [#metadata((destinations: bodies.filter(n => n.value.body-lbl != none).map(n => {
    let pos = query(n.value.body-lbl).first().location()
    (page: pos.page(), x: pos.position().x.pt(), y: pos.position().y.pt())
  })))<test-result>]
}
