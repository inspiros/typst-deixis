#import "../../src/lib.typ": *
#set page(width: 500pt, height: 600pt, margin: 60pt)
#show: deixis-setup-notes

// More forward synchronization hops than Typst's layout pass limit. The scope
// graph must resolve in one lookup, not acquire one more hop on each pass.
#deixis-update-note-counter(20, target: "chain-1")
#deixis-inline-mark(id: <chain-note>, target: "chain-1")[Forward]
#deixis-inline-note-body(of: <chain-note>)[Forward chain body.]
#for i in range(1, 9) {
  deixis-block(id: "chain-" + str(i), sync-counters-with: if i == 8 { "page" } else { "chain-" + str(i + 1) })[
    Chain block #i.
    #context assert.eq(deixis-note-counter(), 21)
  ]
}
#deixis-inline-mark(id: <page-note>)[Page]
#deixis-inline-note-body(of: <page-note>)[Page body.]
#context assert.eq(deixis-note-counter(), 22)

// A future nested scope can inherit its parent's synchronized counter through
// a relative target, even when the initiating mark is outside that parent.
#deixis-inline-mark(id: <relative-note>, target: <inner>)[Relative]
#deixis-inline-note-body(of: <relative-note>)[Relative future body.]
#deixis-block(id: <outer>, sync-counters-with: "page") [
  #deixis-block(id: <inner>, sync-counters-with: 0)[
    #context assert.eq(deixis-note-counter(), 23)
  ]
]
#context assert.eq(deixis-note-counter(), 23)
