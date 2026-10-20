#import "../../src/lib.typ": *
#set page(width: 360pt, height: 240pt, margin: (left: 24pt, right: 120pt, y: 24pt))
#show: deixis-setup-notes
// The preset is a lettered margin note in the "review" series whose data always
// carries author/status. The final build omits the series, keeping passages.
#let final = sys.inputs.at("final", default: "false") == "true"
#deixis-set(omit: if final { (series: ("review",)) } else { none })
A #deixis-comment(id: <a>, author: "Ada", status: "open")[claim][Check.]
and a source#deixis-footnote(id: <src>)[Kept.].
#deixis-comment(id: <b>, author: "Lin", data: (title: "Wording"), header: d => [Re: #d.title])[Reword.]
#deixis-comment(id: <c>, header: none, numbering: "i")[plain][No header.]
#deixis-mark(of: <a>)[again]
#context {
  let notes = deixis-query-notes(include-unpaired: true)
  let review = notes.filter(n => n.series == "review")
  if final {
    assert.eq(review, ())
    assert.eq(notes.map(n => (str(n.id), n.marker)), (("src", "1"),))
  } else {
    assert.eq(review.map(n => (str(n.id), n.marker, n.type)),
      (("a", "A", "margin-note"), ("b", "B", "margin-note"), ("c", "iii", "margin-note")))
    assert.eq(review.map(n => n.data), ((author: "Ada", status: "open"),
      (title: "Wording", author: "Lin", status: none), (author: none, status: none)))
    assert.eq(notes.find(n => str(n.id) == "src").marker, "1")
  }
}
