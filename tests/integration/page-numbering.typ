#import "../../src/lib.typ": *
#set page(width: 350pt, height: 400pt, margin: 28pt, numbering: "1")
#set text(size: 11pt)
#show: deixis-setup-notes
#let mode = sys.inputs.at("mode", default: "contracts")
#let symbols = sys.inputs.at("symbols", default: "false") == "true"
#let named = sys.inputs.at("named", default: "true") == "true"
#let pattern = if symbols { "*" } else { "1" }
#let policy(key) = (restart: "page", pattern: n => [
  #metadata((key: key, value: n))<page-numbered-marker>#numbering(pattern, n)
])
#let f(key, body, ..args) = deixis-footnote(body, data: (key: key),
  numbering: policy(key), layer: sys.inputs.at("layer", default: "flow"), ..args)
#if mode == "contracts" [
  A forward reuse#deixis-mark(of: <future>).
  #f("one", id: <one>)[FIRST_BODY]
  #f("other", id: <other>, series: "other")[OTHER_BODY]
  #deixis-block(id: <local>)[
    Local one#f("local-one", id: <local-one>)[LOCAL_ONE_BODY].
    Local two#f("local-two", id: <local-two>)[LOCAL_TWO_BODY].
  ]
  #hide[Hidden note#f("hidden", id: <hidden>)[HIDDEN_ONLY_BODY].]
  #deixis-set(omit: (series: ("omit",)))
  #f("omitted", id: <omitted>, series: "omit")[OMITTED_BODY]
  #deixis-set(omit: none)
  After hidden#f("after-hidden", id: <after-hidden>)[AFTER_HIDDEN_BODY].
  #pagebreak()
  #counter(page).update(1)
  Future original#f("future", id: <future>)[FUTURE_BODY].
  An anonymous note#f("anonymous")[ANONYMOUS_BODY].
  #deixis-update-note-counter(20)
  After manual update#f("updated", id: <updated>)[UPDATED_BODY].
  #f("forced", id: <forced>, marker: [X])[FORCED_BODY]
  After custom marker#f("after-forced", id: <after-forced>)[AFTER_FORCED_BODY].
  #pagebreak()
  A reference #deixis-ref(<one>) and a reuse#deixis-mark(of: <future>).
  References: #deixis-ref(<updated>, <one>, <future>).
  #deixis-note-outline()
] else if mode == "natural" or mode == "columns" [
  #let n = int(sys.inputs.at("n", default: "40"))
  #let contents = [#for i in range(n) [
    Paragraph #i#f("natural-" + str(i), id: if named { label("natural-" + str(i)) } else { none })[Explanation #i.].
    #lorem(12) #parbreak()
  ]]
  #if mode == "columns" { columns(2, gutter: 18pt, contents) } else { contents }
  #if named [#pagebreak() A later reuse#deixis-mark(of: <natural-0>).]
] else if mode == "long" [
  A split footnote#f("long", id: <long>)[LONG START. #lorem(650) LONG END.].
  #for i in range(6) [Fresh text#f("short-" + str(i))[Short body #i.]. #lorem(35) #parbreak()]
] else if mode == "nested" [
  Outer#f("outer", id: <outer>)[An inner annotation#deixis-inline-note(
    id: <inner>, data: (key: "inner"), numbering: policy("inner"))[INNER BODY]. #lorem(20)].
  After#f("after", id: <after>)[AFTER BODY].
] else if mode == "forward-body" [
  #deixis-footnote-body(of: <later>)[ATTACHED EARLY BODY]
  #pagebreak()
  Later original#deixis-inline-mark(id: <later>, data: (key: "later"), numbering: policy("later")).
  #f("next", id: <next>)[NEXT BODY]
] else if mode == "phantom" [
  #deixis-phantom-mark(id: <phantom>, data: (key: "phantom"), numbering: policy("phantom"))
  #deixis-footnote-body(of: <phantom>)[PHANTOM BODY]
  #f("after-phantom", id: <after-phantom>)[AFTER PHANTOM BODY]
] else if mode == "region" [
  #deixis-mark(id: <region>, data: (key: "region"), mark-type: "region", inline: true,
    numbering: policy("region"), layer: "background")[$x^2$]
  #deixis-footnote-body(of: <region>)[REGION BODY]
  #pagebreak()
  #f("new", id: <new>)[NEW BODY]
  #deixis-mark(of: <region>).
] else if mode == "replay" [
  #set page(header: context {
    let previous = query(selector(heading).before(here()))
    if previous.len() > 0 { deixis-plain(previous.last().body) }
  })
  = Heading#f("heading", id: <heading-note>)[HEADING BODY]
  Following#f("following", id: <following>)[FOLLOWING BODY].
  #outline()
  #pagebreak()
  New page#f("new", id: <new>)[NEW PAGE BODY].
] else if mode == "scopes" [
  #deixis-block(id: <first>)[A#f("first")[FIRST LOCAL].]
  #deixis-block(id: <synced>, sync-counters-with: <first>)[B#f("synced")[SHARED COUNTER].]
  #deixis-block(id: <independent>)[C#f("independent")[INDEPENDENT COUNTER].]
] else { panic("Unknown page-numbering test mode") }
#context {
  let notes = deixis-query-notes()
  let events = query(<page-numbered-marker>).map(m => m.value)
  let expected = if mode == "contracts" {
    assert.eq(deixis-note-counter(), 23)
    assert.eq(notes.find(n => n.id == <updated>).count, 21)
    assert.eq(notes.find(n => n.id == <after-forced>).count, 23)
    assert(not notes.any(n => n.id == <omitted>))
    assert.eq(notes.find(n => n.id == <future>).marks.len(), 3)
    (one: 1, other: 1, local-one: 1, local-two: 2, hidden: 2,
      after-hidden: 3, future: 1, anonymous: 2, updated: 3, forced: 4, after-forced: 5)
  } else if mode == "scopes" { (first: 1, synced: 2, independent: 1) } else {
    let result = (:)
    // Independent oracle: monotone assigned counts order each page's stream.
    for note in notes {
      let page = note.marks.find(m => m.original).dest.page()
      let peers = notes.filter(n => n.marks.find(m => m.original).dest.page() == page).sorted(key: n => n.count)
      result.insert(note.data.key, peers.position(n => n.data.key == note.data.key) + 1)
    }
    result
  }
  for note in notes {
    if note.data.key == "forced" { continue }
    let observed = events.filter(e => e.key == note.data.key)
    assert(observed.len() > 0, message: "Missing printed marker for " + note.data.key)
    assert(observed.all(e => e.value == expected.at(note.data.key)), message: repr((note.data.key, observed, expected)))
  }
  assert.eq(counter(footnote).final(), (0,))
  if mode == "long" {
    let body = notes.find(n => n.id == <long>).body
    assert(body.end.page() > body.start.page())
  }
  if mode == "forward-body" {
    let note = notes.find(n => n.id == <later>)
    assert(note.body.start.page() < note.marks.first().dest.page())
  }
  [#metadata((mode: mode, pages: here().page(), notes: notes.len(),
    original_pages: notes.map(n => n.marks.find(m => m.original).dest.page()).dedup().len(),
    evidence: events.len()))<page-numbering-result>]
}
