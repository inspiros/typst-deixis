#import "@preview/deixis:0.2.0": *
#set page(width: 420pt, height: 260pt, margin: (left: 30pt, right: 95pt, y: 30pt))
#show: deixis-setup-notes
#let kind = sys.inputs.at("kind", default: "inset")
#let policy = sys.inputs.at("policy", default: "avoid")
#let mode = sys.inputs.at("mode", default: "mark")
#show: deixis-routing.with(policy: policy)
#let paint(r) = { panic("Covered shorthand executed its painter") }
#let head(r) = { panic("Covered shorthand executed its head") }
#let mark = deixis-mark(id: <note>)[Source]
#if mode == "mark" { hide(mark) } else { mark }
#let options = if mode == "disabled" { none } else {
  (route: "orthogonal", radius: 0pt, render: paint, heads: (body: head))
}
#let body = if kind == "inset" {
  deixis-inset-note-body(of: <note>, layer: "foreground", width: 65pt, connector: options,
    placement: x => place(top + left, dx: 190pt, dy: 90pt, x))[Body]
} else {
  deixis-margin-note-body(of: <note>, width: 65pt, connector: options)[Body]
}
#if mode == "body" { hide(body) } else { body }
#context assert.eq(query(<deixis-routing-plan>).len(), 0)
