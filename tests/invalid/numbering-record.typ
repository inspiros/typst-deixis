#import "../../src/lib.typ": *
#show: deixis-setup-notes
#let mode = sys.inputs.at("mode", default: "restart")
#let invalid = { if mode == "restart" { (restart: "section", pattern: "1") }
  else if mode == "pattern" { (restart: "page", pattern: 12) }
  else if mode == "unknown" { (restart: "page", pattern: "1", unknown: true) }
  else { (restart: "page", rest: "1") }
}
Text#deixis-footnote(numbering: invalid)[Body]
