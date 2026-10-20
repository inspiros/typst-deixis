#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#set page(width: 520pt, height: 650pt, margin: 40pt)
#show: deixis-setup-notes
#context assert.eq(deixis-note-counter(), 0)

// Punctuation and empty series names are literal independent keys.
#deixis-update-note-counter(7, target: "alpha", series: "beta:gamma")
#deixis-update-note-counter(20, target: "alpha:beta", series: "gamma")
#deixis-block(id: "alpha")[
  #deixis-mark(id: <first>, series: "beta:gamma", mark-type: "phantom")
  #context assert.eq(deixis-note-counter(series: "beta:gamma"), 8)
]
#deixis-block(id: "alpha:beta")[
  #context assert.eq(deixis-note-counter(series: "gamma"), 20)
  #deixis-update-note-counter(n => n + 3, series: "gamma")
  #deixis-mark(id: <second>, series: "gamma", mark-type: "phantom")
  #context assert.eq(deixis-note-counter(series: "gamma"), 24)
]
#context {
  assert.eq(deixis-note-counter(target: <alpha>, series: "beta:gamma"), 8)
  assert.eq(deixis-note-counter(target: "alpha:beta", series: "gamma"), 24)
  assert.eq(deixis-note-counter(target: "alpha", series: "gamma"), 0)
}
#deixis-update-note-counter(2, series: "")
#deixis-update-note-counter(4, series: "left:rest")
#deixis-update-note-counter(6, series: "left")
#deixis-update-note-counter(8, series: "rest")
#context {
  assert.eq(deixis-note-counter(series: ""), 2)
  assert.eq(deixis-note-counter(series: "left:rest"), 4)
  assert.eq(deixis-note-counter(series: "left"), 6)
  assert.eq(deixis-note-counter(series: "rest"), 8)
}

// Updates, resets, mark kinds, bodies, references, and repeats have distinct roles.
#deixis-update-note-counter(10)
#deixis-endnote-body(of: <inline>)[Body before original.]
#deixis-mark(of: <inline>, occurrence: <early>)[A forward reuse]
#deixis-mark(id: <inline>)[Original inline]
#deixis-region-mark(id: <region>)[Original region]
#deixis-phantom-mark(id: <phantom>)
#deixis-endnote-body(of: <region>)[Region body.]
#deixis-endnote-body(of: <phantom>)[Phantom body.]
#context assert.eq(deixis-note-counter(), 13)
#deixis-update-note-counter(n => n + 2)
#deixis-mark(id: <incremented>, mark-type: "phantom")
#deixis-update-note-counter(0)
#deixis-mark(id: <reset>, mark-type: "phantom")
#deixis-endnote-body(of: <incremented>)[Incremented body.]
#deixis-endnote-body(of: <reset>)[Reset body.]
#deixis-endnote-body(id: <standalone>, series: "printed")[Unnumbered standalone body.]
#deixis-mark(of: <inline>)[Reuse after reset]
Reference #deixis-ref(<inline>).
#context {
  assert.eq(deixis-note-counter(), 1)
  assert.eq(deixis-note-counter(series: "printed"), 0)
}

// Thread and synchronization aliases deliberately share the same stream.
#deixis-block(id: <shared-a>, thread: "shared")[
  #deixis-phantom-mark(id: <thread-first>, series: "notes")
]
#deixis-block(id: <shared-b>, thread: "shared")[
  #deixis-update-note-counter(n => n + 4, target: <shared-a>, series: "notes")
  #deixis-phantom-mark(id: <thread-second>, series: "notes")
]
#deixis-block(sync-counters-with: <shared-b>)[
  #deixis-phantom-mark(id: <synced>, series: "notes")
  #context assert.eq(deixis-note-counter(series: "notes"), 7)
]
#context {
  assert.eq(deixis-note-counter(target: <shared-a>, series: "notes"), 7)
  assert.eq(deixis-note-counter(target: <shared-b>, series: "notes"), 7)
  assert.eq(deixis-note-counter(series: "notes"), 0)
}
#deixis-block(id: <parent>)[
  #deixis-block[
    #deixis-update-note-counter(30, target: -1)
    #deixis-phantom-mark(id: <parent-note>, target: -1)
    #context assert.eq(deixis-note-counter(), 0)
  ]
  #context assert.eq(deixis-note-counter(), 31)
]
// Integer semantics remain unrestricted; custom numbering may handle negatives.
#deixis-update-note-counter(-2, series: "signed")
#deixis-phantom-mark(id: <signed>, series: "signed", numbering: n => str(n))
#deixis-update-note-counter(-1, series: "zero")
#deixis-phantom-mark(id: <zero>, series: "zero")

#deixis-print-endnotes()
#for id in (<inline>, <region>, <phantom>, <incremented>, <reset>, <standalone>) {
  [#link(id)[Native destination] ]
}
#context {
  let registry = deixis-system.final()
  for (id, expected) in (("first", 8), ("second", 24), ("inline", 11), ("region", 12),
    ("phantom", 13), ("incremented", 16), ("reset", 1), ("thread-first", 1),
    ("thread-second", 6), ("synced", 7), ("parent-note", 31), ("signed", -1), ("zero", 0)) {
    assert.eq(registry.registry.value.notes.at("id-" + id).count, expected)
  }
  assert.eq(registry.registry.value.notes.at("id-standalone").count, none)
  assert.eq(query(<deixis-rendered-start>).len(), 6)
  [#metadata((destinations: query(<deixis-body-destination>).map(body => {
    let pos = body.location().position()
    (page: pos.page, x: pos.x.pt(), y: pos.y.pt())
  })))<test-result>]
}
