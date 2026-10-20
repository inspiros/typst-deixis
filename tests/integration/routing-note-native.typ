#import "../../src/lib.typ": *
#set page(width: 440pt, height: 280pt, margin: (left: 30pt, right: 95pt, y: 30pt))
#set text(size: 10pt)
#show: deixis-setup-notes
#let kind = sys.inputs.at("kind", default: "inset")
#let active = sys.inputs.at("policy", default: "manual") == "manual"
#show: it => if active { deixis-routing(policy: "manual", it) } else { it }
#let paint(r) = {
  assert.eq(r.route.at("search", default: none), none)
  [#metadata(r.route)<note-native-route>]
  deixis-render-connector(r)
}
#let options = (route: "curve", radius: 3pt, heads: "triangle", render: paint,
  via: if kind == "margin" { auto } else { ((40pt, 20pt), (80pt, 35pt)) })
#deixis-mark(id: <note>, inline-mode: "underline")[Source]
#if kind == "margin" {
  deixis-margin-note-body(of: <note>, width: 65pt, connector: options)[Body]
} else {
  deixis-inset-note-body(of: <note>, width: 65pt, layer: "foreground", connector: options,
    placement: x => place(top + left, dx: 200pt, dy: 100pt, x))[Body]
}
#context {
  assert.eq(query(<note-native-route>).len(), 1)
  assert.eq(query(<deixis-routing-plan>).len(), 0)
}
