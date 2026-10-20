#import "../../src/lib.typ": *
#let mode = sys.inputs.at("mode", default: "empty")
#deixis-set(palette: if mode == "empty" { () } else if mode in ("large", "none-entry") { (blue, none) }
  else if mode == "mixed" { (blue, "red") } else if mode == "map" { (mark: (blue, red)) }
  else if mode == "bool" { true } else if mode == "name" { "unknown" } else { blue })
