#import "../../src/lib.typ": *
#set page(width: 260pt, height: auto, margin: 12pt)
#set text(size: 13pt)
#show: deixis-setup-notes

// BEGIN EXAMPLE
An idea#deixis-endnote(id: <idea>)[
  One explanation for both uses.
] appears again#deixis-mark(of: <idea>).

A new idea#deixis-endnote[
  A second explanation.
] gets a new number.

#deixis-print-endnotes()
// END EXAMPLE
