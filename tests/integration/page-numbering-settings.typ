#import "../../src/lib.typ": *
#set page(width: 350pt, height: 400pt, margin: 28pt)
#show: deixis-setup-notes
#deixis-set(numbering: (restart: "page", pattern: n => [#metadata(n)<setting-number>#n]))
#deixis-footnote(id: <one>)[One.]
#deixis-footnote(id: <two>)[Two.]
#deixis-block[
  #deixis-set(numbering: "i")
  #deixis-footnote(id: <local>)[Local roman.]
]
#pagebreak()
#deixis-footnote(id: <three>)[Page two.]
#deixis-set(numbering: "1")
#deixis-footnote(id: <four>)[Global counter continues.]
#let forward-policy = (restart: "page", pattern: n => [#metadata(n)<forward-page-number>#n])
#deixis-mark(id: <early-owned>, target: <later-owner>, numbering: forward-policy)
#deixis-footnote-body(of: <early-owned>)[Forward-owned body.]
#deixis-block(id: <later-owner>)[
  Local#deixis-footnote(numbering: forward-policy)[Local body.].
]
#context {
  let values = query(<setting-number>).map(m => m.value)
  assert(values.all(v => v in (1, 2)))
  assert(values.filter(v => v == 1).len() == 4)
  assert(values.filter(v => v == 2).len() == 2)
  assert.eq(deixis-note-counter(), 4)
  assert.eq(query(<forward-page-number>).map(m => m.value), (1, 2, 1, 2))
}

// Plain decimal policies must preserve caller order rather than form ranges
// from unrelated page-local ordinals. Bodies deliberately collect later.
#pagebreak()
#deixis-block(id: <reference-owner>)[
  #let note = deixis-footnote.with(numbering: (restart: "page", pattern: "1"))
  A#note(id: <rank-a>)[A body.]
  B#note(id: <rank-b>)[B body.]
  C#note(id: <rank-c>)[C body.]
  #colbreak()
  D#note(id: <rank-d>)[D body.]
  #colbreak()
  References: #deixis-ref(<rank-c>, <rank-d>, <rank-b>, <rank-a>).
]

#deixis-block[
  #deixis-update-note-counter(-5)
  Signed counter#deixis-footnote(numbering: (restart: "page", pattern: n => {
    assert.eq(n, 1)
    str(n)
  }))[The assigned count is negative; its display ordinal is positive.]
  #context assert.eq(deixis-note-counter(), -4)
]

// A nested record replaces its parent record; an omitted pattern means "1".
#deixis-block[
  #deixis-set(numbering: (restart: "page", pattern: "a"))
  #deixis-set(numbering: (restart: "page"))
  Nested record#deixis-footnote[Default pattern.]
]
