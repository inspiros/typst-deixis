#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system, _deixis-layout-scopes
#set page(width: 560pt, height: 650pt, margin: (x: 105pt, y: 40pt))
#show: deixis-setup-notes
#let kind = sys.inputs.at("kind", default: "inset")
#let layer = sys.inputs.at("layer", default: "foreground")
#let inside = sys.inputs.at("inner", default: "inside") == "inside"
#let anonymous = sys.inputs.at("scope", default: "named") == "anonymous"
#let live = state("deferred-scope-live", ())
#let body = [
  #live.update(xs => xs + ("outer",))
  #deixis-block(id: if anonymous { auto } else { <local> }, inset: 3pt)[
    Reuse #deixis-mark(of: <inner>, occurrence: <again>)[Local passage].
    Local#deixis-mark(id: <inner>, marker-style: it => text(fill: teal, super(it))).
    #if inside { deixis-inline-note-body(of: <inner>)[#live.update(xs => xs + ("inner",))Inner body.] }
  ]
]
Outer#deixis-mark(id: <outer>).
#{
  if kind == "inset" {
    deixis-inset-note-body(of: <outer>, layer: layer, width: 250pt, dx: 25pt, dy: 30pt, body)
  } else if kind == "margin" {
    deixis-margin-note-body(of: <outer>, layer: layer, side: right, width: 95pt, body)
  } else if kind == "footnote" { deixis-footnote-body(of: <outer>, layer: layer, body) }
  else if kind == "inline" { deixis-inline-note-body(of: <outer>, inline: false, body) }
  else { deixis-endnote-body(of: <outer>, body); deixis-print-endnotes() }
}
#if not inside { deixis-inline-note-body(of: <inner>, inline: false)[#live.update(xs => xs + ("inner",))Inner body.] }
After.
#pagebreak()
#link(<outer>)[Outer] #deixis-ref(<inner>) #link(<inner>)[Inner]
#let verify() = {
  let sys = deixis-system.final()
  assert.eq(live.final().sorted(), ("inner", "outer"))
  assert.eq(query(<deixis-scope>).len(), 1)
  assert.eq(query(<deixis-rendered-start>).len(), 2)
  assert.eq(query(<deixis-body-destination>).len(), 2)
  assert.eq(sys.stack, ())
  assert.eq(_deixis-layout-scopes.final().stack, ())
  let get(id) = sys.registry.value.notes.at(sys.registry.value.id-index.at(str(id)))
  assert.eq(get(<outer>).count, 1)
  assert.eq(get(<inner>).count, 1)
  assert.eq(get(<inner>).inst-id, query(<deixis-scope>).first().value.id)
  assert.ne(get(<outer>).count-id, get(<inner>).count-id)
  assert.eq(get(<inner>).target-id, get(<inner>).inst-id)
  let local-body = query(<deixis-inline-note>).find(n => n.value.id == <inner>).value
  assert.eq(local-body.inst-id, get(<inner>).inst-id)
  assert.eq(local-body.target-id, get(<inner>).target-id)
  assert.eq(local-body.count, 1)
  assert.eq(query(<deixis-mark-destination>).len(), 2)
  assert.eq(query(<deixis-mark-occurrence>).len(), 1)
  (destinations: (<outer>, <inner>).map(id => {
    let pos = query(id).first().location().position()
    (page: pos.page, x: pos.x.pt(), y: pos.y.pt())
  }))
}
