#import "../../src/lib.typ": *
#set page(width: 420pt, height: 320pt, margin: 40pt)
#show: deixis-setup-notes
#let ticks = state("footnote-boundary-bodies", 0)
#let body(name) = [#ticks.update(n => n + 1)#name]

// Empty overlay markers allocate reliably before visible content. The original
// mark and body declaration may appear in either order.
#deixis-footnote-body(of: <forward>, layer: "foreground")[#body("Forward overlay body.")]
#deixis-inline-mark(id: <forward>)[Forward original].

#deixis-inline-mark(id: <backward>)[Backward original]
#deixis-footnote-body(of: <backward>, layer: "background")[#body("Backward overlay body.")].

#pagebreak()
// Flow retains native allocation at the paragraph/document end, with a weak
// zero marker. Standalone flow declarations may introduce an empty paragraph.
Native flow#deixis-footnote(layer: "flow")[#body("Trailing flow body.")]

#block[Between blocks.]
#deixis-footnote-body(layer: "flow")[#body("Standalone flow body.")]
#block[Following block.]
#deixis-footnote-body(layer: "flow")[#body("Final flow body.")]
#context {
  assert.eq(ticks.final(), 5)
  assert.eq(query(<deixis-rendered-start>).len(), 5)
  assert.eq(query(<deixis-reserver-left>).len(), 2)
}
