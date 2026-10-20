#import "../../src/lib.typ": *
#set text(size: 10pt)
#let backwards = sys.inputs.at("direction", default: "forward") == "backward"
#let mode = sys.inputs.at("mode", default: "bare")
#let kind = sys.inputs.at("kind", default: "explicit")
#let policy = sys.inputs.at("policy", default: "native")
#set page(width: if backwards { 240pt } else { 600pt }, height: 250pt, margin: (left: 30pt, right: 20pt, y: 30pt))
#show: deixis-setup-notes
#show: body => if policy == "native" { body } else { deixis-routing(policy: policy, body) }
#let paint(r) = {
  let d = r.route.document
  let p = d.continuation.point
  assert.eq(d.continuation.allocation.automatic, mode != "fixed")
  assert.eq(p.first(), if mode == "fixed" or d.is-outgoing { 540pt } else { 70pt })
  [#metadata((page: d.page, x: p.first()))<automatic-split>]
  deixis-render-connector(r)
}
#let via = (if mode == "none" { auto }
  else if mode == "bare" { ("split",) }
  else if mode == "array" { (("split",),) }
  else if mode == "auto" { (("split", auto),) } else { (("split", 0pt),) })
#let options = (route: "orthogonal", radius: 0pt, via: via, render: paint)
#let body() = deixis-inset-note-body(of: <n>, layer: "foreground", width: 60pt,
  placement: x => place(top + left, dx: 40pt, dy: 80pt, x), connector: options)[Body]
#if kind == "explicit" {
  deixis-connect(from: (pin: <a>), to: (pin: <b>), connector: options)
  if backwards { place(top + left, dx: 40pt, dy: 80pt, deixis-pin(<b>, padding: 0pt)) }
  else { place(top + left, dx: 510pt, dy: 50pt, deixis-pin(<a>, padding: 0pt)) }
} else if backwards { body() } else {
  place(top + left, dx: 510pt, dy: 50pt, deixis-mark(id: <n>, mark-type: "phantom"))
}
First Page
#pagebreak()
Middle Page
#pagebreak()
#set page(width: if backwards { 600pt } else { 240pt }, height: 280pt)
#if kind == "explicit" {
  if backwards { place(top + left, dx: 510pt, dy: 50pt, deixis-pin(<a>, padding: 0pt)) }
  else { place(top + left, dx: 40pt, dy: 80pt, deixis-pin(<b>, padding: 0pt)) }
} else if backwards {
  place(top + left, dx: 510pt, dy: 50pt, deixis-mark(id: <n>, mark-type: "phantom"))
} else { body() }
Last Page
#context assert.eq(query(<automatic-split>).map(m => m.value.page).sorted(), (1, 3))
