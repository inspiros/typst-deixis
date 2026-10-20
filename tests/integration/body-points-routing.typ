#import "../../src/lib.typ": *
#set page(width: 450pt, height: 300pt, margin: 40pt)
#show: deixis-setup-notes
#let count = 0
#let painter(name, coincident, request) = {
  [#metadata((name: name, coincident: coincident, document: request.route.document,
    segments: request.route.segments, shaft: request.shaft,
    start: request.route.start, end: request.route.end,
    start-tangent: request.route.start-tangent, end-tangent: request.route.end-tangent))<point-router>]
  for s in request.shaft {
    place(top + left, curve(stroke: request.stroke, curve.move(s.start),
      if s.kind == "line" { curve.line(s.end) } else { curve.cubic(s.c1, s.c2, s.end) }))
  }
  deixis-render-head(request.heads.mark, request.route.start, request.route.start-tangent.map(v => -v))
  deixis-render-head(request.heads.body, request.route.end, request.route.end-tangent)
}
#for route in ("straight-line", "right-angle", "chamfer", "curve", "ucr", "ccr") {
  for coincident in (false, true) {
    if count > 0 { pagebreak() }
    let source = "route-source-" + str(count)
    let target = "route-target-" + str(count)
    count += 1
    deixis-mark(id: source)[Original]
    v(10pt)
    let point = deixis-mark(of: source, mark-type: "phantom", occurrence: <point>)
    let body = deixis-inline-note-body(id: target, inline: true, inline-mode: "none")[Body point.]
    if coincident {
      deixis-inline-note-body(id: target, inline: true, inline-mode: "none")[#point#text[Body point.]]
    } else { point; [Point source.]; v(70pt); body }
    deixis-connect(from: (mark: source, occurrence: <point>), to: (body: target, point: "start"),
      connector: (route: route, heads: (mark: "circle", body: "triangle"),
        render: painter.with(route, coincident)))
  }
}
