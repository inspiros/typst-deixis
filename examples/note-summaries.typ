#import "@preview/deixis:0.2.0": *
#set page(width: 470pt, height: 430pt, margin: 45pt)
#set text(size: 11pt)
#show: deixis-setup-notes

= A Safe Note Index

A note can contain formatted text#deixis-endnote[An _ordinary_ reading note.]
or compute its text when laid out#deixis-endnote(id: <computed>)[#context [This body is printed on page #here().page().]].

#deixis-print-endnotes()

// Default summaries read static text without running a note body again.
#deixis-note-outline(title: [Automatic Summaries], heading-level: 2)

// Describe contextual-only content explicitly when it needs a useful excerpt.
#deixis-note-outline(title: [Custom Summaries], heading-level: 2,
  summary: note => if note.id == <computed> {
    [A detail computed when the note is laid out.]
  } else {
    [An ordinary reading note.]
  },
)
