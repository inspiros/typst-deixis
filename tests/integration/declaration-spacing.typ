// Named declarations add no text: a passage starts where its anonymous form
// does, for every mark kind and note wrapper that registers an original.
#import "../../src/lib.typ": *
#set page(width: 400pt, height: auto, margin: 20pt)
#show: deixis-setup-notes
#let start(name) = [#metadata(name)<passage-start>]
#let forms = (
  ("inline", it => deixis-inline-mark(id: <inline>, inline-mode: "none", it),
    it => deixis-inline-mark(inline-mode: "none", it)),
  ("mark", it => deixis-mark(id: <mark>, inline-mode: "none", it),
    it => deixis-mark(inline-mode: "none", it)),
  ("region", it => deixis-region-mark(id: <region>, inline: true, padding: 0pt, it),
    it => deixis-region-mark(inline: true, padding: 0pt, it)),
  ("margin", it => deixis-margin-note(id: <margin>, inline-mode: "none", it)[Body.],
    it => deixis-margin-note(inline-mode: "none", it)[Body.]),
)
#for (name, named, anonymous) in forms {
  [X#named[#start(name + "-named")Q]Y]
  parbreak()
  [X#anonymous[#start(name + "-anonymous")Q]Y]
  parbreak()
}
// Body-less marks keep their weak glue: no space before the marker either.
X#deixis-phantom-mark(id: <phantom>)#start("phantom-named")Y

X#deixis-phantom-mark()#start("phantom-anonymous")Y
#deixis-footnote-body(of: <phantom>)[Phantom body.]

X#start("plain")Q

#context {
  let starts = query(<passage-start>).map(m => (m.value, m.location().position().x))
  let plain = starts.find(s => s.first() == "plain").last()
  assert.eq(starts.len(), 11)
  for (name, x) in starts { assert(calc.abs((x - plain).pt()) < 0.01, message: name + " starts at " + repr(x)) }
}
