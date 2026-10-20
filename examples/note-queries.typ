#import "@preview/deixis:0.2.0": *
#set page(width: 510pt, height: 370pt, margin: 38pt,
  header: context {
    let notes = deixis-query-notes(page: here().page(), include-types: "endnote")
    if notes.len() > 0 {
      text(size: 9pt, fill: gray)[Printed notes: #notes.map(n =>
        if n.count == none { [unnumbered] } else { n.marker }).join([, ])]
    }
  },
)
#set text(size: 11pt)
#show: deixis-setup-notes

#text(size: 19pt, weight: "bold")[Query Notes In Reading Order]

The header follows printed body order when numbering restarts.

#deixis-update-note-counter(7, series: "reading")
First passage#deixis-endnote(id: <first>, series: "reading")[An earlier note numbered eight.]
#deixis-update-note-counter(0, series: "reading")
Later passage#deixis-endnote(id: <later>, series: "reading")[A later note numbered one.]
#deixis-endnote-body(id: <aside>, series: "reading")[An unnumbered explanation in the same collection.]

#deixis-print-endnotes(series: "reading")

#deixis-note-outline(title: [Notes In Source Order], include-types: "endnote",
  series: "reading", include-unpaired: "body")
