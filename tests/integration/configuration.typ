#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#import "../../src/core/config.typ": _deixis-resolve-typed-param
#set page(width: 560pt, height: 430pt, margin: (x: 110pt, y: 40pt))
#show: deixis-setup-notes
#let live = state("configuration-bodies", 0)
#let render(n, ..args) = {
  assert.eq(n.render-single, render)
  assert.eq(type(n.at("render-context", default: none)), dictionary)
  if n.body-type == "inline-note" { assert.eq(args.named(), (:)) }
  assert.eq(n.styles.radius, (:))
  assert.eq(n.indent, 3pt)
  assert.eq(n.marker-gap, 5pt)
  assert.eq(n.backlink, true)
  if not n.at("disable-links", default: false) { [#metadata(n.id)<configured-single>] }
  deixis-native-render-single(n, ..args.named())
}
#let container(body, ..args) = {
  assert.eq(args.named().radius, (:))
  body
}
#let body-style(body) = text(fill: teal, body)
#let group(notes, ..args) = {
  [#metadata(notes.map(n => n.id))<configured-group>]
  deixis-native-render-group(notes, ..args.named())
}
#deixis-set(
  render-single: (body: render), render-group: (body: group),
  container-func: (nodes: container), body-style: (body: body-style),
  indent: (body: 3pt), marker-gap: (nodes: 5pt),
  backlink: (body: true), gap: (body: 4pt),
  clearance: (body: 6pt), separator: (body: none),
)
// Changing dictionary representations replaces the old scope/native structure.
#deixis-set(radius: (body: 3pt))
#deixis-set(radius: (top-left: 8pt))
#deixis-set(radius: (:))
#let expected = ()
#for (i, kind) in ("inline", "footnote", "endnote", "margin", "inset").enumerate() {
  for (j, attached) in (false, true).enumerate() {
    if i > 0 or j > 0 { pagebreak() }
    let id = kind + str(j)
    if attached { deixis-mark(id: id)[Original] }
    let args = if attached { (of: id) } else { (id: id) }
    let body = [#live.update(n => n + 1)Configured body.]
    if kind == "inline" { deixis-inline-note-body(..args, body) }
    // Overlay footnotes exercise the configured group renderer (flow is native).
    else if kind == "footnote" { deixis-footnote-body(..args, layer: "foreground", body) }
    else if kind == "endnote" { deixis-endnote-body(..args, body) }
    else if kind == "margin" { deixis-margin-note-body(..args, width: 80pt, side: right, body) }
    else { deixis-inset-note-body(..args, layer: "foreground", width: 80pt, dy: 65pt, body) }
    [Following native anchor.]
    deixis-print-endnotes()
    expected.push(id)
  }
}
#context {
  assert.eq(live.final(), 10)
  assert.eq(query(<configured-single>).map(m => m.value).sorted(), expected.sorted())
  assert.eq(query(<configured-group>).len(), 4)
  for n in deixis-query-notes(include-unpaired: true) { assert.eq(n.styles.radius, (:)) }
}
#pagebreak()
// Partial scope updates preserve sibling branches; dictionary-form changes
// replace only the affected branch. Native corner values remain incremental.
#deixis-set(radius: (inset-note: (body: (top-left: 2pt)), rest: 1pt))
#deixis-set(radius: (inset-note: (body: (bottom-right: 5pt))))
#context {
  let sys = deixis-system.get()
  assert.eq(_deixis-resolve-typed-param(sys, auto, "radius", "inset-note", component: "body"),
    (top-left: 2pt, bottom-right: 5pt))
  assert.eq(_deixis-resolve-typed-param(sys, auto, "radius", "footnote", component: "body"), 1pt)
}
#deixis-block[
  #deixis-set(radius: (nodes: 7pt))
  #deixis-set(radius: (inset-note: (body: (top-right: 9pt))))
  #context assert.eq(_deixis-resolve-typed-param(deixis-system.get(), auto, "radius", "inset-note", component: "body"),
    (top-right: 9pt))
]
#context assert.eq(_deixis-resolve-typed-param(deixis-system.get(), auto, "radius", "inset-note", component: "body"),
  (top-left: 2pt, bottom-right: 5pt))
