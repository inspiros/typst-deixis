#import "@preview/deixis:0.2.0": *
#set page(width: 580pt, height: 310pt, margin: (left: 32pt, right: 160pt, y: 28pt))
#set text(size: 11pt)
#show: deixis-setup-notes
#deixis-set(palette: (rgb("3B6D9A"), rgb("387C69"), rgb("9A663F")))

= Keep The Detail Close

Let the main argument stay readable, with explanations beside it.

#v(14pt)
Our #deixis-margin-note(id: <method>, width: 115pt, side: right,
  connector: (route: "orthogonal", radius: 3pt),
)[method][A short explanation stays beside the passage it describes.]
uses one annotation for one idea.

#v(18pt)
The #deixis-margin-note(width: 115pt, side: right,
  connector: (route: "orthogonal", radius: 3pt),
)[result][Each new annotation receives the next palette color.]
has its own explanation and color.

#v(18pt)
#deixis-mark(of: <method>)[A related passage] shares the first number and body.
See also @method.

A small detail#deixis-footnote[Footnotes use the native page footer.]
belongs at the bottom of the page.
