#import "../../src/lib.typ": *
#set page(width: 500pt, height: 400pt, margin: 80pt,
  header: context [#metadata(deixis-query-notes(page: here().page()).map(n => n.type).sorted())<test-result>],
)
#show: deixis-setup-notes
Text#deixis-footnote[Footnote body.]
#deixis-endnote[Endnote body.]
#deixis-print-endnotes()
