// HTML placement and navigation regression for inspiros/typst-deixis#1.
// The checker compiles every case with default and explicit backlinks.
// case=nested embeds Deixis footnote and margin notes in an endnote body.
// This fixture also compiles as ordinary paged output without warnings.
#import "../../src/lib.typ": *
#show: deixis-setup-notes
#let case = sys.inputs.at("case", default: "report")
#if sys.inputs.at("backlinks", default: "default") == "true" {
  deixis-set(backlink: true)
}

#if case == "report" [
  hello#deixis-endnote[world]

  more#deixis-endnote[text]

  Before Printer.
  #deixis-print-endnotes()
  After Printer.
] else if case == "series" [
  Alpha#deixis-endnote(series: "alpha")[Alpha First.]
  Beta#deixis-endnote(series: "beta")[Beta First.]
  Alpha#deixis-endnote(series: "alpha")[Alpha Second.]
  Beta#deixis-endnote(series: "beta")[Beta Second.]

  Before Alpha.
  #deixis-print-endnotes(series: "alpha")
  After Alpha.
  Before Beta.
  #deixis-print-endnotes(series: "beta")
  After Beta.
  #deixis-print-endnotes()
] else if case == "nested" [
  Outer#deixis-endnote[
    Outer Body. Nested#deixis-footnote[Nested Footnote Body.]
    and #deixis-margin-note[note][Nested Margin Body.]
  ]

  Before Printer.
  #deixis-print-endnotes()
  After Printer.
] else if case == "references" [
  Named#deixis-endnote(id: <named>)[Named Body.]
  References: #deixis-ref(<named>) and @named.

  Before Printer.
  #deixis-print-endnotes()
  After Printer.
] else if case == "native-nested" [
  Outer#deixis-endnote[Outer Body. Nested#footnote[Native Nested Footnote Body.]]

  Before Printer.
  #deixis-print-endnotes()
  After Printer.
] else if case == "chicago" [
  Chicago#deixis-endnote[Chicago Body.]

  Before Printer.
  #deixis-print-endnotes(render-single: deixis-chicago-render-single)
  After Printer.
] else if case == "page" [
  #deixis-set(numbering: (restart: "page", pattern: "1"))
  First#deixis-endnote[Page First.]
  #context if std.target() != "html" { pagebreak() }
  Second#deixis-endnote[Page Second.]

  Before Printer.
  #deixis-print-endnotes()
  After Printer.
] else if case in ("custom", "custom-native") {
  let custom(note, ..args) = [
    Custom Prefix.
    #deixis-generate-body-marker(note)
    #deixis-generate-body-content(note)
    #deixis-generate-backlinks(note)
  ]
  [Custom#deixis-endnote[Custom Body.]

  Before Printer.
  #deixis-print-endnotes(render-single: custom,
    render-group: if case == "custom-native" { deixis-native-render-group } else { auto })
  After Printer.]
} else { panic("Unknown HTML endnote case: " + case) }
