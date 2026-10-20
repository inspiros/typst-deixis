#import "../../src/lib.typ": *
#set page(width: 500pt, height: 300pt, binding: right, margin: (inside: 100pt, outside: 80pt, y: 40pt))
#show: deixis-setup-notes

#deixis-set(margin-layout: "adaptive")
Outside#deixis-margin-note(side: "outside")[Adaptive outside.]
#v(40pt)
Inside#deixis-margin-note(side: "inside")[Adaptive inside.]
#pagebreak()
#deixis-set(margin-layout: "flow")
Outside#deixis-margin-note(side: "outside")[Flow layout outside.]
#v(40pt)
Inside#deixis-margin-note(side: "inside")[Flow layout inside.]
#pagebreak()
#set page(binding: left)
#deixis-set(margin-layout: "exact")
Outside#deixis-margin-note(side: "outside")[Exact outside.]
#v(40pt)
Inside#deixis-margin-note(side: "inside")[Exact inside.]
#pagebreak()
Outside#deixis-margin-note(layer: "flow", side: "outside")[Immediate outside.]
#v(40pt)
Inside#deixis-margin-note(layer: "flow", side: "inside")[Immediate inside.]

#context {
  let notes = query(<deixis-rendered-start>).sorted(key: n => n.value.internal-id)
  assert.eq(notes.len(), 8)
  assert.eq(notes.map(n => n.location().page()), (1, 1, 2, 2, 3, 3, 4, 4))
  assert.eq(notes.map(n => n.location().position().x < 100pt), (true, false, false, true, false, true, true, false))
}
