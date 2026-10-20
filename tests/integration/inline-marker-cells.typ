#import "../../src/lib.typ": *
#import "../../src/marks/inline-paint.typ": _deixis-render-inline-mark
#set page(width: 550pt, height: auto, margin: 30pt)
#show: deixis-setup-notes
#let live = state("inline-marker-passages", 0)
#let contains-super(value) = {
  if type(value) == array { return value.any(contains-super) }
  if type(value) != content { return false }
  value.func() == super or value.fields().values().any(contains-super)
}
// A box cannot shield a superscript from an enclosing native decoration.
#show underline: it => { assert(not contains-super(it.body)); it }
#show highlight: it => { assert(not contains-super(it.body)); it }
#let edges = (top: blue + 0.7pt, bottom: red + 0.9pt, left: green + 1pt, right: purple + 1.2pt)
#let corners = (top-left: 3pt, top-right: 5pt, bottom-left: 4pt, bottom-right: 6pt)
#let cases = state("inline-marker-cases", ())
#context {
  for font in ("Libertinus Serif", "DejaVu Sans") {
    for size in (11pt, 20pt) {
      text(font: font, size: size)[#context {
        for mode in ("box", "underline", "parentheses", "highlight") {
          for side in (left, right) {
            for marker in ("1", "A", "*", "a") {
              let key = repr((font, size, mode, side, marker))
              let body = [#live.update(n => n + 1)#box[#metadata(key)<passage-start>A] marked passage
                that wraps naturally across a line to #box[#metadata(key)<passage-end>method]]
              let painted = _deixis-render-inline-mark(body, inline-mode: mode, marker-position: side,
                marker-str: marker, marker-style: it => [#metadata(key)<marker-position>#super(it)],
                mark-lbl: label("deixis-mark-" + key), body-lbl: <destination>,
                stroke: edges, fill: yellow, radius: corners)
              let emit = painted.value
              assert(calc.abs(measure(emit(false)).width - measure(emit(true)).width) < 0.001pt)
              let ascent = measure(text(bottom-edge: "baseline", [M])).height
              cases.update(items => items + ((key: key, side: side, ascent: ascent),))
              block(width: 180pt, painted)
            }
          }
        }
      }]
    }
  }
}
Destination #metadata(none)<destination>
#context {
  assert.eq(live.final(), 128)
  assert.eq(query(<deixis-mark-destination>).len(), 128)
  assert.eq(query(std.link).filter(it => it.dest == <destination>).len(), 128)
  let markers = query(<marker-position>)
  for item in cases.final() {
    let marker = markers.find(m => m.value == item.key).location().position()
    let boundary = query(if item.side == left { <passage-start> } else { <passage-end> })
      .find(m => m.value == item.key).location().position()
    assert.eq(marker.page, boundary.page)
    assert(calc.abs(marker.y - boundary.y - item.ascent) < 0.001pt, message: "marker detached: " + item.key)
  }
}
