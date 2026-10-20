#import "../../src/lib.typ": *
#show: deixis-setup-notes
#let option = sys.inputs.at("option", default: "render-single")
#deixis-endnote[An explanation.]
#deixis-print-endnotes(..((option): 12))
