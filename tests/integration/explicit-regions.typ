#import "../../src/lib.typ": *
#set page(width: 440pt, height: 290pt, margin: 45pt)
#show: deixis-setup-notes
#let painter(name, request) = {
  [#metadata((name: name, document: request.route.document))<explicit-region-route>]
}
#deixis-pin("region-pins", padding: 0pt)First region fragment.
#deixis-region-mark(id: <region>, pins: ("region-pins",), layer: "background")
#v(130pt)
#pagebreak()
Middle region fragment.
#v(130pt)
#pagebreak()
Final region fragment.#deixis-pin("region-pins", padding: 0pt)
#deixis-inset-note-body(of: <region>, connector: none, width: 75pt, layer: "foreground",
  placement: it => place(top + right, it))[Same-page body.]
#deixis-connect(from: <region>, to: <region>, connector: (route: "curve", render: painter.with("region")))
#pagebreak()
#deixis-phantom-mark(id: <phantom>)Phantom source.
#deixis-margin-note-body(of: <phantom>, connector: none, width: 70pt, side: right)[Phantom body.]
#deixis-connect(from: <phantom>, to: <phantom>, connector: (route: "straight-line", render: painter.with("phantom")))
