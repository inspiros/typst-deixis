#import "../../src/lib.typ": *
#set page(width: 440pt, height: 280pt, margin: (left: 30pt, right: 100pt, y: 30pt))
#show: deixis-setup-notes
#show: deixis-routing
#let kind = sys.inputs.at("kind", default: "margin")
#deixis-connect(from: (pin: <p>), to: <n>, connector: (heads: "triangle"))
#deixis-mark(id: <n>)[Source]
#if kind == "margin" {
  deixis-margin-note-body(of: <n>, connector: none, width: 65pt)[Body]
} else {
  deixis-inset-note-body(of: <n>, connector: none, layer: "foreground", width: 65pt, dx: 140pt, dy: 60pt)[Body]
}
#place(top + left, dx: 20pt, dy: 150pt, deixis-pin(<p>, padding: 0pt))
#context {
  let plans = query(<deixis-routing-plan>).map(m => m.value)
  assert.eq(plans.len(), 1)
  assert.eq(plans.first().plan.routes.first().status, "ok")
}
