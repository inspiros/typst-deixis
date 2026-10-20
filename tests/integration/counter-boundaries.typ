#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#set page(width: 540pt, height: 480pt, margin: (x: 105pt, y: 40pt))
#show: deixis-setup-notes
#let live = state("counter-boundary-live", ())

// Native heading hooks precede title marks. Attachments/reuse can be forward,
// and a new chapter does not renumber an earlier annotation or another series.
#{
  show heading.where(level: 1): it => {
    deixis-update-note-counter(0, target: "page", series: "chapters")
    it
  }
  deixis-endnote-body(of: <chapter-title>)[Forward title body.]
  [Before the declaration: #deixis-mark(of: <chapter-title>)[shared title].]
  heading(level: 1)[First #deixis-mark(id: <chapter-title>, series: "chapters",
    mark-type: "region", inline: true, layer: "foreground")[title]]
  deixis-endnote(id: <chapter-next>, series: "chapters")[Second note.]
  deixis-endnote(id: <todo-first>, series: "todos")[First task.]
  heading(level: 2)[Subsection]
  deixis-endnote(id: <chapter-third>, series: "chapters")[Third note.]
  heading(level: 1)[Second chapter]
  deixis-endnote(id: <chapter-restart>, series: "chapters")[Restarts at one.]
  deixis-endnote(id: <todo-second>, series: "todos")[Second task.]
  [Old number: #deixis-ref(<chapter-third>).
    #deixis-mark(of: <chapter-title>)[Another title occurrence].]
  deixis-print-endnotes()
}

// A physical or printed page change does not reset a document-owned stream.
#pagebreak()
#counter(page).update(1)
#deixis-phantom-mark(id: <physical-next>, series: "chapters")
#context assert.eq(deixis-note-counter(series: "chapters"), 2)
// For deliberately created page boundaries, reset explicitly before originals.
#pagebreak()
#deixis-update-note-counter(0, series: "chapters")
#deixis-phantom-mark(id: <physical-reset>, series: "chapters")

// Local heading hooks select the current owner, including synchronized aliases.
#let section(body) = {
  show heading.where(level: 1): it => {
    deixis-update-note-counter(0, series: "scoped")
    it
  }
  body
}
#deixis-update-note-counter(50, target: "page", series: "scoped")
#deixis-block(id: <scope-a>, thread: "reset-sections")[
  #deixis-update-note-counter(8, series: "scoped")
  #section[
    = Scoped #deixis-mark(id: <scope-title>, series: "scoped")[title]
    #deixis-phantom-mark(id: <scope-next>, series: "scoped")
  ]
]
#deixis-block(id: <scope-b>, sync-counters-with: <scope-a>)[
  #section[
    = Alias
    #deixis-phantom-mark(id: <scope-reset>, series: "scoped")
  ]
]
#context {
  assert.eq(deixis-note-counter(target: <scope-a>, series: "scoped"), 1)
  assert.eq(deixis-note-counter(target: <scope-b>, series: "scoped"), 1)
  assert.eq(deixis-note-counter(target: "page", series: "scoped"), 50)
}

// Arbitrary show callbacks cannot be inspected in advance. A native context
// keeps dynamically generated resets and originals in their live order.
#let custom-content = {
  show strong: it => {
    deixis-update-note-counter(0, series: "custom")
    it
  }
  [*#deixis-mark(id: <custom-title>, series: "custom")[Custom title]*
    #deixis-phantom-mark(id: <custom-after>, series: "custom")]
}
#deixis-update-note-counter(7, series: "custom")
#deixis-inline-note-body(id: <custom-body>, inline: false)[#context { custom-content }]
#link(<custom-body>)[Custom body.]

// A heading show rule can generate a reset inside a live body. Nested originals
// must not be prepared across that boundary, even for deferred/background output.
#let cases = (("inline", "flow"), ("endnote", "flow"),
  ("footnote", "flow"), ("footnote", "foreground"), ("footnote", "background"),
  ("margin", "flow"), ("margin", "foreground"), ("margin", "background"),
  ("inset", "flow"), ("inset", "foreground"), ("inset", "background"))
#for (kind, layer) in cases {
  pagebreak()
  let name = kind + "-" + layer
  deixis-update-note-counter(9, target: "page", series: name)
  let body = {
    show heading.where(level: 1): it => {
      deixis-update-note-counter(0, target: "page", series: name)
      it
    }
    [#live.update(ids => ids + (name,))
      Before #deixis-mark(id: name + "-before", series: name).
      = Title #deixis-mark(id: name + "-title", series: name)
      After #deixis-mark(id: name + "-after", series: name).
    ]
  }
  [#name #deixis-mark(id: name, series: "owners")]
  if kind == "inline" { deixis-inline-note-body(of: name, inline: false, body) }
  else if kind == "endnote" {
    deixis-endnote-body(of: name, body)
    deixis-print-endnotes()
  } else if kind == "footnote" { deixis-footnote-body(of: name, layer: layer, body) }
  else if kind == "margin" { deixis-margin-note-body(of: name, layer: layer, side: right, width: 95pt, body) }
  else { deixis-inset-note-body(of: name, layer: layer, width: 200pt, dy: 25pt, body) }
  [ Allocation anchor.]
}

#context {
  let registry = deixis-system.final()
  let count(id) = registry.registry.value.notes.at("id-" + id).count
  for (id, expected) in (("chapter-title", 1), ("chapter-next", 2), ("chapter-third", 3),
    ("chapter-restart", 1), ("todo-first", 1), ("todo-second", 2),
    ("physical-next", 2), ("physical-reset", 1),
    ("scope-title", 1), ("scope-next", 2), ("scope-reset", 1),
    ("custom-title", 1), ("custom-after", 2)) {
    assert.eq(count(id), expected, message: id)
  }
  for (kind, layer) in cases {
    let name = kind + "-" + layer
    // Background live content precedes that physical page's main-flow reset.
    let before = if layer == "background" { 1 } else { 10 }
    for (suffix, expected) in (("before", before), ("title", 1), ("after", 2)) {
      assert.eq(count(name + "-" + suffix), expected, message: name + "-" + suffix)
    }
  }
  assert.eq(live.final().sorted(), cases.map(((kind, layer)) => kind + "-" + layer).sorted())
  assert.eq(query(<deixis-rendered-start>).len(), 18)
  [#metadata((destinations: query(<deixis-body-destination>).map(body => {
    let pos = body.location().position()
    (page: pos.page, x: pos.x.pt(), y: pos.y.pt())
  })))<test-result>]
}
