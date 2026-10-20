#import "../../src/lib.typ": *
#set page(width: 250pt, height: 180pt, margin: 25pt)
#show: deixis-setup-notes
#deixis-inset-note(id: <n>, layer: "flow", connector: none, container-func: deixis-plain-container)[Source][
  #for i in range(12) { [Paragraph #i.] + v(25pt) }
]
#deixis-connect(from: <n>, to: <n>)
