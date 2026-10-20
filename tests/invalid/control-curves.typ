#import "../../src/lib.typ": *
#show: deixis-setup-notes
#let mode = sys.inputs.at("mode", default: "type")
#let form = sys.inputs.at("form", default: "explicit")
#let values = (
  type: none, scalar: 20pt, item: (20pt,), string: ("body",),
  short: ((10pt,),), long: ((10pt, 20pt, 30pt),), coordinate: ((true, 10pt),),
  switch: ((kind: "curve"),), key: ((offset: (0pt, 0pt), bogus: 1),),
  offset: ((offset: 10pt),), offset-type: ((offset: (2, 3)),),
  frame: ((relative-to: "sheet"),), anchor: ((relative-to: "mark", anchor: "left"),),
  previous: ((anchor: left),),
  pin-name: ((pin: ""),), pin-offset: ((pin: "p", offset: (50%, 0pt)),),
  pin-missing: ((pin: "missing"),), pin-page: ((pin: "later"),),
  pin-multiple: ((pin: (name: "p", select: "all")),), pin-ambiguous: ((pin: "p"),),
)
#let record = (kind: "b-spline", controls: values.at(mode, default: ((20pt, 30pt),)))
#if mode == "tension" { record.tension = 2 }
#if mode == "policy" { record.parameterization = "uniform" }
#if mode == "degree" { record.degree = 2 }
#if mode == "knots" { record.knots = (0, 0, 1, 1) }
#let options = {
  if form == "segments" { (route: "b-spline", segments: ((route: record),)) }
  else if form == "via" { (route: "b-spline", via: (record,)) }
  else { (route: record) }
}
#if mode == "waypoints" { options.via = ((10pt, 20pt), (20pt, 30pt)) }
#if form == "settings" { deixis-set(connector: options) }
#if form == "margin" {
  deixis-margin-note(connector: options)[Source][Bad settings.]
} else if form == "inset" {
  deixis-inset-note(connector: options)[Source][Bad settings.]
} else {
  deixis-connect(from: (pin: "a"), to: (pin: "b"), connector: if form == "settings" { auto } else { options })
}
#place(top + left, dx: 10pt, dy: 20pt, deixis-pin("a", padding: 0pt))
#place(top + left, dx: 200pt, dy: 150pt, deixis-pin("b", padding: 0pt))
#place(top + left, dx: 40pt, dy: 20pt, deixis-pin("p", padding: 0pt))
#place(top + left, dx: 50pt, dy: 30pt, deixis-pin("p", padding: 0pt))
Text.
#pagebreak()
#deixis-pin("later", padding: 0pt)
Later.
