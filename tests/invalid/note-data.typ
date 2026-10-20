#import "../../src/lib.typ": *
#show: deixis-setup-notes
#let kind = sys.inputs.at("kind", default: "mark")
#let mode = sys.inputs.at("mode", default: "type")
#let data = if mode == "type" { ("invalid",) } else { (title: "override",) }
#let args = if mode == "inherit" { (of: <idea>, data: data) } else { (id: <test>, data: data) }
#deixis-mark(id: <idea>)[Original]
#{
if kind == "mark" { deixis-mark(..args)[Passage] }
else if kind == "inline-mark" { deixis-inline-mark(..args)[Passage] }
else if kind == "region-mark" { deixis-region-mark(..args, inline: true)[Passage] }
else if kind == "phantom-mark" {
  if mode == "anonymous" { deixis-phantom-mark(data: data) }
  else { deixis-phantom-mark(..args) }
}
else if kind == "inline" { deixis-inline-note-body(..args)[Body] }
else if kind == "footnote-body" { deixis-footnote-body(..args)[Body] }
else if kind == "endnote-body" { deixis-endnote-body(..args)[Body] }
else if kind == "margin-body" { deixis-margin-note-body(..args)[Body] }
else if kind == "inset-body" { deixis-inset-note-body(..args)[Body] }
else if kind == "sidenote-body" { deixis-sidenote-body(..args)[Body] }
else if kind == "footnote" { deixis-footnote(..args)[Body] }
else if kind == "endnote" { deixis-endnote(..args)[Body] }
else if kind == "margin" { deixis-margin-note(..args)[Body] }
else if kind == "inset" { deixis-inset-note(..args)[Body] }
else if kind == "sidenote" { deixis-sidenote(..args)[Body] }
}
