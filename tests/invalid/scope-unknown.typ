#import "../../src/lib.typ": *
#show: deixis-setup-notes
#let kind = sys.inputs.at("kind", default: "mark")
#let missing = if sys.inputs.at("label", default: "off") == "on" { <missing> } else { "missing" }
#{
  if kind == "mark" { deixis-mark(id: <note>, target: missing)[Original] }
  else if kind == "region" { deixis-region-mark(id: <note>, target: missing)[Original] }
  else if kind == "phantom" { deixis-phantom-mark(id: <note>, target: missing) }
  else if kind == "counter" { deixis-update-note-counter(0, target: missing) }
  else if kind == "sync" { deixis-block(sync-counters-with: missing)[Unknown synchronization.] }
  else if kind == "printer" { deixis-print-endnotes(target: missing) }
  else if kind == "inline" { deixis-inline-note-body(target: missing)[Body.] }
  else if kind == "footnote" { deixis-footnote-body(target: missing)[Body.] }
  else if kind == "endnote" { deixis-endnote-body(target: missing)[Body.] }
  else if kind == "margin" { deixis-margin-note-body(target: missing)[Body.] }
  else { deixis-inset-note-body(target: missing)[Body.] }
}
Following native anchor.
