#import "@preview/deixis:0.2.0": *
#set page(width: 470pt, height: auto, margin: 30pt)
#set text(size: 11pt)
#show: deixis-setup-notes
#show heading: set text(fill: rgb("27645e"))
// Native heading rules can restart just one stream at each section.
#show heading.where(level: 2): it => {
  deixis-update-note-counter(0, target: "page", series: "notes")
  it
}

#text(size: 19pt, weight: "bold")[Restart One Series, Keep The Others]

#let note = deixis-endnote.with(series: "notes")
#let todo = deixis-endnote.with(series: "todo", numbering: "a")

== First Section

The argument needs an explanation#note[The first explanation.]
and a revision#todo[Check the opening example.].

#deixis-print-endnotes()

== Second Section

Explanations restart at one#note[The first explanation in this section.],
while revisions continue#todo[Check the final example too.].

#deixis-print-endnotes()

#v(8pt)
```typst
#show heading.where(level: 2): it => {
  deixis-update-note-counter(0, target: "page", series: "notes")
  it
}
```
