#import "../../src/lib.typ": *
#set page(width: 400pt, height: 250pt, margin: 40pt)
#show: deixis-setup-notes
#deixis-connect(from: (pin: <source>), to: <note>)
#deixis-pin(<source>)
#pagebreak()
#deixis-block(inset: 60pt)[
  #deixis-margin-note(id: <note>, width: 40pt, side: right)[Mark][Body]
]
