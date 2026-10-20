#import "../../src/lib.typ": *
#show: deixis-setup-notes
#let consumer = sys.inputs.at("consumer", default: "printer")
#let call = if consumer == "printer" { deixis-print-endnotes } else { deixis-note-outline }
#call(after: <missing-boundary>)
