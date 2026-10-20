#import "../../src/lib.typ": *
#show: deixis-setup-notes
#let mode = sys.inputs.at("mode", default: "meta")
#let kind = sys.inputs.at("kind", default: "inset")
#let standalone = sys.inputs.at("standalone", default: "off") == "on"
#let owner = if standalone { (id: <item>,) } else { (of: <item>,) }
#let renderer(data, ..args) = {
  if mode == "meta" { [#deixis-generate-body-meta(data)#data.body#deixis-generate-body-meta(data)] }
  else if mode == "marker" { [#deixis-generate-body-marker(data)#data.body#deixis-generate-body-meta(data)] }
  else { [#deixis-native-render-single(data, ..args.named())#deixis-native-render-single(data, ..args.named())] }
}
#if not standalone { deixis-mark(id: <item>, mark-type: "phantom") }
#{
  if kind == "footnote" { deixis-footnote-body(..owner, layer: "flow", render-single: renderer)[One body.] }
  else if kind == "endnote" {
    deixis-endnote-body(..owner)[One body.]
    deixis-print-endnotes(render-group: deixis-native-render-group, render-single: renderer)
  } else { deixis-inset-note-body(..owner, layer: "foreground", render-single: renderer)[One body.] }
}
Following allocation anchor.
