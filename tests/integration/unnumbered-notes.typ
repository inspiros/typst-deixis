#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#set page(width: 480pt, height: 620pt, margin: (right: 140pt, rest: 30pt))
#set text(size: 10pt)
#show: deixis-setup-notes

// Factory, per-call and family defaults share one assigned stream.
First#deixis-footnote(id: <first>)[First Footnote.]
#deixis-mark(of: <aside>, occurrence: <early>)[Forward Reuse]
#deixis-margin-note(id: <aside>, numbering: none, backlink: true)[Passage][Margin Aside.]
Second#deixis-footnote(id: <second>)[Second Footnote.]
#deixis-set(numbering: (margin-note: none, inset-note: none))
#deixis-margin-note(id: <family-margin>)[Family Margin][Family Margin Aside.]
#deixis-inset-note(id: <family-inset>)[Family Inset][Family Inset Aside.]
#deixis-margin-note(id: <fixed-aside>, marker: "!")[Fixed Passage][Fixed Marker Aside.]
Third#deixis-footnote(id: <third>)[Third Footnote.]
#context assert.eq(deixis-note-counter(), 3)

// Hiding a marker alone, or fixing it with ordinary numbering, still counts.
Hidden#deixis-footnote(id: <marker-none>, marker: none)[Hidden Marker Footnote.]
Fixed#deixis-footnote(id: <fixed-numbered>, marker: "X")[Fixed Numbered Footnote.]
#deixis-mark(of: <aside>, occurrence: <later>)[Later Reuse]
Markerless Reference: #deixis-ref(<aside>, marker-style: value => {
  assert.eq(value, "?")
  [REF_UNNUMBERED]
}). Fixed Reference: #deixis-ref(<fixed-aside>, marker-style: value => {
  assert.eq(value, "!")
  [REF_FIXED]
}).
#context assert.eq(deixis-note-counter(), 5)

#pagebreak()
// Every original mark kind and body adapter accepts a nullable count.
#deixis-footnote(id: <unnumbered-foot>, numbering: none)[Unnumbered Footnote.]
#deixis-endnote(id: <unnumbered-end>, numbering: none)[Unnumbered Endnote.]
#deixis-inline-note(id: <unnumbered-inline>, numbering: none)[Inline Passage][Inline Aside.]
#deixis-footnote-body(of: <region>)[Forward Attached Region Body.]
#deixis-region-mark(id: <region>, numbering: none, inline: true)[Region Passage]
#deixis-phantom-mark(id: <phantom>, numbering: none)
#deixis-footnote-body(of: <phantom>)[Phantom Body.]
#deixis-print-endnotes()
#deixis-block(id: <local-owner>)[
  #deixis-set(numbering: none)
  #context assert.eq(deixis-note-counter(), 0)
  #deixis-footnote(id: <local-aside>)[Local Unnumbered Body.]
  #context assert.eq(deixis-note-counter(), 0)
  #deixis-footnote(id: <local-first>, numbering: "1")[Local First Numbered Body.]
  #deixis-inset-note(id: <local-inset>)[Local Inset][Local Family Aside.]
  #deixis-footnote(id: <local-second>, numbering: "1")[Local Second Numbered Body.]
  #context assert.eq(deixis-note-counter(), 2)
]
#context {
  assert.eq(deixis-note-counter(), 5)
  assert.eq(deixis-note-counter(target: <local-owner>), 2)
  assert.eq(deixis-note-counter(series: "endnote"), 0)
}

#pagebreak()
// Page ordinals skip unnumbered originals, including hidden and fixed ones.
#let page-note(key, body) = deixis-footnote(id: label(key), series: "paged",
  numbering: (restart: "page", pattern: n => [#metadata((key: key, value: n))<unnumbered-page-marker>#n]), body)
#page-note("page-first")[Page First.]
#deixis-margin-note(id: <page-aside>, series: "paged")[Page Aside][Unnumbered Page Aside.]
#hide[#deixis-phantom-mark(id: <hidden-aside>, series: "paged", numbering: none)]
#deixis-footnote(id: <page-fixed>, series: "paged", numbering: none, marker: "!")[Unnumbered Fixed Page Body.]
#deixis-set(omit: (series: ("omitted",)))
#deixis-footnote(id: <omitted-aside>, series: "omitted", numbering: none)[Omitted Aside.]
#deixis-set(omit: none)
#page-note("page-second")[Page Second.]
#deixis-footnote(id: <page-counted>, series: "paged", marker: none)[Counted Markerless Page Body.]
#page-note("page-fourth")[Page Fourth.]
#context assert.eq(deixis-note-counter(series: "paged"), 4)
#pagebreak()
#page-note("next-page")[New Page First.]
#deixis-mark(of: <page-aside>)[Reused Page Aside]

#deixis-note-outline(title: none, include-types: "margin-note", summary: note => {
  assert.eq(note.count, none)
  assert(note.marker == none or note.id == <fixed-aside>)
  note.summary
})
#context {
  let registry = deixis-system.final().registry.value
  assert("endnote" not in registry.counters.at("page"))
  let notes = deixis-query-notes(include-unpaired: true)
  let selected(id) = notes.find(n => n.id == id)
  for id in (<aside>, <family-margin>, <family-inset>, <fixed-aside>, <unnumbered-foot>,
    <unnumbered-end>, <unnumbered-inline>, <region>, <phantom>, <local-aside>,
    <local-inset>, <page-aside>, <hidden-aside>, <page-fixed>) {
    let original = registry.notes.at(registry.id-index.at(str(id)))
    assert.eq(original.numbering, none)
    assert.eq(original.count, none)
    assert(original.count-id != none)
    assert.eq(selected(id).count, none)
    if id not in (<fixed-aside>, <page-fixed>) { assert.eq(selected(id).marker, none) }
  }
  for (id, count) in ((<first>, 1), (<second>, 2), (<third>, 3), (<marker-none>, 4),
    (<fixed-numbered>, 5), (<local-first>, 1), (<local-second>, 2), (<page-first>, 1),
    (<page-second>, 2), (<page-counted>, 3), (<page-fourth>, 4), (<next-page>, 5)) {
    assert.eq(selected(id).count, count)
  }
  assert.eq(selected(<fixed-aside>).marker, "!")
  assert.eq(selected(<aside>).marks.map(m => m.original), (false, true, false))
  assert(selected(<aside>).body.dest != none)
  assert.eq(selected(<page-aside>).marks.len(), 2)
  assert.eq(selected(<omitted-aside>), none)
  assert("omitted-aside" not in registry.id-index)
  assert.eq(deixis-note-counter(series: "paged"), 5)
  let expected = (page-first: 1, page-second: 2, page-fourth: 4, next-page: 1)
  let markers = query(<unnumbered-page-marker>).map(m => m.value)
  for (key, value) in expected {
    let observed = markers.filter(m => m.key == key)
    assert(observed.len() > 0)
    assert(observed.all(m => m.value == value), message: repr((key, observed)))
  }
}
