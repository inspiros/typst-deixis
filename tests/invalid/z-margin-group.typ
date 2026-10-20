#import "../../src/lib.typ": *
#show: deixis-setup-notes
#let custom(notes, ..args) = deixis-margin-note-exact-layout(notes, ..args)
#deixis-set(margin-layout: custom)
#deixis-margin-note(id: "a", z-index: 0)[First.]
Following text.
#deixis-margin-note(id: "b", z-index: 2)[Second.]
Following text.
