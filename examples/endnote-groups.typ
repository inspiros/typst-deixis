#import "@preview/deixis:0.2.0": *
#set page(width: 470pt, height: 420pt, margin: 45pt)
#set text(size: 11pt)
#show: deixis-setup-notes

= Collect Notes By Topic

This overview has a reading note#deixis-endnote[A short explanation for the reader.]
and a technical note#deixis-endnote(series: "technical")[A detail for readers who want more depth.].

== Reading Notes
#deixis-print-endnotes(series: "endnote")

== Technical Notes
#deixis-print-endnotes(series: "technical")

#v(15pt)
A later paragraph adds another reading note#deixis-endnote[This note was added after the first collection.].

== Later Reading Notes
// Earlier bodies have already been printed. Only the new body appears here.
#deixis-print-endnotes(series: "endnote")
