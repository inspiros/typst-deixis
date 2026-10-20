#import "../../src/lib.typ": *
#set page(width: 400pt, height: 400pt, margin: 45pt)
#show: deixis-setup-notes.with(override-page-footnotes: false)
Ordinary#footnote[Ordinary one.]
Custom#deixis-footnote(id: <custom>, backlink: true)[
  Native-start. #lorem(400) Native-end.
]
Ordinary#footnote[Ordinary two.]
Ref @custom.
#pagebreak()
Tail text.
