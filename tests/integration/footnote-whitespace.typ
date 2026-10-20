// Compare real glyph positions with an ordinary native footnote control.
#import "../../src/lib.typ": *
#set page(width: 420pt, height: 700pt, margin: 30pt)
#set text(size: 11pt)
#show: deixis-setup-notes
#let mode = sys.inputs.at("mode", default: "flow")
#let renderer = sys.inputs.at("renderer", default: "default")
#let samples = ([Alpha.], [
  Alpha.
], [

  Alpha.
], [\ Alpha.], text(fill: red)[
  Alpha.
], [#set text(fill: red)
  Alpha.
], [
  #metadata(none)
  Alpha.
], [#text[
  Alpha.
]], [#context [
  Alpha.
]], [#set text(fill: red)

  Alpha.
])
#let note(body) = if mode == "native" { std.footnote(body) } else {
  deixis-footnote(layer: mode,
    render-single: if renderer == "native" { deixis-native-render-single } else { auto }, body)
}
// Adjacent/spaced words, punctuation, natural wrapping and justified text must
// retain the native paragraph shape, including the space after an annotation.
#set par(justify: true)
AA#note(samples.at(0))BB CC.

DD
#note(samples.at(1)) EE FF.

GG#note(samples.at(2))HH II.

JJ#note(samples.at(3))KK LL.

#for sample in samples.slice(4) { [Passage#note(sample). ] }

#lorem(30) followed#note[Last.] by more words and punctuation.

#note[Isolated.]

Another Paragraph.
#context {
  if mode != "native" {
    assert.eq(query(<deixis-footnote-entry>).len(), 12)
    assert.eq(counter(footnote).final(), (0,))
  }
}
