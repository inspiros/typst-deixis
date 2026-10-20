#import "../../src/lib.typ": *
#set page(width: 450pt, height: 220pt, margin: (x: 100pt, y: 30pt))
#show: deixis-setup-notes
#let layer = sys.inputs.at("layer", default: "foreground")
#let mode = sys.inputs.at("mode", default: "tall")
#let form = sys.inputs.at("form", default: "attached")
#deixis-set(margin-layout: if mode == "custom" { (..args) => [] } else { "exact" })
#let note() = {
  let body = if mode in ("tall", "block") { block(height: 190pt)[Tall.] } else { [Small.] }
  let options = (layer: layer, side: right, overflow: "error",
    width: if mode == "wide" { 120pt } else { 85pt },
    dx: if mode == "negative" { -10pt } else { 0pt },
    dy: if mode == "above" { -50pt } else { 0pt })
  if form == "standalone" { deixis-margin-note-body(id: <note>, ..options, body) }
  else if form == "wrapper" { deixis-margin-note(id: <note>, ..options)[Mark][#body] }
  else { deixis-mark(id: <note>)[Mark]; deixis-margin-note-body(of: <note>, ..options, body) }
}
#if mode == "block" { deixis-block(inset: (x: 90pt, y: 5pt))[#note()#v(30pt)End.] } else { note() }
Following.
