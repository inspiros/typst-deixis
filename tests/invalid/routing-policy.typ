#import "../../src/lib.typ": *
#show: deixis-setup-notes
#let mode = sys.inputs.at("mode", default: "unknown")
#let policy = (if mode == "unknown" { "automatic" } else if mode == "none" { none }
  else if mode == "auto" { auto } else if mode == "number" { 1 }
  else if mode == "record" { (avoid: true) } else { <avoid> })
#deixis-routing(policy: policy)[Text]
