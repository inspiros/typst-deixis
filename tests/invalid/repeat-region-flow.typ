#import "../../src/lib.typ": *
#set page(width: 420pt, height: 250pt, margin: 35pt)
#show: deixis-setup-notes
#deixis-inline-mark(id: <owner>)[Original]
#deixis-region-mark(of: <owner>, layer: "flow")[
  #for i in range(12) {
    [Paragraph #i.]
    v(32pt)
  }
]
