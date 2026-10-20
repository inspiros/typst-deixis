#import "../../src/lib.typ": *
#set page(width: 360pt, height: 200pt, margin: 25pt)
#show: deixis-setup-notes
#let mode = sys.inputs.at("mode", default: "original")
#deixis-block[
  #if mode in ("body", "occurrence") { [#deixis-mark(id: <head>)[Column].] }
  #table(columns: 1, inset: 8pt,
    table.header[
      #if mode == "original" { deixis-mark(id: <head>)[Column] } else if mode == "body" {
        deixis-footnote-body(of: <head>)[Repeated Body]
        [Column]
      } else if mode == "occurrence" { deixis-mark(of: <head>, occurrence: <header>)[Column] } else {
        deixis-block(id: <repeated>)[Column]
      }
    ],
    ..range(20).map(i => [Row #i. #lorem(7)]))
]
