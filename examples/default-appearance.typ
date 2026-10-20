#import "@preview/deixis:0.2.0": *
#set page(width: 560pt, height: 470pt, margin: (left: 32pt, right: 145pt, y: 28pt))
#set text(size: 11pt)
#show: deixis-setup-notes

= Default Marks And Notes

This specimen uses factory appearance. Only placement and body widths are set.

== Marks In Prose

A #deixis-mark[short passage] and #deixis-mark[another annotation] sit in a
sentence alongside a region #deixis-region-mark(inline: true)[$x^2 + y^2 = z^2$].
A solo marker #deixis-mark(of: <inline>) also fits ordinary prose.

== Notes Beside And Within Text

A #deixis-margin-note(width: 110pt)[margin annotation][A brief explanation in the
margin. A second line makes spacing and marker alignment easier to judge.]
keeps the main argument readable.

#v(15pt)
#deixis-mark(id: <inline>)[An inline annotation]
#deixis-inline-note-body(of: <inline>)[This explanation stays in the text.]

#v(15pt)
An #deixis-inset-note(width: 150pt, dx: 150pt, dy: 12pt)[inset annotation][A compact
callout inside the page.]
uses the default body container.

#v(65pt)
A native #deixis-footnote[footnote passage][A footer note with the default text
scale, marker and spacing.] and an #deixis-endnote[endnote passage][A collected
note uses the same factory typography.] complete the comparison.

== Collected Note

#deixis-print-endnotes()
