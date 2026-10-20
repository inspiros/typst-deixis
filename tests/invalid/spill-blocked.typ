#import "../../src/lib.typ": *
#set page(width: 420pt, height: 260pt, margin: (left: 90pt, right: 110pt, y: 30pt))
#show: deixis-setup-notes
#deixis-connect(from: (pin: <source>), to: <note>, connector: (
  route: "orthogonal", radius: 0pt,
  scene: d => deixis-routing-scene(nodes: if d.is-outgoing {
    ((page: d.page, bounds: (left: 300pt, right: 420pt, top: 210pt, bottom: 260pt)),)
  } else { () })))
#place(top + left, dx: 60pt, dy: 80pt, deixis-pin(<source>, padding: 0pt))
#pagebreak()
#deixis-margin-note(id: <note>, side: right, width: 65pt)[Mark][Body]
