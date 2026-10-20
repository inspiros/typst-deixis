#import "../../src/lib.typ": *
#set page(width: 260pt, height: auto, margin: 12pt)
#set text(size: 13pt)
#show: deixis-setup-notes

// BEGIN EXAMPLE
#deixis-endnote(id: <method>,
  data: (title: [Explain The Method]),
)[The method needs context.]
#deixis-mark(of: <method>)
#deixis-print-endnotes()

#deixis-note-outline(
  title: [Review Topics],
  summary: n => n.data.title,
)
// END EXAMPLE
