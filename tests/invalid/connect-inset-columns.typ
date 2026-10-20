#import "../../src/lib.typ": *
#set page(width: 550pt, height: 360pt, margin: 25pt)
#set text(size: 10pt)
#show: deixis-setup-notes
#columns(2, gutter: 20pt)[
  #deixis-inset-note(id: <n>, layer: "flow", connector: none,
    container-func: deixis-plain-container)[Source][
    #for i in range(12) { [Paragraph #i. #lorem(10)] + parbreak() }
  ]
]
#deixis-connect(from: <n>, to: <n>)
