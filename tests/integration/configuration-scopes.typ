#import "../../src/lib.typ": *
#set page(width: 500pt, height: 500pt, margin: 40pt)
#show: deixis-setup-notes
#let rendered = state("configuration-scope-bodies", ())
#let render(n, ..args) = {
  assert.eq(n.styles.stroke.paint, n.data.paint)
  assert.eq(n.styles.radius, n.data.radius)
  assert.eq(n.marker-gap, n.data.gap)
  [#rendered.update(ids => ids + (n.id,))#deixis-native-render-single(n, ..args.named())]
}
#let body(id, paint, radius, gap) = deixis-inline-note-body(id: id,
  data: (paint: paint, radius: radius, gap: gap))[Captured Body]
#deixis-set(stroke: (nodes: blue), radius: 1pt, marker-gap: 3pt, render-single: render)
#body("global", blue, 1pt, 3pt)
#deixis-block(id: <settings>)[
  #deixis-set(stroke: (body: orange), radius: (inline-note: (body: 2pt)), marker-gap: (body: 5pt))
  #body("local", orange, 2pt, 5pt)
  #deixis-block(id: <nested-settings>)[
    #deixis-set(stroke: (nodes: purple), marker-gap: (nodes: 7pt))
    #body("nested", purple, 2pt, 7pt)
    // A map branch reset resumes the outer scope. Top-level auto is a no-op.
    #deixis-set(stroke: (nodes: auto), marker-gap: (nodes: auto))
    #deixis-set(stroke: auto, radius: auto, marker-gap: auto)
    #body("cleared", orange, 2pt, 5pt)
  ]
  #body("restored-local", orange, 2pt, 5pt)
  #deixis-set(stroke: (:), radius: (:), marker-gap: (:))
  // Empty stroke/radius are literal native values; empty spacing is a scope
  // map with no branch and therefore resumes the document value.
  #deixis-inline-note-body(id: "empty", render-single: (n, ..args) => {
    assert.eq(n.styles.stroke, (:))
    assert.eq(n.styles.radius, (:))
    assert.eq(n.marker-gap, 3pt)
    deixis-native-render-single(n, ..args.named())
  })[Square And Borderless]
]
#body("restored-global", blue, 1pt, 3pt)
// Ordinary Typst brackets do not create a Deixis settings scope.
#[#deixis-set(stroke: (body: teal))]
#body("ordinary-brackets", teal, 1pt, 3pt)
// Settings, including ordering hints and no-op calls, are invisible in flow.
A#metadata("settings")<setting-start>#deixis-set()#deixis-set(z-index: (body: 3))#deixis-set(stroke: auto)#metadata("settings")<setting-end>B
#context {
  assert.eq(query(<setting-start>).first().location().position(),
    query(<setting-end>).first().location().position())
  assert.eq(rendered.final(), ("global", "local", "nested", "cleared", "restored-local", "restored-global", "ordinary-brackets"))
}
