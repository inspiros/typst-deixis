// After installing Deixis 0.2.0, compile to HTML with:
// typst compile --features html --format html examples/html-endnotes.typ target/html-endnotes.html
#import "@preview/deixis:0.2.0": *
#show: deixis-setup-notes

hello#deixis-endnote[world]

more#deixis-endnote[text]

#deixis-print-endnotes()
