#import "../../src/lib.typ": *
#show: deixis-setup-notes
#let mode = sys.inputs.at("mode", default: "global")
#{
  if mode == "local" { deixis-sidenote(fill: (sidenote: blue))[Unmatched type.] }
  else if mode == "nested" {
    deixis-set(fill: (margin-note: (body: (sidenote: blue))))
    deixis-sidenote[Unmatched nested type.]
  } else {
    deixis-set(fill: (sidenote: blue, rest: none))
    deixis-sidenote[Unmatched type.]
  }
}
