#import "../../src/lib.typ": *
#show: deixis-setup-notes
#let form = sys.inputs.at("form", default: "body")
#let value = (unknown: "clip", boolean: true, integer: 2).at(sys.inputs.at("value", default: "unknown"))
#{
  if form == "settings" { deixis-set(overflow: value); deixis-margin-note[Body.] }
  else if form == "wrapper" { deixis-margin-note(overflow: value)[Body.] }
  else { deixis-margin-note-body(overflow: value)[Body.] }
}
