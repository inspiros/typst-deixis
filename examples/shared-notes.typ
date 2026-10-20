#import "@preview/deixis:0.2.0": *
#set page(width: 480pt, height: auto, margin: 35pt)
#set text(size: 11pt)
#show: deixis-setup-notes
#deixis-set(backlink: "multiple")
#show link: set text(fill: rgb("27645e"))

#text(size: 19pt, weight: "bold")[One Explanation, Many Marks]

Introduce an idea#deixis-endnote(id: <shared>)[
  One body serves every occurrence. Return links lead back to each passage.
]. Mention it again#deixis-mark(of: <shared>).

The same note can also decorate
#deixis-inline-mark(of: <shared>, inline-mode: "underline")[a later passage].

A different idea gets the next number#deixis-endnote[
  Repeated marks do not advance the counter or print another copy.
].

#deixis-print-endnotes()
