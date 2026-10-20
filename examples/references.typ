#import "@preview/deixis:0.2.0": *
#set page(width: 460pt, height: 330pt, margin: 35pt, numbering: "1")
#set text(size: 11pt)
#show: deixis-setup-notes
#deixis-set(backlink: "multiple")
#show link: set text(fill: rgb("27645e"))

#text(size: 19pt, weight: "bold")[Notes You Can Revisit]

A mark introduces a note#deixis-endnote(id: <mark>)[
  The mark and body share an identity.
]. Its body can appear later#deixis-endnote(id: <body>)[
  The printer collects these three bodies.
]. References connect them#deixis-endnote(id: <links>)[
  Backlink hooks return to the mark and to each reference site.
].

Return to the first note: @mark.
Find its page: #ref(<mark>, form: "page").

Or refer to several at once: #deixis-ref(<links>, <mark>, <body>)[Notes].

#deixis-print-endnotes()
