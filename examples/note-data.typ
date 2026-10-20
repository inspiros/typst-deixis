#import "@preview/deixis:0.2.0": *
#set page(width: 560pt, height: auto, margin: 35pt)
#set text(size: 11pt)
#show: deixis-setup-notes

= A Small Review Catalogue

Our #deixis-endnote(id: <method>, data: (
  title: [Explain the method], tags: ("method", "review"), status: "open",
))[method][This paragraph could explain why the method suits the problem.]
needs a clearer explanation.

The #deixis-endnote(id: <result>, data: (
  title: [Check the result], tags: ("result", "review"), status: "done",
))[result][The numerical result has been checked.]
has already been checked.

#deixis-mark(of: <method>)[A second use] shares the first annotation's data.

#deixis-print-endnotes()

// An explicit callback chooses a title instead of the default static excerpt.
#deixis-note-outline(title: [Review Topics], heading-level: 2,
  summary: note => note.data.at("title", default: note.summary))

// Data stays separate from IDs and layout. Ordinary array operations can filter it.
#context {
  let pending = deixis-query-notes().filter(note => note.data.at("status", default: none) == "open")
  table(columns: (auto, 1fr, auto), inset: 6pt,
    table.header([*Note*], [*Pending Topic*], [*Uses*]),
    ..pending.map(note => (link(note.dest, note.marker), note.data.title, str(note.marks.len()))).flatten(),
  )
}
