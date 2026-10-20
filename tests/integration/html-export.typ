// HTML export: every body reaches the page, markers and backlinks resolve, and
// paged-only geometry (page layers, connectors, regions, pins) is omitted
// without Deixis warnings. Also compiled as an ordinary paged fixture.
#import "../../src/lib.typ": *
#set document(title: "HTML Export")
#show: deixis-setup-notes
#deixis-set(backlink: true)

= HTML Export

A claim#deixis-footnote(id: <flow-foot>)[Flow footnote body.] with an
overlay#deixis-footnote(layer: "foreground")[Overlay footnote body.] footnote,
a #deixis-margin-note(id: <margin>, connector: "curve")[margin][Margin body.]
note, a #deixis-sidenote[sidenote][Sidenote body.] and an
immediate #deixis-margin-note(layer: "flow")[margin][Immediate margin body.] note.

An #deixis-inset-note(dx: 20pt, dy: 20pt, width: 90pt)[inset][Inset body.] callout,
a flow #deixis-inset-note(layer: "flow")[inset][Flow inset body.] callout, an
#deixis-inline-note[aside][Inline note body.] and an
endnote#deixis-endnote(id: <end>)[Endnote body.].

A #deixis-comment(author: "Ada", status: "open")[comment][Comment body.] and a
#deixis-region-mark(id: <region>, layer: "background")[region passage]
explained in the margin.
#deixis-margin-note-body(of: <region>)[Region margin body.]

#deixis-phantom-mark(id: <phantom>)Attached bodies.
#deixis-inset-note-body(of: <phantom>)[Attached inset body.]
#deixis-margin-note-body[Standalone margin body.]

Pinned #deixis-pin("from")start and #deixis-pin("to")end.
#deixis-connect(from: (pin: "from"), to: (pin: "to"))
#deixis-connect(from: <margin>, to: (body: <margin>))
References: @flow-foot, @end, @margin and #deixis-mark(of: <margin>)[a reused mark].

#deixis-block(id: <local>)[
  A local#deixis-footnote[Local block footnote body.] note.
]

#deixis-print-endnotes()
#deixis-note-outline()
