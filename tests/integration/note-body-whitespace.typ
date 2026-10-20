// Body adapters must preserve supplied content, including explicit boundaries.
// Native weak marker spacing, rather than content-tree surgery, folds spaces.
#import "../../src/lib.typ": *
#set page(width: 520pt, height: 350pt, margin: (left: 35pt, right: 170pt, y: 35pt))
#set text(size: 11pt)
#show: deixis-setup-notes
#let kind = sys.inputs.at("kind", default: "margin")
#let samples = ([Alpha.], [
  Alpha.
], [

  Alpha.
], [\ Alpha.], text(fill: red)[
  Alpha.
], [#set text(fill: red)
  Alpha.
], [#context [
  Alpha.
]], [Alpha.#parbreak()])
#for (i, sample) in samples.enumerate() {
  pagebreak(weak: true)
  let renderer(data, ..args) = {
    assert.eq(data.body, sample)
    deixis-aligned-render-single(data, ..args)
  }
  let options = (render-single: renderer, backlink: false)
  if kind == "margin" { [Passage#deixis-margin-note(..options, sample).] }
  else if kind == "inset" { [Passage#deixis-inset-note(..options, layer: "foreground", dx: 20pt, dy: 50pt, sample).] }
  else if kind == "inline" { [Passage#deixis-mark(id: "n" + str(i)).]; deixis-inline-note-body(of: "n" + str(i), ..options, sample) }
  else if kind == "footnote" { [Passage#deixis-footnote(..options, layer: "flow", sample).] }
  else if kind == "block-footnote" { deixis-block[Passage#deixis-footnote(..options, sample).] }
  else if kind == "endnote" {
    deixis-block[
      Passage#deixis-endnote(..options, sample).
      #deixis-print-endnotes()
    ]
  }
  [Following Text.]
}
