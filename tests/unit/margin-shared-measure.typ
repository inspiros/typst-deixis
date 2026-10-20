// Margin planning measures bodies at the note's located metadata so every page
// can reuse the measurement. The caller's styles must still decide the size,
// and another note's metadata inside a measured body must pass through.
#import "../../src/lib.typ": *
#import "../../src/layout/margin.typ": _deixis-measure-margin-height
#set page(width: 300pt, height: 200pt, margin: (right: 100pt, rest: 20pt))
#show: deixis-setup-notes
First#deixis-margin-note[a][Short body.] and
second#deixis-margin-note[b][A longer body that wraps across several margin lines.]

#let bodies = (
  block(width: 60pt)[Plain text that wraps inside a narrow block.],
  context box(width: 10pt, height: 2 * text.size),
  block(width: 60pt, par(leading: 1em)[Leading follows the caller's styles.]),
  box(width: 80pt, align(left, pad(left: 5pt, block(width: 60pt)[Nested margin box.]))),
)
#for size in (6pt, 20pt) {
  set text(size: size)
  context {
    let anchors = query(<deixis-margin-note>)
    assert.eq(anchors.len(), 2)
    let heights = ()
    for (i, anchor) in anchors.enumerate() {
      let other = anchors.at(1 - i)
      for body in bodies + ([Before#other;after],) {
        let expected = measure(body).height
        assert.eq(_deixis-measure-margin-height(body, anchor), expected)
        heights.push(expected)
      }
    }
    // The contextual body follows the caller's text size, not the declaration's.
    assert.eq(heights.at(1), 2 * size)
    [#metadata(heights)<shared-measure>]
  }
}
#context {
  let runs = query(<shared-measure>).map(m => m.value)
  assert.eq(runs.len(), 2)
  assert.ne(runs.first(), runs.last())
}
