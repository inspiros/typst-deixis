#import "../../src/lib.typ": *
#show: deixis-setup-notes
#let mode = sys.inputs.at("mode", default: "text-fill")
#let stroke = (left: blue, rest: none)
#{
  if mode == "text-fill" { deixis-mark(stroke: stroke, inline-mode: "text-fill")[Ambiguous paint.] }
  else if mode == "margin-stroke" { deixis-margin-note(stroke: stroke, connector: (route: "straight-line"))[Edges.] }
  else if mode == "inset-stroke" { deixis-inset-note(stroke: stroke, connector: (route: "straight-line"))[Edges.] }
  else if mode == "radius" { deixis-inset-note(radius: (top-left: 2pt), connector: (route: "straight-line"))[Corners.] }
  else {
    [#deixis-pin("start")Start.]
    [#deixis-pin("end")End.]
    deixis-connect(from: (pin: "start"), to: (pin: "end"), connector: (route: "straight-line", stroke: stroke))
  }
}
