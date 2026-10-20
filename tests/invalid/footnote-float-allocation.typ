#import "../../src/lib.typ": *
#show: deixis-setup-notes
#let layer = sys.inputs.at("layer", default: "flow")
#let kind = sys.inputs.at("kind", default: "wrapper")
#let placement = if sys.inputs.at("placement", default: "top") == "top" { top } else { bottom }
#figure(placement: placement, scope: "parent")[
  Floating source.
  #{
    if kind == "wrapper" { deixis-footnote(layer: layer)[Missing native allocation.] }
    else if kind == "standalone" { deixis-footnote-body(layer: layer)[Missing native allocation.] }
    else {
      deixis-mark(id: <source>)[Marked source]
      deixis-footnote-body(of: <source>, layer: layer)[Missing native allocation.]
    }
  }
  Following text does not repair parent-scope float allocation.
]
Main flow.
