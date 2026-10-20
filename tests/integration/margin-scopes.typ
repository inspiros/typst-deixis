#import "../../src/lib.typ": *
#set page(width: 500pt, height: 350pt, margin: (inside: 85pt, outside: 100pt, y: 40pt))
#show: deixis-setup-notes
Odd#deixis-sidenote[Odd outside.]
#pagebreak()
Even#deixis-sidenote[Even outside.]
#deixis-set(margin-layout: "exact")
#deixis-block(id: <exact>, inset: (right: 70pt, rest: 5pt))[
  Exact#deixis-margin-note(side: right, spillover: false)[Block exact.]
  #v(25pt)
  Immediate#deixis-margin-note(layer: "flow", side: right)[Block immediate.]
]
#context [#metadata(query(<deixis-rendered-start>).filter(n => n.value.body-type == "margin-note").map(n => (
  target: n.value.target-id, page: n.location().page(), x: n.location().position().x.pt(),
)))<test-result>]
