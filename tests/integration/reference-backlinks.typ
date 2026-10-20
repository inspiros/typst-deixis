#import "../../src/lib.typ": *
#import "../../src/core/references.typ": *
#import "../../src/render/body.typ": _deixis-should-render-backlinks
#set page(width: 500pt, height: 430pt, margin: 40pt)
#show: deixis-setup-notes
#deixis-set(marker-style: it => it)
Paired#deixis-inline-mark(id: <paired>, series: "endnote").
#deixis-endnote-body(of: <paired>, backlink: "multiple")[Paired body.]
#deixis-endnote-body(id: <solo-id>, backlink: "multiple")[Standalone with two reference sites.]
#deixis-endnote-body(id: <single>, backlink: "multiple")[Standalone with one reference site.]
#deixis-inline-note-body(id: <inline>, inline: true, backlink: true)[Inline standalone.]
#metadata((unrelated: true))<ordinary>

#pagebreak()
Aliases: #deixis-ref(<paired>, <paired>, <deixis-mark-id-paired>, <deixis-body-id-paired>).
Again: @paired.
Solo: #deixis-ref(<solo-id>, <solo-id>) and @solo-id.
Single: @single.
Inline: @inline.
#deixis-print-endnotes()
#context {
  let index = _deixis-reference-index()
  let sites = _deixis-reference-sites()
  assert.eq(_deixis-reference-target(index, <ordinary>), none)
  let paired = _deixis-reference-target(index, <paired>)
  let solo = _deixis-reference-target(index, <solo-id>)
  let single = _deixis-reference-target(index, <single>)
  let inline-note = _deixis-reference-target(index, <inline>)
  assert.eq(paired.uid, _deixis-reference-target(index, <paired>).uid)
  assert.eq(solo.uid, _deixis-reference-target(index, <solo-id>).uid)
  assert.eq(sites.at(paired.uid).len(), 2)
  assert.eq(sites.at(solo.uid).len(), 2)
  assert.eq(sites.at(single.uid).len(), 1)
  assert.eq(sites.at(inline-note.uid).len(), 1)
  for data in query(<deixis-endnote>).map(n => n.value) {
    assert.eq(_deixis-should-render-backlinks(data), data.id != <single>)
    assert(not _deixis-should-render-backlinks(data + (disable-links: true)))
  }
  assert.eq(query(<deixis-ref-marker>).len(), 6)
  let targets = ((paired, solo, single, inline-note).map(n => n.dest) +
     (index.locations.at("deixis-mark-id-paired"),) + sites.at(paired.uid) + sites.at(solo.uid) + sites.at(inline-note.uid))
  [#metadata((destinations: targets.map(loc => (
    page: loc.page(), x: loc.position().x.pt(), y: loc.position().y.pt(),
  ))))<test-result>]
}
