#import "../../src/lib.typ": *
#set page(width: 420pt, height: 300pt, margin: 50pt)
#show: deixis-setup-notes
#let painter(request) = {
  let doc = request.route.document
  assert(doc.is-incoming != doc.is-outgoing)
  assert.eq(request.heads.mark != none, doc.is-outgoing)
  assert.eq(request.heads.body != none, doc.is-incoming)
  assert.eq(doc.endpoints.mark.role, if doc.is-incoming { "continuation" } else { "mark" })
  assert.eq(doc.endpoints.body.role, if doc.is-outgoing { "continuation" } else { "body" })
  [#metadata((source: doc.source-page, target: doc.target-page, page: doc.page,
    outgoing: doc.is-outgoing, incoming: doc.is-incoming))<routed-page>]
  for s in request.shaft {
    place(top + left, curve(stroke: request.stroke, curve.move(s.start),
      if s.kind == "line" { curve.line(s.end) } else { curve.cubic(s.c1, s.c2, s.end) }))
  }
  deixis-render-head(request.heads.mark, request.route.start, request.route.start-tangent.map(v => -v))
  deixis-render-head(request.heads.body, request.route.end, request.route.end-tangent)
}
#let options = (route: "catmull-rom-centripetal", heads: (mark: "triangle", body: "circle"),
  via: ((relative-to: "mark", offset: (15pt, 20pt)), "split", (relative-to: "body", offset: (-15pt, -20pt))),
  render: painter)
#deixis-inline-mark(id: <forward>)[Forward source.]
#deixis-inset-note-body(of: <backward>, layer: "foreground", placement: body => place(top + right, body),
  width: 100pt, connector: options)[Backward body.]
#pagebreak()
#set page(width: 500pt, height: 350pt, margin: 70pt)
Middle page. No connector continuation is drawn here.
#pagebreak()
#set page(width: 600pt, height: 400pt, margin: 80pt)
#deixis-inline-mark(id: <backward>)[Backward source.]
#deixis-inset-note-body(of: <forward>, layer: "background", placement: body => place(top + right, body),
  width: 100pt, connector: options)[Forward body.]
#context {
  let routes = query(<routed-page>).map(n => n.value)
  assert.eq(routes.len(), 4)
  assert.eq(routes.map(r => (r.source, r.target, r.page)).sorted(), ((1, 3, 1), (1, 3, 3), (3, 1, 1), (3, 1, 3)))
}
