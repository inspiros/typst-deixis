#import "../../src/lib.typ": *
#set page(width: 420pt, height: 260pt, margin: 30pt)
#show: deixis-setup-notes
#let painter(name, request) = [#metadata((name: name, document: request.route.document,
  origin: request.route.origin, segments: request.route.segments,
  heads: (request.heads.mark != none, request.heads.body != none)))<pin-page-route>]
#let connect(from, to, name) = deixis-connect(from: (pin: from), to: (pin: to),
  connector: (route: "curve", ports: (right, left), heads: (mark: "circle", body: "triangle"),
    render: painter.with(name), via: ((pin: from + "-via"), "split", (pin: to + "-via"))))
#connect("early", "late", "forward")
#connect("late", "early", "backward")
#place(top + left, dx: 60pt, dy: 70pt, deixis-pin("early"))
#place(top + left, dx: 120pt, dy: 120pt, deixis-pin("early-via"))
#pagebreak()
No route on this intermediate page.
#pagebreak()
#place(top + left, dx: 260pt, dy: 100pt, deixis-pin("late"))
#place(top + left, dx: 180pt, dy: 140pt, deixis-pin("late-via"))
