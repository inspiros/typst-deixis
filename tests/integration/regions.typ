#import "../../src/lib.typ": *
#set page(width: 410pt, height: 300pt, margin: 40pt)
#show: deixis-setup-notes
#deixis-region-mark(id: <region>, pins: ("start", "end"), layer: "background")
#deixis-pin("start")A region over three pages.
#pagebreak()
Middle page.
#pagebreak()
Last page.#deixis-pin("end")
#deixis-inset-note-body(of: <region>, layer: "foreground", dx: 10pt, dy: 10pt,
  connector: "right-angle", width: 80pt)[Region note.]
#context [#metadata(query(<deixis-rendered-start>).map(n => n.location().page()))<test-result>]
