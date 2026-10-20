#import "../../src/lib.typ": *
#set page(width: 480pt, height: 360pt, margin: 75pt)
#show: deixis-setup-notes
Footnote#deixis-footnote(id: <foot>, backlink: true)[The footnote destination.]
#v(20pt)
Inset#deixis-inset-note(id: <inset>, width: 90pt, dx: 35pt, dy: 30pt,
  connector: (route: "straight-line", heads: (mark: "stealth", body: "stealth")))[The inset destination.]
#pagebreak()
Forward and backward links: @foot and @inset.
#context [#metadata((
  destinations: (<foot>, <inset>).map(lbl => {
    let loc = query(lbl).first().location()
    (page: loc.page(), x: loc.position().x.pt(), y: loc.position().y.pt())
  }),
))<test-result>]
