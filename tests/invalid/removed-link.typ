#import "../../src/lib.typ": *
#show: deixis-setup-notes
// 0.1 flat connector options were replaced by connector in 0.2.
#let option = sys.inputs.at("option", default: "link")
#let value = (link: "curve", link-ports: (mark: right), link-waypoints: ((10pt, 0pt),),
  link-marks: "body", link-heads: "stealth").at(option)
#let call = (
  margin: deixis-margin-note.with(..((option): value))[Passage],
  margin-body: deixis-margin-note-body.with(..((option): value)),
  inset: deixis-inset-note.with(..((option): value))[Passage],
  inset-body: deixis-inset-note-body.with(..((option): value)),
  sidenote: deixis-sidenote.with(..((option): value)),
).at(sys.inputs.at("form", default: "margin"))
#deixis-mark(id: <x>)[Original]
#call(..if sys.inputs.at("form", default: "margin").ends-with("body") { (of: <x>) } else { (:) })[Body.]
