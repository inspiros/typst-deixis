#import "../../src/lib.typ": *
#import "../../src/core/references.typ": _deixis-reference-index, _deixis-reference-target, _deixis-reference-sites
#set page(width: 500pt, height: 390pt, margin: 45pt, numbering: "i")
#set heading(numbering: "1.")
#set math.equation(numbering: "(1)")
// An earlier target-specific native rule survives the Deixis bridge.
#show ref.where(target: <custom-heading>): it => [Custom heading]
#show: deixis-setup-notes
// A later wrapper can style both note and native references without replacing them.
#show ref: it => text(fill: blue, it)
#deixis-set(marker-style: it => it)
#let supplements = state("reference-supplement-calls", 0)
#let note-prefix(element) = {
  assert.eq(element.func(), metadata)
  assert.eq(element.value.body-type, "endnote")
  assert.eq(element.location().page(), 2)
  [#supplements.update(n => n + 1)Collected]
}
= Heading <heading>
= Custom heading <custom-heading>
#figure(rect(width: 20pt, height: 12pt), caption: [Native figure.])<figure>
$ x = 1 $ <equation>
Native#footnote[Native footnote.]<native-footnote>.
Source#deixis-inline-mark(id: <claim>, series: "endnote").
#deixis-endnote-body(of: <claim>, backlink: true)[Collected body.]
Second#deixis-endnote(id: <second>)[Second body.]
Third#deixis-endnote(id: <third>)[Third body.]
Unprinted#deixis-inline-mark(id: <pending>, series: "pending").
#deixis-endnote-body(of: <pending>)[Pending body.]
#deixis-endnote-body(id: <orphan>, series: "pending")[Unprinted standalone.]
#deixis-endnote-body(id: <standalone>)[Printed standalone.]
#deixis-endnote-body(id: <bare-id>)[Printed without a public label.]

Native: @heading; @custom-heading; @figure; @equation; @native-footnote.

Normal: @claim. Callback: #deixis-ref(<claim>, supplement: note-prefix).
Range: #deixis-ref(<third>, <second>, <claim>, supplement: note-prefix).
Mixed: #deixis-ref(<claim>, <heading>, supplement: element => if element.func() == metadata { [Note] } else { [Heading] }).
Empty prefix: #deixis-ref(<claim>, supplement: element => []).

Page: #ref(<claim>, form: "page"). Alias page: #ref(<claim>, form: "page", supplement: [At]).
Direct page: #deixis-ref(<claim>, <claim>, form: "page", supplement: note-prefix).
Native page: #ref(<heading>, form: "page", supplement: none).
Mark page: #ref(<pending>, form: "page", supplement: none).
Missing page: #deixis-ref(<orphan>, form: "page").
Pending supplement: #deixis-ref(<orphan>, supplement: element => [Pending]).
Standalone pages: #deixis-ref(<standalone>, <bare-id>, form: "page", supplement: none).
Page list: #deixis-ref(<claim>, <second>, form: "page", supplement: [Pages]).

#pagebreak()
#set page(numbering: "A")
#counter(page).update(7)
#deixis-print-endnotes(series: "endnote")

#set ref(supplement: note-prefix)
Inherited: @claim.
#set ref(supplement: auto)
#context {
  assert.eq(supplements.final(), 4)
  let index = _deixis-reference-index()
  let sites = _deixis-reference-sites()
  let body = _deixis-reference-target(index, <claim>)
  assert.eq(body.dest.page(), 2)
  assert.eq(sites.at(body.uid).len(), 10)
  let pending = _deixis-reference-target(index, <pending>)
  assert.eq(pending.dest.page(), 1)
  assert.eq(_deixis-reference-target(index, <orphan>).dest, none)
  let standalone = _deixis-reference-target(index, <standalone>)
  let bare = _deixis-reference-target(index, <bare-id>)
  assert.eq(standalone.dest.page(), 2)
  assert.eq(bare.dest.page(), 2)
  [#metadata((destinations: (body.dest, pending.dest, standalone.dest, bare.dest).map(loc => (
    page: loc.page(), x: loc.position().x.pt(), y: loc.position().y.pt(),
  ))))<test-result>]
}
