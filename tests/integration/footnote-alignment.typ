#import "../../src/lib.typ": *
#set page(width: 320pt, height: 300pt, margin: 35pt)
#show: deixis-setup-notes
#for words in (7, 41) {
  pagebreak(weak: true)
  [One#deixis-footnote[#lorem(words)]]
  [Two#deixis-footnote(marker: [A very long marker])[#lorem(words)]]
  [Three#deixis-footnote[#lorem(words)]]
}
#context [#metadata(query(<deixis-rendered-end>).map(n => (
  page: n.location().page(), y: n.location().position().y.pt(),
)))<test-result>]
