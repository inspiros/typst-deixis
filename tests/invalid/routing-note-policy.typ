#import "../../src/lib.typ": *
#set page(width: 420pt, height: 260pt, margin: (left: 30pt, right: 95pt, y: 30pt))
#show: deixis-setup-notes
#show: deixis-routing
#let kind = sys.inputs.at("kind", default: "inset")
#let mode = sys.inputs.at("mode", default: "curve")
#let options = (route: "orthogonal", radius: 0pt) + (if mode == "curve" { (route: "curve") }
  else if mode == "radius" { (radius: 2pt) }
  else if mode == "mixed" { (segments: ((route: "curve", via: ((50pt, 40pt),)),)) }
  else { (scene: deixis-routing-scene()) })
#deixis-mark(id: <note>)[Source]
#if kind == "inset" {
  deixis-inset-note-body(of: <note>, layer: "foreground", width: 65pt, connector: options,
    placement: x => place(top + left, dx: 190pt, dy: 90pt, x))[Body]
} else {
  deixis-margin-note-body(of: <note>, width: 65pt, connector: options)[Body]
}
