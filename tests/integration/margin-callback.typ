#import "../../src/lib.typ": *
#set page(width: 440pt, height: 240pt, margin: (x: 80pt, y: 40pt))
#show: deixis-setup-notes

// Existing custom layout hooks keep their arguments and may alter dimensions
// before delegating to a public built-in layout.
#let custom(notes, top-bound, bottom-bound, start-x, text-width, end-y,
  left-space, right-space, current-page, ..args,
) = {
  [#metadata(current-page)<custom-margin-layout>]
  let narrower = notes.map(n => n + (note-data: n.note-data + (width: 50%)))
  deixis-margin-note-adaptive-layout(narrower, top-bound, bottom-bound, start-x, text-width,
    end-y, left-space, right-space, current-page, ..args.named())
}
#let body(data, ..args) = layout(size => box(width: 100%, height: 55pt, {
  if not data.at("disable-links", default: false) {
    place(top + left, [#metadata(size.width)<custom-margin-body>])
  }
  deixis-native-render-single(data, ..args.named())
}))
#deixis-set(margin-layout: custom)

One#deixis-margin-note(side: right, render-single: body)[First.]
#v(20pt)
Two#deixis-margin-note(side: right, render-single: body)[Second.]
#v(20pt)
Three#deixis-margin-note(side: right, render-single: body)[Third.]
#pagebreak()
#set page(width: 520pt, margin: (x: 120pt, y: 40pt))
Continuation.

#context {
  let bodies = query(<custom-margin-body>)
  assert.eq(query(<custom-margin-layout>).map(n => n.value), (1, 2))
  assert.eq(bodies.map(n => n.location().page()), (1, 1, 2))
  assert.eq(bodies.map(n => n.value), (40pt, 40pt, 60pt))
  assert.eq(query(<deixis-rendered-start>).len(), 3)
}
