#import "../../src/lib.typ": *
#set page(width: 500pt, height: 500pt, margin: 45pt)
#show: deixis-setup-notes
#columns(2, gutter: 20pt)[
  #for i in range(6) {
    if i == 3 { colbreak() }
    lorem(18)
    deixis-footnote(marker: if i == 1 { [Wide marker] } else { auto })[#lorem(12)]
    parbreak()
  }
]
#context [#metadata((
  bodies: query(<deixis-rendered-end>).map(n => (
    x: n.location().position().x.pt(), y: n.location().position().y.pt(),
  )),
  marks: query(<deixis-inline-mark>).map(n => n.location().position().x.pt()),
))<test-result>]
