#import "@preview/deixis:0.2.0": *
#set page(width: 460pt, height: 270pt, margin: (left: 35pt, right: 130pt, y: 30pt))
#set text(size: 11pt)
#show: deixis-setup-notes

= Spill Regions On Different Pages

A connector to a margin body continues in that body's selected margin channel.
Other destinations use the content width. Both pages resolve their own bounds.

#place(top + left, dx: 260pt, dy: 190pt, deixis-pin(<source>, padding: 0pt))
#place(top + left, dx: 220pt, dy: 180pt, text(size: 9pt)[Source])
#deixis-connect(from: (pin: <source>), to: <detail>, connector: (
  route: "orthogonal", stroke: blue + 0.8pt, heads: "stealth",
  continuation: (shape: "portal", link: "counterpart")))

#v(25pt)
```typst
connector: (spill: auto) // contextual default
connector: (spill: "content")
connector: (spill: "page")
connector: (spill: (left: 20%, right: 80%))
```

#pagebreak()
#set page(width: 400pt, height: 270pt)
= The Local Margin Channel

#deixis-margin-note(id: <detail>, side: right, width: 100pt)[This passage][
  The ring remains in the right margin even though this page is narrower.
]

An exact split still selects its own coordinate. Marker shape and linking are
independent of these placement choices.
