#import "@preview/deixis:0.2.0": *
#set page(width: 480pt, height: auto, margin: 35pt)
#set text(size: 11pt)
#show: deixis-setup-notes

#text(size: 19pt, weight: "bold")[Connect To A Collected Explanation]

An annotation#deixis-endnote(id: <detail>)[
  The explanation begins here. It stays under the printer's control.

  A longer body can continue onto later pages. Its end point follows the last
  printed fragment, wherever native pagination puts it.
] can connect to either end of its body.

#deixis-connect(from: <detail>, to: (body: <detail>, point: "start"),
  connector: (route: "curve", stroke: teal + 0.8pt, heads: (body: "triangle"),
    ports: (mark: bottom, body: (side: left, gap: 4pt))))
#deixis-connect(from: <detail>, to: (body: <detail>, point: "end"),
  connector: (route: "curve", stroke: orange.darken(20%) + 0.8pt, heads: (body: "circle"),
    ports: (mark: left, body: (side: left, gap: 8pt)),
    via: ((relative-to: "body", offset: (-25pt, -65pt)),
      (relative-to: "body", offset: (-25pt, 0pt)))))

#v(55pt)
#deixis-print-endnotes()

#v(22pt)
```typst
#deixis-connect(from: <detail>,
  to: (body: <detail>, point: "start"))
#deixis-connect(from: <detail>,
  to: (body: <detail>, point: "end"))
#deixis-print-endnotes()
```

Start and end are points in the live body content. They do not change wrapping,
reserve space, or request another printing. The same selectors work for native
footnotes and ordinary flow bodies.
