#import "../../src/lib.typ": *
#set page(width: 320pt, height: 220pt, margin: 20pt)
#show: deixis-setup-notes
#let paint(request) = {
  assert.eq(request.route.interactions.map(e => e.behavior).sorted(), ("cross", "cut"))
  assert.eq(request.route.scene-cuts.len(), 1)
  assert(request.shaft.len() > 1)
  [#metadata(request.route.document.page)<behavior-paint>]
  deixis-render-connector(request)
}
#deixis-routing[
  #deixis-connect(from: (node: <a>, scope: <boxes>), to: (node: <b>, scope: "boxes"),
    connector: (ports: (mark: (pin: <socket>, side: right)), render: paint))
  #place(top + left, dx: 0pt, dy: 60pt)[#deixis-attach(id: <a>, scope: "boxes",
    pins: ((<unused>, (anchor: bottom)),))[
    #rect(width: 40pt, height: 20pt)]]
  #place(top + left, dx: 40pt, dy: 70pt, deixis-pin(<socket>, padding: 0pt))
  #place(top + left, dx: 230pt, dy: 60pt)[#deixis-attach(id: <b>, scope: <boxes>)[#rect(width: 40pt, height: 20pt)]]
  #place(top + left, dx: 80pt, dy: 40pt)[#deixis-attach(behavior: "cut")[#rect(width: 30pt, height: 60pt)]]
  #place(top + left, dx: 140pt, dy: 40pt)[#deixis-attach(behavior: "cross")[#rect(width: 30pt, height: 60pt)]]
  #place(top + left, dx: 190pt, dy: 40pt)[#deixis-attach(behavior: "ignore")[#rect(width: 30pt, height: 60pt)]]
]
#context assert.eq(query(<behavior-paint>).len(), 1)
